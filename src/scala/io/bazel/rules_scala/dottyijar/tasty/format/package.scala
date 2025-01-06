package io.bazel.rules_scala.dottyijar.tasty

import com.softwaremill.tagging.*

package object format {
  private val isDebuggingEnabled: Boolean = Option(System.getProperty("DEBUG_TASTYFORMAT")).contains("true")

  trait Signed
  trait Unsigned

  type SignedInt = Int @@ Signed
  type SignedLong = Long @@ Signed
  type UnsignedInt = Int @@ Unsigned
  type UnsignedLong = Long @@ Unsigned
}
