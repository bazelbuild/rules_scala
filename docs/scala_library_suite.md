# scala_library_suite

`scala_library_suite` allows you to define a glob or series of targets for which to generate sub
scala libraries. The outer target will export all of the inner targets.

This rule is useful for splitting up a larger target into smaller targets (typically a series of independent files),
thereby enabling better cache outputs and parallelization of building individual targets.
Generally speaking, downstream targets should not be aware of a suite's presence - it should be strictly
a parent-children relationship.