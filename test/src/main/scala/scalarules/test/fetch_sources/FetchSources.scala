package scalarules.test.src.main.scala.scalarules.test.fetch_sources

/* This file's only purpose is to materialize the dependency in guava and be built! */
object FetchSources extends App {
  println(classOf[com.google.common.cache.Cache[_, _]])
}
