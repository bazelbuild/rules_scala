package io.bazel.rules_scala.target_split

import com.lightbend.tools.sculpt.model.{EntityKind, FullDependency, ModelJsonProtocol, Path => SPath, DependencyKind}
import java.nio.file.{Files, Path, Paths}

object SculptProcessor {
  def loadFullDeps(p: Path): Seq[FullDependency] = {
    // narrow implicit scope
    import ModelJsonProtocol._
    import spray.json._

    val str = new String(Files.readAllBytes(p), "utf-8")
    str.parseJson.convertTo[Seq[FullDependency]]
  }


  def addEdges[A](graph: Map[A, Set[A]], from: A, to: Set[A]): Map[A, Set[A]] =
    graph.get(from) match {
      case None => graph.updated(from, to)
      case Some(n) => graph.updated(from, n.union(to))
    }

  def fileGraph(deps: Seq[FullDependency]): Map[Path, Set[Path]] = {
    val pathToFile: Map[SPath, Path] =
      deps.flatMap {
        case fd if fd.kind == DependencyKind.Declares =>
          fd
            .from
            .elems
            .collect { case e if e.kind == EntityKind.File && e.name != "" => (fd.to, Paths.get(e.name)) }
        case _ => Nil
      }
      .toMap

    // here if an SPath extends or uses an SPath, we list it here
   val useExtendGraph: Map[SPath, Set[SPath]] =
      deps.foldLeft(Map.empty[SPath, Set[SPath]]) { (graph, fd) =>
        if (fd.kind == DependencyKind.Uses || fd.kind == DependencyKind.Extends) {
          addEdges(graph, fd.from, Set(fd.to))
        }
        else graph
      }

    val allSPaths: Set[SPath] =
      deps.flatMap { fd => fd.from :: fd.to :: Nil }.toSet

    def getFile(spath: SPath): Option[Path] =
      pathToFile.get(spath) match {
        case None =>
          println(s"warning: $spath file is unknown")
          None
        case some => some
      }

    allSPaths.foldLeft(Map.empty[Path, Set[Path]]) { (graph, spath) =>
      getFile(spath) match {
        case Some(path) =>
          val deps = useExtendGraph.getOrElse(spath, Set.empty)
            .iterator
            .flatMap(getFile(_).iterator)
            .toSet

          addEdges(graph, path, deps)
        case None => graph
      }
    }
  }

  def main(args: Array[String]): Unit = {
    val fds = loadFullDeps(Paths.get(args(0)))

    val graph = fileGraph(fds)
    val dag = Graph.dagifyGraph(graph)
    println(dag.clusterDeps)
  }
}
