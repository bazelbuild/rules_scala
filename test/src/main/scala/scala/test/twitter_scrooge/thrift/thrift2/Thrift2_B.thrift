namespace java scala.test.twitter_scrooge.thrift.thrift2

// TODO We should be able to do a full import based on the full package
// which will make refactoring targets much less fragile
include "thrift3/Thrift3.thrift"

struct Struct2B {
  1: Thrift3.Struct3 msg
}