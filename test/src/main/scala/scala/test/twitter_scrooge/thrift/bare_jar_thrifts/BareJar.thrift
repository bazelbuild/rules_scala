namespace java com.foo.bar.baz

include "Foo.thrift"
include "Bar.thrift"
include "Baz.thrift"

struct BareJar {
  1: Foo foo
  2: Bar bar
  3: Baz baz
}
