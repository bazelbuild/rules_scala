package io.bazel.rules_scala.dottyijar.tasty.format

import dotty.tools.tasty.TastyFormat as DottyTastyFormat
import io.bazel.rules_scala.dottyijar.tasty.numeric.{SignedInt, SignedLong, UnsignedInt, UnsignedLong}
import java.nio.charset.StandardCharsets
import java.util.UUID
import scala.annotation.tailrec
import scala.collection.mutable

case class TastyReader private (
  input: Array[Byte],
  private[format] var start: Int,
  end: Int,
  markers: mutable.Map[MarkerType, Marker],
  private var nextReferencableId: Int,
  referencesByTargetPosition: mutable.LongMap[TastyReference[? <: MarkerType, ?]],
  referencablesByPosition: mutable.LongMap[TastyReferencable],
) {
  private def readNBytes(length: Int): Array[Byte] = {
    val result = input.slice(start, start + length)

    start += result.length

    result
  }

  private def readUncompressedLong(): Long = Range(0, 8).foldLeft(0L) { case (current, _) =>
    (current << 8) | (readByte() & 0xff /* This prevents sign extension */ )
  }

  def isAtEnd: Boolean = start >= end
  def linkReferences(): Unit = referencesByTargetPosition.foreach { case (position, reference) =>
    val referencable =
      referencablesByPosition.getOrElse(position, throw new Exception(s"No referencable value read at $position"))

    referencable.information = TastyReferencableInformation(Some(reference.referencableId))
  }

  def peek[A](read: TastyReader => A): A = {

    /**
     * We have [[reader]] and [[this]] share [[nextReferencableId]], [[referencesByTargetPosition]], and
     * [[referencablesByPosition]] values to increase efficiency and reduce allocations. Although the value peeked will
     * eventually be re-read, if it's a [[TastyReference]], it should be re-read with the same ID because we cache
     * references in [[referencesByTargetPosition]].
     */
    val reader = copy()
    val result = read(reader)

    nextReferencableId = reader.nextReferencableId

    result
  }

  def readByte(): Byte = {
    val result = input(start)

    start += 1

    result
  }

  def readMagicNumber(): Unit = {
    val actual = readNBytes(4)
    val expected = DottyTastyFormat.header.map(_.toByte)

    if (!java.util.Arrays.equals(actual, expected)) {
      throw new Exception(
        s"Expected a magic number of ${expected.toList}, but got ${actual.toList}",
      )
    }
  }

  def readReferencable[A <: TastyReferencable](read: => A): A = {
    val position = start
    val result = read

    referencablesByPosition(position) = result

    result
  }

  def readReference[RelativeTo <: MarkerType, Value](relativeTo: RelativeTo): TastyReference[RelativeTo, Value] = {
    val marker = markers.getOrElse(relativeTo, throw new MarkerNotSetException(relativeTo))
    val position = marker.position + readUnsignedInt().value

    referencesByTargetPosition
      .getOrElseUpdate(
        position, {
          val result = TastyReference(relativeTo, nextReferencableId)

          nextReferencableId += 1

          result
        },
      )
      .asInstanceOf[TastyReference[RelativeTo, Value]]
  }

  def readSignedInt(): SignedInt = SignedInt(readSignedLong().value.toInt)
  def readSignedLong(): SignedLong = {
    var currentByte = readByte()
    var result: Long = (currentByte << 1).toByte >> 1 // Sign extend the first byte, using bit 6 as the sign

    while ((currentByte & 0x80) == 0) {
      currentByte = readByte()
      result = (result << 7) | (currentByte & 0x7f)
    }

    SignedLong(result)
  }

  def readUnsignedInt(): UnsignedInt = UnsignedInt(readUnsignedLong().value.toInt)
  def readUnsignedLong(): UnsignedLong = {
    var currentByte = readByte()
    var result = 0L

    while {
      result = (result << 7) | (currentByte & 0x7f)

      (currentByte & 0x80) == 0
    } do {
      currentByte = readByte()
    }

    UnsignedLong(result)
  }

  def readUntilEnd[A](read: => A): List[A] = {
    val result = readWhile(!isAtEnd)(read)

    assert(start == end, s"Expected to read until $end, but stopped at $start")

    result
  }

  def readUtf8String(): String = new String(readNBytes(readUnsignedInt().value), StandardCharsets.UTF_8)
  def readUuid(): UUID = new UUID(readUncompressedLong(), readUncompressedLong())
  def readWithLength[A](length: Int)(read: TastyReader => A): A = {
    val reader = copy(end = start + length)
    val result = read(reader)

    assert(
      reader.start == reader.end,
      s"Given a length of $length, expected to read until $end, but stopped at ${reader.start}",
    )

    start = reader.start
    nextReferencableId = reader.nextReferencableId

    result
  }

  def readWhile[A](condition: => Boolean)(read: => A): List[A] = {
    @tailrec
    def withExisting(existing: List[A])(condition: => Boolean)(read: => A): List[A] = {
      if (condition) {
        withExisting(read +: existing)(condition)(read)
      } else {
        existing
      }
    }

    withExisting(List.empty)(condition)(read).reverse
  }

  def setMarker(markerType: MarkerType): Unit = markers(markerType) = Marker(start, markerType)
}

object TastyReader {
  def apply(input: Array[Byte]): TastyReader = new TastyReader(
    input,
    start = 0,
    end = input.length,
    markers = mutable.Map.empty,
    nextReferencableId = 0,
    referencesByTargetPosition = mutable.LongMap.empty,
    referencablesByPosition = mutable.LongMap.empty,
  )
}
