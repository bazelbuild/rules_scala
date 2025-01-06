package io.bazel.rules_scala.dottyijar.tasty.format

import com.softwaremill.tagging.*
import dotty.tools.dotc.util.Spans.Span
import izumi.reflect.Tag
import java.util.UUID
import scala.collection.{mutable, Factory}
import scala.deriving.Mirror
import scala.reflect.ClassTag

trait TastyFormat[A] private[format] {
  def read(reader: TastyReader): A
  def write(writer: TastyWriter, value: A): Unit

  final def bimap[B: Tag](to: A => B, from: B => A): TastyFormat[B] =
    TastyFormat(reader => to(read(reader)), (writer, value) => write(writer, from(value)))

  final def marked(markerType: MarkerType): TastyFormat[A] = new TastyFormat[A] {
    override def read(reader: TastyReader): A = {
      reader.setMarker(markerType)

      TastyFormat.this.read(reader)
    }

    override def write(writer: TastyWriter, value: A): Unit = {
      writer.setMarker(markerType)

      TastyFormat.this.write(writer, value)
    }
  }

  final def withLengthPrefixed: TastyFormat[A] = new TastyFormat[A] {
    override def read(reader: TastyReader): A = reader.readWithLength(reader.readUnsignedInt())(TastyFormat.this.read)
    override def write(writer: TastyWriter, value: A): Unit =
      writer.writeWithLengthPrefixed(TastyFormat.this.write(_, value))
  }
}

object TastyFormat {
  def apply[A: Tag](read: TastyReader => A, write: (TastyWriter, A) => Unit): TastyFormat[A] = {
    val _read = read
    val _write = write

    if (isDebuggingEnabled) {
      new DebuggingTastyFormat[A] {
        override protected def readUnderlying(reader: TastyReader): A = _read(reader)
        override protected def writeUnderlying(writer: TastyWriter, value: A): Unit = _write(writer, value)
      }
    } else {
      new TastyFormat[A] {
        override def read(reader: TastyReader): A = _read(reader)
        override def write(writer: TastyWriter, value: A): Unit = _write(writer, value)
      }
    }
  }

  inline def forIterableWithLengthPrefixed[Element: TastyFormat, SeqLike <: Seq[Element]](using
    factory: Factory[Element, SeqLike],
  ): TastyFormat[SeqLike] = TastyFormat(
    reader =>
      reader.readWithLength(reader.readUnsignedInt()) { reader =>
        factory.fromSpecific(reader.readUntilEnd(summon[TastyFormat[Element]].read(reader)))
      },
    (writer, value) =>
      writer.writeWithLengthPrefixed(writer => value.foreach(summon[TastyFormat[Element]].write(writer, _))),
  )

  inline def forIterableWithoutLengthPrefixed[Element: TastyFormat, SeqLike <: Seq[Element]](using
    factory: Factory[Element, SeqLike],
  ): TastyFormat[SeqLike] = TastyFormat(
    reader => factory.fromSpecific(reader.readUntilEnd(summon[TastyFormat[Element]].read(reader))),
    (writer, value) => value.foreach(summon[TastyFormat[Element]].write(writer, _)),
  )

  inline def forOptional[Init <: Tuple: TastyFormat, Last: TastyFormat](using
    evidence1: Tuple.Init[Tuple.Append[Init, Option[Last]]] =:= Init,
    evidence2: Tuple.Last[Tuple.Append[Init, Option[Last]]] =:= Option[Last],
  ): TastyFormat[Tuple.Append[Init, Option[Last]]] = TastyFormat(
    reader =>
      reader.readWithLength(reader.readUnsignedInt()) { reader =>
        val init = summon[TastyFormat[Init]].read(reader)

        init :* Option.unless(reader.isAtEnd)(summon[TastyFormat[Last]].read(reader))
      },
    (writer, value) =>
      writer.writeWithLengthPrefixed { writer =>
        summon[TastyFormat[Init]].write(writer, value.init)

        value.last.foreach(summon[TastyFormat[Last]].write(writer, _))
      },
  )

