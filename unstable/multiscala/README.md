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

A change of configuration to specify two scala versions would not require any changes from the user. In other words, the default behavior would be to build everything against all versions and use arguments to reduce targets, not require them to increase them.

So in the example above, with two scala versions configured, a build would create, for example,  `lib_2_11.jar`, `lib_2_12.jar`, `app_2_11.jar` and `app_2_12.jar`. The mutliscala code will create the versioned targets based on the version deps. (This is a simplified example. As mentioned, I think we'll end up creating one jar for every version and then a set of aliases to give people the names that they expect.)

To do this, we'd need to change `scala_library` from a rule to a macro. The macro has access to the configuration (which is why it's an external repo) and can instantiate the necessary targets and aliases.

I do wonder if folks will consider this _too magic_. I can say that the developers I work with would prefer this to manual copying or having to write a starlark loop themselves for every target.

## External Repos

See [External Repositories](ExternalReposistories.md)
