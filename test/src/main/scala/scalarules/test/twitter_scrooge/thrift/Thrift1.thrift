namespace java scalarules.test.twitter_scrooge.thrift

include "thrift2/Thrift2_A.thrift"
include "thrift2/Thrift2_B.thrift"
include "thrift2/thrift3/Thrift3.thrift"

struct Struct1 {
  1: Thrift2_A.Struct2A msg_a
  2: Thrift2_B.Struct2B msg_b
  3: Thrift3.Struct3 msg
}

# A union causes scrooge to generate a `@javax.annotation.Generated` annotation,
# which was moved between jdk8 and jdk11. So having this union is important for
# testing jdk11, which requires the shims in javax.annotation:javax.annotation-api:1.3.2
# to compile.
union Union1 {
  1: Struct1 struct1
}