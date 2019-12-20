package io.bazel.rules_scala.target_split

import scala.collection.immutable.SortedSet

object Graph {

  def dagify[A: Ordering](seed: Set[A])(neighbors: A => Set[A]): Dagify[A] =
    new Dagify[A](seed, neighbors)

  def dagifyGraph[A: Ordering](graph: Map[A, Iterable[A]]): Dagify[A] =
    dagify(graph.keySet) { a => graph.getOrElse(a, Nil).toSet }

  /**
   * Build a DAG by merging individual nodes of type A into merged nodes of type SortedSet[A]
   */
  final class Dagify[A: Ordering](seed: Set[A], val neighbors: A => Set[A]) {

    @annotation.tailrec
    private def allNodes(toCheck: List[A], reached: Set[A], acc: SortedSet[A]): SortedSet[A] =
      toCheck match {
        case Nil => acc
        case h :: tail =>
          if (reached(h)) allNodes(tail, reached, acc)
          else allNodes(neighbors(h).toList.sorted ::: tail, reached + h, acc + h)
      }

    // all the reachable nodes in a sorted order
    val nodes: SortedSet[A] =
      allNodes(seed.toList, Set.empty, SortedSet.empty)

    /*
     * For each node, build the full set of nodes it can reach by the neighbors function
     */
    @annotation.tailrec
    private def reachable(m: List[(A, SortedSet[A])],
                          acc: List[(A, SortedSet[A])]): Map[A, SortedSet[A]] =
      if (m.isEmpty) acc.toMap
      else {
        // if A -> B, then include all the nodes B can reach
        val stepped = m.iterator.map {
          case (src, dest0) =>
            // expand src + dest0 by looking at all the neighbors of this set
            val dest1 = dest0.flatMap(neighbors) ++ neighbors(src)
            (src, (dest0, dest1))
        }.toList

        // if the expanded set is the same as the initial set, that node has computed its full reach
        // and is done, else we need to continue to expand
        val (done, notDone) = stepped.partition { case (_, (d0, d1)) => d0 == d1 }
        reachable(notDone.map { case (k, (_, d1))                    => (k, d1) }, done.map {
          case (k, (d0, _))                                          => (k, d0)
        } ::: acc)
      }

    private def toSortedSet[T: Ordering](it: Iterator[T]): SortedSet[T] = {
      val bldr = SortedSet.newBuilder[T]
      bldr ++= it
      bldr.result()
    }

    // all the reachable nodes from a given node
    val reachableMap: Map[A, SortedSet[A]] =
      reachable(nodes.iterator.map { a =>
        (a, SortedSet.empty[A])
      }.toList, Nil)

    type Cluster = SortedSet[A]
    implicit val ordCluster: Ordering[Cluster] = Ordering.Iterable[A].on { s: SortedSet[A] =>
      s
    }

    // To make a dag, we group nodes together that are mutually reachable, these larger sets
    // become the new nodes in the bigger graph
    val clusterMembers: SortedSet[Cluster] =
      toSortedSet(reachableMap.iterator.map {
        case (n, reach) =>
          if (reach(n)) {
            // we can reach ourselves, so we include everyone in this cluster that can reach us
            toSortedSet(reach.iterator.collect { case n1 if reachableMap(n1)(n) => n1 })
          } else SortedSet(n)
      })

    // which cluster is each node in
    val clusterMap: Map[A, Cluster] =
      nodes.iterator.map { n =>
        n -> clusterMembers.iterator.filter(_(n)).next
      }.toMap

    // this must form a DAG now by construction
    val clusterDeps: Map[Cluster, SortedSet[Cluster]] =
      clusterMembers.iterator.map { c =>
        val reach = c.flatMap(neighbors)
        val deps = clusterMembers.filter { c1 =>
          reach.exists(c1)
        } - c
        (c, deps)
      }.toMap

    lazy val topological: List[List[Cluster]] = {
      def loop(prev: List[Cluster], rest: List[Cluster], acc: List[List[Cluster]]): List[List[Cluster]] =
        if (rest.isEmpty) acc.reverse.map(_.sorted)
        else {
          // everyone that can reach the prev is in the next group
          val (next, notyet) = rest.partition { c =>
            val cdeps = clusterDeps(c)
            // are all of the deps already seen?
            prev.forall(cdeps)
          }

          loop(next reverse_::: prev, notyet, next :: acc)
        }

        loop(Nil, clusterMembers.toList, Nil)
    }

    /**
     * if the original A graph was a DAG, then all the clusters are singletons
     */
    lazy val originalIsDag: Boolean =
      clusterMembers.forall(_.size == 1)
  }
}

