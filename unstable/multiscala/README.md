# This is a very early work-in-progress.

It is not only not stable, it's not complete. All the documentation here is as much or more about collaborating on the design as it is on documenting the behavior. In other words, it's highly likely that the behavior does not yet match the documentation.

## example

In `private/example`

## Configuration

Is currently via a dict of dicts, lists, strings and booleans. It's not yet documented but there is an example in the example `WORKSPACE`. The feeling is that this is ripe for refactoring. There's been a request to support multiple minor version for the same major version which wouldn't be very hard. Other things to be considered is do we use helpers to construct this rather than core types. This would be less error prone. Also, it's possible structs might be preferable to dicts since it might make code more succinct and less error prone.

## Creating targets

I would like to make the use of multiscala easy ("make easy things simple and hard things possible")

One goal would be that

```
scala_library(
   name = "foo",
   ...
)
```
Would act with the current default configuration just as it does today: it would create a single jar, `foo_.jar`.

A change of configuration to specify two scala versions would not require any changes from the user. In other words, the default behavior is to build everything against all versions and use argument to reduce targets, not to increase them.

So in the example above, with two scala versions configured, a build would create, for example,  `foo_2_11.jar` and `foo_2_12.jar`. (This is a simplified example. I think we'll end up creating one jar for every version and then a set of aliases to give people the names that they expect.)

To do this, we'd need to change `scala_library` from a rule to a macro. The macro has access to the configuration (which is why it's an external repo) and can instantiate the necessary targets and aliases.

I do wonder if folks will consider this _too magic_. I can say that the developers I work with would prefer this to manual copying or having to write a starlark loop themselves for every target.
