# External Repositories

## Summary

This is a WIP summary of approaches to external dependencies. The text isn't structured at this point. It's a raw capture of current understanding so we can collaborate on the issues and approaches. When we close on that, we can turn this into real user documentation.

Every scala build is going to have external dependencies. There are toolchain dependencies like the scala compiler and runtime library. There are dependencies used by the `rules_scala` infrastructure like `commons-io` in the scalac driver. Users will have dependencies in their code represented in build files, things like like `com.fasterxml.jackson.core`.

Some of these dependencies are java and so can be imported fairly straightforwardly.

Scala dependencies are more complicated in a multiscala environment. Now each abstract dependency is potentially multiple concrete dependencies. For example, abstractly `scalatest` is a single dependency. In a multiscala environment, this can actually mean multiple jars, e.g., `org.scalatest:scalatest_2_11` and `org.scalatest:scalatest_2_12`. We do not want any manual per-version repetition exposed to the user in the common case.

There are also multiple mechanisms for downloading external dependencies. All these mechanisms end up downloading the desired contents into one or more external bazel repositories.

The mapping from dependency to label depends on the loader used: e.g., [`jvm.bzl`](https://github.com/bazelbuild/bazel/blob/master/tools/build_defs/repo/jvm.bzl)(and it's variants), [`rules_jvm_external`](https://github.com/bazelbuild/rules_jvm_external), etc. These mechanisms create labels in incompatible ways. Moreover, in many cases, the exact labels used depends on arguments provided by the user.

Mandating a particular loading mechanism and with particular arguments would provide the ability to uniquely map scala version to label but this restriction is not acceptable.

There appear to be two options:
1. use pairs of helper macros to produce and consume structured labels
2. use `bind` to create labels in a canonical pattern

Both of these approaches would rely on a canonical representation of a dependency. Presumably this would be something like `{org}:{artifact}:{version}`. At target creation time, version would be dropped, e.g., `{org}:{artifact}`. The scala version _is not_ included in the canonical representation since it's assume to follow the common scala pattern. (This is actually a bit of a problem for the `org.scala-lang` artifacts that don't follow the common pattern.)

## Using helper macros

In essence, for each loader type (and with the user being able to extend), a pair of macros would be defined, each of which takes the canonical format. The loader macro would translate the canonical coordinate to an external repo request, e.g.,
```
"commons-io:commons-io:2.6"
```
could translate to a macro the calls, approximately,
```
    _scala_maven_import_external(
        name = "scalac_rules_commons_io",
        artifact = "commons-io:commons-io:2.6",
        artifact_sha256 = "f877d304660ac2a142f3865badfc971dec7ed73c747c7f8d5d2f5139ca736513",
        licenses = ["notice"],
        server_urls = ...
    )
```
or one that calls
```
maven_install(
    artifacts = [
        "commons-io:commons-io:2.6",
    ],
    repositories = ...
)
```
These aren't literal but accurate in direction.

In the case of a scala dep, they must make loader calls for each coordinate for each version. (FWIW, bazel is smart enough to only download the versions you need for the targets you ask for.)

The rule-time reference takes the coordinate and returns the label the loader produces. In the cases above, these would be `@scalac_rules_common_io//jar` and `@maven//:commons_io_commons_io`.

In both cases, the macros needs to know whether the jar is scala-versioned and adjust accordingly.

This all seems very doable and can, to some extent, be built into the library so it doesn't have to be reflected in every build file.

Because loading and rule-time reference are so far apart in the structure of bazel, I think it might be necessary to parameterize this behavior per repo by injecting the user choice into the synthetically-created configuration repository. This is not particularly hard or objectionable.

The bigger concern is if multiple loading techniques are used within the same workspace, e.g., some `jvm.bzl` and some `rules_jvm_external`. It relatively straightfoward to to do this but the simplest approach would require each build file to know which mechanism was used for each dependencies. It's possible to imagine keeping track of the per-coordinate choice in the configuration repo but that might be a bit scary ...

## Using `bind`

A potentially straightforward alternative is to simply require `bind`ing whatever label is created by the loader to a canonical label in the external namespace. This separates the loading mechanism from the rule-time consumption mechanism. This simplies consumtion at the expense of loading time work (`bind`ing labels) which, if you have to choose, is the right place to mange the complexity. Among other things, ad hoc corner-cases could be handled relatively easily, more easily than with the previous mechanism. It's also amenable to using multiple loading mechanisms without having to reflect the loader chose in build files.

It's required that the `external` path is canonically paired with the maven coordinate, e.g., `commons-io:commons-io` would end up at `//external:maven/commons-io/commons-io` no matter how the jar was loaded.

## Which to use?

I'm not sure. I don't know if we need to support mixed loaders in a single workspace. If we did, I think I'd tend to lean towards `bind`.

`bind` is considered bad in many cases and for good reason. Where patterns aren't strongly enforced and/or where it's not actually adding any value (you could easily depend on the loader label because it's well  known), using `bind` is a significant increase in complexity. However, here we'd be using a very strict target pattern which, among other things, would make understanding the meaning  of th label and searching for references to the label straightforward.

The alternative, at this point, in the face of supporting multiple loading mechanisms by needing to reflect the mechanism for each dependency in every build file, I find a significant burden for build file writers.

The alternative of keeping a map of the necessary information in the configuration workspace is potentially viable but I haven't really investigated it.

## Open issues

### Handling different versions across different targets

Do we need this? I suspect we might, for instance if the version of `commons-io` we need for building the toolchain is different than the one a user wants for their own code. I think the answer to this is the idea of a scope.

This is easy to handle at load time: `rules_jvm_external` has this natively and it can added systemtically as part of the name in `jvm.bzl` repos.

We would have to figure out how to reflect scopes in rule dependencies since it's not reflected in the normal maven coordinate.

### Handling different shas for tools that want to pass the shas inline

`rules_jvm_external` doesn't use this (it puts the shas in a separate out-of-band file in a way that shouldn't affect this work). Other tools like `jvm.bzl` do. Maybe we factor our the shas into a dict and add them at repo call time.

### Handling multiple references to the same object

This is essentially the `if not native.existing_rule` issue and I still don't have a handle on what happens (or should happen) when you have reconvergence: where two paths want the same dependency and give it the same label but spec different versions, e.g., protobufs. IIUC, it's possible you could get non-deterministic builds because I think the results would depend on execution order of loads which I think can run concurrently and therefore non-deterministicly.
