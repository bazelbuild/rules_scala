# Dependency Tracking

## [Experimental] Dependency options

There are a number of dependency options which can be set in the scala toolchain. These include 
`dependency_mode`, `strict_deps_mode`, `unused_dependency_checker_mode`, and 
`dependency_tracking_method`.

### [Experimental] Recommended options

We recommend one of the following sets of options

**Option A**
Accept the defaults, which might work well enough for you. The defaults are
```
  dependency_mode = "direct",
  strict_deps_mode = "off",
  unused_dependency_checker_mode = "off",
  dependency_tracking_method = "high-level",
```
but you do not need to include this in the toolchain as they are the defaults.

**Option B**
```
  dependency_mode = "plus-one",
  strict_deps_mode = "error",
  unused_dependency_checker_mode = "error",
  dependency_tracking_method = "ast",
```

Should the first option result in too much effort in handling build files and the like due to 
confusing dependencies and you becoming confused as to why some specific dependency is needed when 
the code being compiled never references it, consider this set of options. It will include both 
dependencies and dependencies of dependencies, which in practice is enough to stop almost all 
strange missing dependency errors at the cost of somewhat more incremental compile cost in 
certain cases.

With these settings, we also will error on dependencies which are unneeded, and dependencies which 
should be included in `deps` due to be directly referenced in the code, but are not.

The dependency tracking method `ast` is experimental but so far proves to be better than the default 
for computing the direct dependencies for `plus-one` mode code. In the future we hope to make this 
the default for `plus-one` mode and remove the option altogether.

To try it out you can use the following toolchain: 
`@io_bazel_rules_scala//scala:minimal_direct_source_deps`.

### [Experimental] Dependency mode

There are three dependency modes. The reason for the multiple modes is that often `scalac` depends 
on jars which seem unnecessary at first glance. Hence, in order to reduce the need to please 
`scalac`, we provide the following options.
- `dependency_mode = "direct"` - only include direct dependencies during compiliation; that is, 
those in the `deps` attribute
- `dependency_mode = "plus-one"` - only include `deps` and `deps` of `deps` during compiliation.
- `dependency_mode = "transitive"` - all transitive dependencies are included during compiliation. 
That is, `deps`, `deps` of `deps`, `deps` of `deps` of `deps`, and so on.

Note when a dependency is included, that means its jars are included on the classpath, along with 
the jars of any targets that it exports.

