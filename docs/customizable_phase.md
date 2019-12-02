# Customizable Phase

## Overview
Phases increase configurability. Rule implementations are defined as a list of phases. Each phase defines a specific step, which helps breaking up implementation into smaller and more readable groups. Some phases are independent from others, which means the order doesn't matter. However, some phases depend on outputs of previous phases, in this case, we should make sure it meets all the prerequisites before executing phases.

The biggest benefit of phases is that it is customizable. If default phase A is not doing what you expect, you may switch it with your self-defined phase A. One use case is to write your own compilation phase with your favorite Scala compiler. You may also extend the default phase list for more functionality. One use case is to check the Scala format.

## Who needs customizable phases
Customizable phases is an advanced feature for people who want the rules to do more. If you are an experienced Bazel rules developer, we make this powerful API public for you to do custom work without impacting other users. If you have no experience on writing Bazel rules, we are happy to help but be aware it may be frucstrating at first.

If you don't need to customize your rules and just need the default setup to work correctly, then just load the following file for default rules:
```
load("@io_bazel_rules_scala//scala:scala.bzl")
```

## As a Consumer
You need to load the following 2 files:
```
load("@io_bazel_rules_scala//scala:advanced_usage/providers.bzl", _ScalaRulePhase = "ScalaRulePhase")
load("@io_bazel_rules_scala//scala:advanced_usage/scala.bzl", _make_scala_binary = "make_scala_binary")
```
`ScalaRulePhase` is a phase provider to pass in custom phase. Rules with `make_` prefix, like `make_scala_binary`, are customizable rules. `make_<RULES>`s take a dictionary as input. It currently supports appending `attrs` and `outputs` to default rules, as well as modifying the phase list.

For example:
```
ext_add_custom_phase = {
    "attrs": {
        "custom_content": attr.string(
            default = "This is custom content",
        ),
    },
    "outputs": {
        "custom_output": "%{name}.custom-output",
    },
    "phase_providers": [
        "//custom/phase:phase_custom_write_extra_file",
    ],
}

custom_scala_binary = _make_scala_binary(ext_add_custom_phase)
```
The usage of `attrs` and `outputs` is straight forward. `make_<RULES>`s append these 2 fields to the default rules definition. All items in `attrs` can be accessed by `ctx.attr`, and all items in `outputs` can be accessed by `ctx.outputs`. `phase_providers` takes a list of targets which define how do you want to modify phase list.
```
def _add_custom_phase_singleton_implementation(ctx):
    return [
        _ScalaRulePhase(
            custom_phases = [
                ("last", "", "custom_write_extra_file", phase_custom_write_extra_file),
            ],
        ),
    ]

add_custom_phase_singleton = rule(
    implementation = _add_custom_phase_singleton_implementation,
)
```
`add_custom_phase_singleton` is a simple rule solely to pass in custom phases using `_ScalaRulePhase`. The `custom_phases` field in `_ScalaRulePhase` take a list of tuples. Each tuple has 4 elements:
```
(relation, peer_name, phase_name, phase_function)
```
 - relation: the position to add a new phase
 - peer_name: the existing phase to compare the position with
 - phase_name: the name of the new phase, also used to access phase information
 - phase_function: the function of the new phase

There are 5 possible relations:
 - `^` or `first`
 - `$` or `last`
 - `-` or `before`
 - `+` or `after`
 - `=` or `replace`

The symbols and words are interchangable. If `first` or `last` is used, it puts your custom phase at the beginning or the end of the phase list, `peer_name` is not needed.

Then you have to call the rule in a `BUILD`
```
add_custom_phase_singleton(
    name = "phase_custom_write_extra_file",
    visibility = ["//visibility:public"],
)
```

You may now see `phase_providers` in `ext_add_custom_phase` is pointing to this target.

The last step is to write the function of the phase. For example:
```
def phase_custom_write_extra_file(ctx, p):
    ctx.actions.write(
        output = ctx.outputs.custom_output,
        content = ctx.attr.custom_content,
    )
```
Every phase has 2 arguments, `ctx` and `p`. `ctx` gives you access to the fields defined in rules. `p` is the global provider, which contains information from initial state as well as all the previous phases. You may access the information from previous phases by `p.<PHASE_NAME>.<FIELD_NAME>`. For example, if the previous phase, said `phase_jar` with phase name `jar`, returns a struct
```
def phase_jar(ctx, p):
    # Some works to get the jars
    return struct(
        class_jar = class_jar,
        ijar = ijar,
    )
```
You are able to access information like `p.jar.class_jar` in `phase_custom_write_extra_file`. You can provide the information for later phases in the same way, then they can access it by `p.custom_write_extra_file.<FIELD_NAME>`.

## As a Contributor
These are the relevant files
 - `scala/private/phases/api.bzl`
 - `scala/private/phases/phases.bzl`
