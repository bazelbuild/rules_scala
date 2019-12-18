package io.bazel.rules_scala.target_split

import com.lightbend.tools.sculpt.model.{EntityKind, FullDependency, ModelJsonProtocol, Path => SPath, DependencyKind}
import scala.collection.immutable.SortedSet
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
          System.err.println(s"warning: $spath file is unknown")
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

  def parseArgs(list: List[String]): (List[String], Map[String, List[String]]) = {
    def isKey(s: String): Boolean = s.startsWith("-")
    list match {
      case Nil => (Nil, Map.empty)
      case h :: t =>
        if (isKey(h)) {
          val kh = h.dropWhile(_ == '-')
          val values = t.takeWhile(!isKey(_))
          val next = t.dropWhile(!isKey(_))
          val (tailPos, tailArgs) = parseArgs(next)
          val a1 = tailArgs.get(kh) match {
            case None => values
            case Some(right) => values ::: right
          }
          (tailPos, tailArgs.updated(kh, a1))
        }
        else {
          // this is an arg
          val (tailPos, tailArgs) = parseArgs(t)
          (h :: tailPos, tailArgs)
        }
    }
  }

  def dagToLibraries(target: String, root: Path, d: Graph.Dagify[Path]): List[BazelGen.ScalaLibrary] = {

    def isSrcFile(p: Path): Boolean = {
      val pstr = p.toString
      pstr.endsWith(".scala") || pstr.endsWith(".java")
    }

    val clusterToName: Map[SortedSet[Path], Option[String]] =
      d.clusterMembers
        .iterator
        .zipWithIndex
        .map { case (k, idx) =>
          val v =
            if (k.exists(isSrcFile)) Some(target + idx.toString)
            else None
          (k, v)
        }
        .toMap

    def clusterToLib(c: SortedSet[Path]): Option[BazelGen.ScalaLibrary] = {
      clusterToName(c).map { name =>
        val srcs =
          c.filter { p =>
              p.toString.endsWith(".scala") || p.toString.endsWith(".java")
            }
            .map { root.relativize(_).toString }
            .toList

        val deps = d
          .clusterDeps
          .getOrElse(c, Nil)
          .iterator
          .flatMap(clusterToName(_))
          .map(":" + _)
          .toList

        BazelGen.ScalaLibrary(name, srcs, deps, visibility = Nil, exports = Nil)
      }
    }

    d.clusterMembers.iterator.flatMap(clusterToLib).toList
  }

  def main(args: Array[String]): Unit = {
    val (posArgs, mapArgs) = parseArgs(args.toList)

    val target_name = mapArgs("target_name").head

    val fds = mapArgs
      .getOrElse("sculpt_json", Nil)
      .flatMap { path =>
        loadFullDeps(Paths.get(path))
      }

    val packageRoot = Paths.get(mapArgs("package_root").head)

    val graph = fileGraph(fds)
    val dag = Graph.dagifyGraph(graph)

    dagToLibraries(target_name, packageRoot, dag).foreach { lib =>
      println(lib.render + "\n\n")
    }
  }
}
