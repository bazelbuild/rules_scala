package io.bazel.rules_scala.dottyijar.tasty.format

import com.softwaremill.tagging.*
import dotty.tools.tasty.TastyFormat as DottyTastyFormat
import java.nio.charset.StandardCharsets
import java.util.UUID
import scala.collection.mutable

case class TastyWriter private (
  output: mutable.ArrayBuffer[Byte],
  private[format] var start: Int,
  private val markers: mutable.Map[MarkerType, Marker],
  private val references: mutable.ArrayBuffer[Reference],
  private val referencablePositionsById: mutable.LongMap[Int],
) {
  private def writeUncompressedLong(long: Long): Unit =
    Range(56, -8, -8).foreach(i => writeByte((long >>> i).toByte))

  private def writeUnsignedLongWithWidth(long: Long, width: Int): Unit = {
    Range(width * 7, 7, -7).foreach(remainingBits => writeByte(((long >>> (remainingBits - 7)) & 0x7f).toByte))

    writeByte(((long & 0x7f) | 0x80).toByte)
  }

  def fillInReferences(): Unit = {
    references.foreach { reference =>
      val markerType = reference.reference.relativeTo
      val marker = markers.getOrElse(markerType, throw new MarkerNotSetException(markerType))
      val relativePosition = referencablePositionsById(reference.reference.referencableId) - marker.position

      copy(start = reference.position).writeUnsignedLongWithWidth(relativePosition, TastyWriter.referenceWidth)
    }

    references.clear()
  }

  def setMarker(markerType: MarkerType): Unit = markers(markerType) = Marker(start, markerType)
  def toArray: Array[Byte] = output.toArray
  def writeByte(byte: Byte): Unit = {
    if (start == output.length) {
      output += byte
    } else {
      output(start) = byte
    }

    start += 1
  }

  def writeBytes(bytes: Array[Byte]): Unit = {
    output ++= bytes
    start += bytes.length
  }

  def writeMagicNumber(): Unit = writeBytes(DottyTastyFormat.header.map(_.toByte))
  def writeReferencable(value: TastyReferencable)(write: => Unit): Unit = {
    value.information.id.foreach(referencablePositionsById(_) = start)

    write
  }

  def writeReference(reference: TastyReference[? <: MarkerType, ?]): Unit = {
    references += Reference(reference, start)

    writeUnsignedLongWithWidth(0, TastyWriter.referenceWidth)
  }

  def writeSignedInt(int: SignedInt): Unit = writeSignedLong(int.toLong.taggedWith[Signed])

  /**
   * This method is copied from this one in Dotty:
   * [[https://github.com/scala/scala3/blob/4d3f7576ccae724e6f83d2f3d68bd4c4e1dd5a14/tasty/src/dotty/tools/tasty/TastyBuffer.scala]]
   *
   * I can't, for the life of me, understand how it works.
   */
  def writeSignedLong(long: SignedLong): Unit = {
    def writePrefix(long: Long): Unit = {
      val prefix = long >> 7

      if (prefix != 0L - ((long >> 6) & 1)) {
        writePrefix(prefix)
      }

      writeByte((long & 0x7f).toByte)
    }

    val prefix = long >> 7

    if (prefix != 0L - ((long >> 6) & 1)) {
      writePrefix(prefix)
    }

    writeByte(((long & 0x7f) | 0x80).toByte)
  }

  def writeUnsignedInt(int: UnsignedInt): Unit = writeUnsignedLong(int.toLong.taggedWith[Unsigned])
  def writeUnsignedLong(long: UnsignedLong): Unit = {
    def writePrefix(long: Long): Unit = {
      val prefix = long >> 7

      if (prefix != 0) {
        writePrefix(prefix)
      }

      writeByte((long & 0x7f).toByte)
    }

    val prefix = long >> 7

    if (prefix != 0) {
      writePrefix(prefix)
    }

    writeByte(((long & 0x7f) | 0x80).toByte)
  }

  def writeUtf8String(string: String): Unit = {
    val bytes = string.getBytes(StandardCharsets.UTF_8)

    writeUnsignedInt(bytes.length.taggedWith[Unsigned])
    writeBytes(bytes)
  }

  def writeUuid(uuid: UUID): Unit = {
    writeUncompressedLong(uuid.getMostSignificantBits)
    writeUncompressedLong(uuid.getLeastSignificantBits)
  }

  def writeWithLengthPrefixed(write: TastyWriter => Unit): Unit = {
    val bufferWriter = copy(
      output = mutable.ArrayBuffer.empty,
      start = 0,
      markers = mutable.Map.empty,
      references = mutable.ArrayBuffer.empty,
      referencablePositionsById = mutable.LongMap.empty,
    )

    write(bufferWriter)

    val buffer = bufferWriter.toArray

    writeUnsignedInt(buffer.length.taggedWith[Unsigned])

    markers ++= bufferWriter.markers.view.map { case (markerType, marker) =>
      (markerType, marker.copy(position = start + marker.position))
    }

    references ++=
      bufferWriter.references.view.map(reference => reference.copy(position = start + reference.position))

    referencablePositionsById ++=
      bufferWriter.referencablePositionsById.view.map { case (id, position) => (id, start + position) }

    writeBytes(buffer)
  }
}

object TastyWriter {
  private val referenceWidth = 4

  def empty: TastyWriter = new TastyWriter(
    output = mutable.ArrayBuffer.empty,
    start = 0,
    markers = mutable.Map.empty,
    references = mutable.ArrayBuffer.empty,
    referencablePositionsById = mutable.LongMap.empty,
  )
}

private case class ReferencedValue(relativeTo: MarkerType, value: Any)
private case class Reference(reference: TastyReference[? <: MarkerType, ?], position: Int)
