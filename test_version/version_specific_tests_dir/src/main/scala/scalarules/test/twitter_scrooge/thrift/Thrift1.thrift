namespace java scalarules.test.twitter_scrooge.thrift

include "thrift2/Thrift2_A.thrift"
include "thrift2/Thrift2_B.thrift"
include "thrift2/thrift3/Thrift3.thrift"

struct Struct1 {
  1: Thrift2_A.Struct2A msg_a
  2: Thrift2_B.Struct2B msg_b
  3: Thrift3.Struct3 msg
}