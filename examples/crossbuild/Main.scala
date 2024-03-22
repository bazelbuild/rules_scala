import examples.crossbuild.Hello211
import examples.crossbuild.Hello213

@main def hello = println(s"${(new Hello211).hello} from scala 2.11, ${(new Hello213).hello} from scala 2.13")
