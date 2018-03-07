package third_party.plugin.src.main.io.bazel.rulesscala.dependencyanalyzer

trait DependencyContext {}

case object DependencyByMemberRef extends DependencyContext
case object DependencyByInheritance extends DependencyContext
case object LocalDependencyByInheritance extends DependencyContext