When using `direct` mode, there can be cryptic `scalac` errors when one mistakenly depends on a 
transitive dependency or, as more often the case for some, a transitive dependency is needed to 
[please scalac](https://github.com/scalacenter/advisoryboard/blob/master/proposals/009-improve-direct-dependency-experience.md) 
itself.

As one goes down the list, more dependencies are included which helps reduce confusing requirements 
to add `deps`, at the cost of increased incremental builds due to a greater number of dependencies. 
In practice, using `plus-one` deps results in almost no confusing `deps` entries required while 
still being relatively small in terms of the number of total dependencies included.

**Caveats for `plus_one` and `transitive`:**
<ul>
    <li>Extra builds- Extra dependencies are inputs to the compilation action which means you can 
    potentially have more build triggers for changes the cross the ijar boundary </li>
    <li>Label propagation- since label of targets are needed for the clear message and since it's 
    not currently supported by JavaInfo from bazel we manually propagate it. This means that the 
    error messages have a significantly lower grade if you don't use one of the scala rules or 
    `scala_import` (since they don't propagate these labels)</li>
    <li>javac outputs incorrect targets due to a problem we're tracing down. Practically we've 
    noticed it's pretty trivial to understand the correct target (i.e. it's almost a formatting 
    problem) </li>
  </ul>

Note: the last two issues are bugs which will be addressed by 
[https://github.com/bazelbuild/rules_scala/issues/839].

### [Experimental] Strict deps mode
We have a strict dependency checker which requires that any type referenced in the sources of a 
scala target should be included in that rule's deps. To learn about the motivation for this you can 
visit this Bazel blog [post](https://blog.bazel.build/2017/06/28/sjd-unused_deps.html) on the 
subject.

The option `strict_deps_mode` can be set to `off`, `warn`, or `error`. We highly recommend setting 
it to `error`.

In both cases of `warn` or `error` you will get the following text in the event of a violation:
```
...
Target '//some_package:transitive_dependency' is used but isn't explicitly declared, please add it to the deps.
You can use the following buildozer command:
buildozer 'add deps //some_package:transitive_dependency' //some_other_package:transitive_dependency_user
```
Note that if you have `buildozer` installed you can just run the last line and have it automatically 
apply the fix for you.

Note that this option only applies to scala code. Any java code, even that within `scala_library` 
and other rules_scala rules, is still controlled by the `--strict_java_deps` command-line flag.

### [Experimental] Unused dependency checking
To allow for better caching and faster builds we want to minimize the direct dependencies of our 
targets. Unused dependency checking makes sure that all targets specified as direct dependencies are 
actually used. If `unused_dependency_checker_mode` is set to either
`error` or `warn` you will get the following message for any dependencies that are not used:
```
error: Target '//some_package:unused_dep' is specified as a dependency to //target:target but isn't used, please remove it from the deps.
You can use the following buildozer command:
buildozer 'remove deps //some_package:unused_dep' //target:target
```

Unused dependency checking can either be enabled globally for all targets using a scala toolchain or for individual targets using the
`unused_dependency_checker_mode` attribute.

The feature is still experimental and there can thus be cases where it works incorrectly, in these cases you can enable unused dependency checking globally through a toolchain and disable reports of individual misbehaving targets with `unused_dependency_checker_ignored_targets` which is a list of labels.

### [Experimental] Dependency tracking method

The strict dependency tracker and unused dependency tracker need to track the used dependencies of a scala compilation unit. This toggle allows one to pick which method of tracking to use.

- `dependency_tracking_method = "high-level"` - This is the existing tracking method which has false positives and negatives but generally works reasonably well for `direct` dependency mode.
- `dependency_tracking_method = "ast"` - This is a new tracking method which is being developed for `plus-one` and `transitive` dependency modes. It is still being developed and may have issues which need fixing. If you discover an issue, please submit a small repro of the problem.

By default, `plus-one` and `transitive` dependency modes will use the `ast` dependency tracking method, while `direct` mode will use the `high-level` dependency tracking method.

Note we intend to eventually remove this flag and make the defaults non-configurable.

### [Experimental] Turning on strict_deps_mode/unused_dependency_checker_mode

It can be daunting to turn on strict deps checking or unused dependency mode checking on a large codebase. However, it need not be so bad if this is done in phases

1. Have a default scala toolchain `A` with the option of interest set to `off` (the starting state)
2. Create a second scala toolchain `B` with the option of interest set to `warn` or `error`. Those who are working on enabling the flag can run with this toolchain as a command line argument to help identify issues and fix them.
3. Once all issues are fixed, change `A` to have the option of interest set to `error` and delete `B`.

We recommend turning on strict_deps_mode first, as rule `A` might have an entry `B` in its `deps`, and `B` in turn depends on `C`. Meanwhile, the code of `A` only uses `C` but not `B`. Hence, the unused dependency checker, if on, will request that `B` be removed from `A`'s deps. But this will lead to a compile error as `A` can no longer depend on `C`. However, if strict dependency checking was on, then `A`'s deps is guaranteed to have `C` in it.

### Include/exclude filters
Both strict and unused deps tracking scope can be controlled by configuring *prefixes* of 
included/excluded targets on the toolchain with attributes 
`dependency_tracking_strict_deps_patterns`, `dependency_tracking_unused_deps_patterns`.
Filters can be used for gradual migration towards strict/unused deps error mode. In general, you 
should get strict deps working first before enabling unused deps mode. 

Patterns prefixed with "-" will exclude targets.

Example patterns: 
- `""` includes everything - default setting
- `"@//"` includes all local targets
- `"@//foo/"` includes everything under package `@//foo`, if trailing slash is omitted, it will match 
other packages, which start with "some", eg. `@//foo_bar`
- `"@//foo:bar"` includes target under label `@//foo:bar`
- `@junit_junit` includes external targets, which start with `"@junit_junit"`
- `"-@//foo:baz"` excludes target `@//foo:baz`

Exclusions take higher precedence over inclusions. Empty list will not match any targets.