  inline def forProduct[A <: Product](using
    mirror: Mirror.ProductOf[A],
  )(using underlying: TastyFormat[mirror.MirroredElemTypes]): TastyFormat[A] = TastyFormat(
    reader => mirror.fromTuple(underlying.read(reader)),
    (writer, record) => underlying.write(writer, Tuple.fromProductTyped(record)),
  )

  inline def forSumType[A <: TastyReferencable: TastySumType]: TastyFormat[A] =
    TastyFormat(
      reader =>
        reader.readReferencable {
          val tag = reader.readByte()

          summon[TastySumType[A]].variantsByTag
            .getOrElse(
              tag,
              throw new Exception(
                s"Unknown tag: $tag. Expected one of ${summon[TastySumType[A]].variants.map(_.tag).mkString(", ")}",
              ),
            )
            .read(reader)
        },
      (writer, value) => {

        /**
         * Previously, we declared a `TastyReferencableFormat` type that wrapped an underlying [[TastyFormat]] value by
         * recording the position of the value to be written (which is necessary to write references to that value). We
         * ended up scrapping this and instead made all sum types "referencable" because it wasn't guaranteed that the
         * positions of sum type values would be recorded. This is due to two reasons:
         *
         *   1. [[TastySumType]]s can be composed, so even if the [[TastyFormat]] for a type `A` was referencable, it
         *      may have been passed to [[TastySumType.or]] to create a [[TastySumType]] for a supertype of `A`. Unless
         *      that supertype's [[TastyFormat]] was wrapped in a `TastyReferencableFormat`, it wouldn't be
         *      "referencable", meaning that we couldn't write references to values of type `A` unless those values were
         *      written as "`A`"s, and not some supertype of `A`.
         *   1. [[TastySumType]] composition also means that if a value of type `A` were written using a more specific
         *      [[TastyFormat]] for one of its subclasses that wasn't wrapped in a `TastyReferencableFormat`, the
         *      position for that value wouldn't have been recorded.
         */
        writer.writeReferencable(value)(
          summon[TastySumType[A]].variants
            .find(_.maybeWrite(writer, value))
            .getOrElse(throw new Exception(s"Couldn't find the variant of $value")),
        )
      },
    )

  def forValue[A: ValueOf: Tag]: TastyFormat[A] = TastyFormat(_ => summon[ValueOf[A]].value, (_, _) => {})

  inline def forVariadic[Init <: Tuple: TastyFormat, LastElement: TastyFormat, Last <: Iterable[LastElement]](using
    factory: Factory[LastElement, Last],
    evidence1: Tuple.Init[Tuple.Append[Init, Last]] =:= Init,
    evidence2: Tuple.Last[Tuple.Append[Init, Last]] =:= Last,
  ): TastyFormat[Tuple.Append[Init, Last]] = TastyFormat(
    reader =>
      reader.readWithLength(reader.readUnsignedInt()) { reader =>
        val init = summon[TastyFormat[Init]].read(reader)

        init :* summon[Factory[LastElement, Last]]
          .fromSpecific(reader.readUntilEnd(summon[TastyFormat[LastElement]].read(reader)))
      },
    (writer, value) =>
      writer.writeWithLengthPrefixed { writer =>
        summon[TastyFormat[Init]].write(writer, value.init)

        value.last.foreach(summon[TastyFormat[LastElement]].write(writer, _))
      },
  )

  given TastyFormat[SignedInt] = TastyFormat(_.readSignedInt(), (writer, value) => writer.writeSignedInt(value))
  given TastyFormat[SignedLong] = TastyFormat(_.readSignedLong(), (writer, value) => writer.writeSignedLong(value))
  given TastyFormat[Span] = summon[TastyFormat[SignedLong]].bimap(new Span(_), _.coords.taggedWith[Signed])
  given TastyFormat[String] = TastyFormat(_.readUtf8String(), (writer, value) => writer.writeUtf8String(value))
  given TastyFormat[UnsignedInt] = TastyFormat(_.readUnsignedInt(), (writer, value) => writer.writeUnsignedInt(value))
  given TastyFormat[UnsignedLong] =
    TastyFormat(_.readUnsignedLong(), (writer, value) => writer.writeUnsignedLong(value))

