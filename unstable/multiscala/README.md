# This is a very early work-in-progress.

It is not only not stable, it's not complete. All the documentation here is as much or more about collaborating on the design as it is on documenting the behavior. In other words, it's highly likely that the behavior does not yet match the documentation.

## example

In [`private/example`](private/example)

## Configuration

The configuration is currently via a dict of dicts, lists, strings and booleans. It's not yet documented but there is an example in the example [`WORKSPACE`]((private/example/WORKSPACE)). The feeling is that this is ripe for refactoring. There's been a request to support multiple minor versions for the same major version which wouldn't be very hard. Another thing to consider is do we use helper macros to construct this rather than core types. That would be less error prone. Also, it's possible structs might be preferable to dicts since it might make code more succinct and less error prone.

## Creating targets

I would like to make the use of multiscala easy ("make easy things simple and hard things possible")

One goal would be that

```
scala_library(
   name = "lib",
   ...
)

scala_binary(
   name = "app",
   deps = [
     ":lib",
     ...
   ]
   ...
)
```
would act with the current default single version configuration mostly exactly as it does today: it would create a single jar for each target, e.g., `lib.jar`  and `app.jar` (but we would probably add some aliases, too, with version suffixes as commmonly seen in maven).

It would be highly desriable if a a change of configuration to specify two scala versions would not require any changes from the user. In other words, the default behavior would be to build everything against all versions and use arguments to reduce targets, not require them to increase them. At this point, that may not be feasible though close approximation probably are. See below

So in the example above, with two scala versions configured, a build would create, for example,  `lib_2_11.jar`, `lib_2_12.jar`, `app_2_11.jar` and `app_2_12.jar`. The mutliscala code will create the versioned targets based on the version deps. (This is a simplified example. As mentioned, I think we'll end up creating one jar for every version and then a set of aliases to give people the names that they expect.)

To do this, we'd need to change `scala_library` from a rule to a macro. The macro has access to the configuration (which is why it's an external repo) and can instantiate the necessary targets and aliases.

I do wonder if folks will consider this _too magic_. I can say that the developers I work with would prefer this to manual copying or having to write a starlark loop themselves for every target.

## Challenges to supporting multiscala without build file changes

The primary challenge here is `deps` and `runtime_deps` (and anything else of that ilk). In the example above, version-specific jars of `app` need to depend on the version-specific jars of `lib`. At this point, I don't see any way to do this with a `scala_binary` macro: information about the depended-on target isn't available during loading and it's too late to make dependence changes at analysis.

So far, the only thing I've come up with is to add `scala_deps` and `scala_runtime_deps` arguments to the `scala_*` macros. The macros can then add the necessary version information to the labels before combining them with the standard, unaltered sets (`deps`, `runtime_deps`) and then running the standard rule to create a target. So to migrate, a user would have to move existing dependencies that need automatic scala version naming to `scala_deps`, leaving non-versioned (java) deps in `deps`. It would be easy enough to add compatibility no-op shims to allow people to future proof while still sticking with stable code though correctness would not be checked.

## Using defaults and aliases

When declaring something like the library `lib` above, one can imagine many ways `lib` will be named. In the uniscala mode, this would simply be `lib.jar`. Using the standard scala pattern, one would expect something like `lib_2_12.jar` and `lib_2_11.jar`.

If we support concurrent minor builds, we can imagine
```
lib_2_11_10.jar
lib_2_11_12.jar
lib_2_12_10.jar
lib_2_13_1.jar
```
This could break build environments that ran the multiscala build (for test purposes) but still expected a uniscala-like target, i.e., `lib.jar`.

The proposed model is that users can optionally configure/ask for defaults. Based on that default, aliases are created that remove version information from names. This could be both a global default but also could be done for each major version.

So in the example above if we configured a 2.11 default of 12, a 2.12 default of 10, and a global default of 2.12, we would expect
```
lib_2_11_10.jar
lib_2_11_12.jar
lib_2_11.jar
lib_2_12_10.jar
lib_2_12.jar
lib_2_13_1.jar
lib.jar
```
We might want a `lib_2.jar` as well, just to be complete.

Defaults are explicit unless there's only one option, e.g., 2.12.10, above in which case they're implicit. They can be explicitly inhibited with a value of None.

One thing I noted and I'm not sure about is that AFAICT, bazel implements aliases with copies. That means keeping unneeded aliases takes disk space. Not sure if this is an issue ...