  given TastyFormat[UUID] = TastyFormat(_.readUuid(), (writer, value) => writer.writeUuid(value))

  inline given [A: TastyFormat]: TastyFormat[Tuple1[A]] with {
    override def read(reader: TastyReader): Tuple1[A] = Tuple1(summon[TastyFormat[A]].read(reader))
    override def write(writer: TastyWriter, value: Tuple1[A]): Unit = summon[TastyFormat[A]].write(writer, value._1)
  }

  inline given [Head: TastyFormat, Tail <: Tuple: TastyFormat]: TastyFormat[Head *: Tail] with {
    override def read(reader: TastyReader): Head *: Tail =
      summon[TastyFormat[Head]].read(reader) *: summon[TastyFormat[Tail]].read(reader)

    override def write(writer: TastyWriter, value: Head *: Tail): Unit = {
      summon[TastyFormat[Head]].write(writer, value.head)
      summon[TastyFormat[Tail]].write(writer, value.tail)
    }
  }
}

private abstract class DebuggingTastyFormat[A: Tag] extends TastyFormat[A] {
  protected def readUnderlying(reader: TastyReader): A
  protected def writeUnderlying(writer: TastyWriter, value: A): Unit

  private val typeName = summon[Tag[A]].tag.shortName

  override def read(reader: TastyReader): A = {
    DebuggingTastyFormat.depth += 1

    try {
      DebuggingTastyFormat.logBuffer ++=
        s"${"  " * DebuggingTastyFormat.depth}TastyFormat: Reading $typeName at ${reader.start}\n"

      val position = reader.start
      val result = readUnderlying(reader)

      DebuggingTastyFormat.logBuffer ++=
        s"${"  " * DebuggingTastyFormat.depth}TastyFormat: Read $result at $position\n"

      result
    } finally {
      DebuggingTastyFormat.depth -= 1
    }
  }

  override def write(writer: TastyWriter, value: A): Unit = {
    DebuggingTastyFormat.depth += 1

    try {
      DebuggingTastyFormat.logBuffer ++=
        s"${"  " * DebuggingTastyFormat.depth}TastyFormat: Writing $value at ${writer.start}\n"

      val position = writer.start

      writeUnderlying(writer, value)

      DebuggingTastyFormat.logBuffer ++=
        s"${"  " * DebuggingTastyFormat.depth}TastyFormat: Wrote $typeName at $position\n"
    } finally {
      DebuggingTastyFormat.depth -= 1
    }
  }
}

private[tasty] object DebuggingTastyFormat {
  private var depth = -1
  private val logBuffer = new mutable.StringBuilder()

  def clearLogs(): Unit = logBuffer.clear()
  def logs: String = logBuffer.toString
}

class TastySumType[A](private[format] val variants: TastySumType.Variant[? <: A]*) {
  private[format] val variantsByTag: Map[Byte, TastySumType.Variant[? <: A]] =
    variants.map(variant => variant.tag -> variant).toMap

  def peekIsVariant(reader: TastyReader): Boolean = variantsByTag.contains(reader.peek(_.readByte()))
  def or[B](other: TastySumType[B]): TastySumType[A | B] =
    new TastySumType(variants ++ other.variants*)
}

object TastySumType {
  case class Variant[A: ClassTag](tag: Byte)(using TastyFormat[A]) {
    private[format] def maybeWrite(writer: TastyWriter, value: Any): Boolean = value match {
      case value: A =>
        writer.writeByte(tag)

        summon[TastyFormat[A]].write(writer, value)

        true

      case _ => false
    }

    private[format] def read(reader: TastyReader): A = summon[TastyFormat[A]].read(reader)
  }

  object Variant {
    def apply[A: ClassTag](tag: Int)(using TastyFormat[A]): Variant[A] = new Variant(tag.toByte)
  }

  def withSingleVariant[A: ClassTag](tag: Byte, format: TastyFormat[A]): TastySumType[A] =
    new TastySumType(Variant(tag)(using summon, format))

  def withSingleVariant[A: ClassTag](tag: Int, format: TastyFormat[A]): TastySumType[A] =
    withSingleVariant(tag.toByte, format)
}
