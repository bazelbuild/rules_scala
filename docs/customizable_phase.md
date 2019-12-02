# Customizable Phase

## Contents
*  [Overview](#overview)
*  [Who needs customizable phase?](#who-needs-customizable-phase?)
*  [As a consumer](#as-a-consumer)
*  [As a contributor](#as-a-contributor)
   *  [Phase naming convention](#phase-naming-convention)

## Overview
Phases increase configurability. Rule implementations are defined as a list of phases. Each phase defines a specific step, which helps breaking up implementation into smaller and more readable groups. Some phases are independent from others, which means the order doesn't matter. However, some phases depend on outputs of previous phases, in this case, we should make sure it meets all the prerequisites before executing phases.

The biggest benefit of phases is that it is customizable. If default phase A is not doing what you expect, you may switch it with your self-defined phase A. One use case is to write your own compilation phase with your favorite Scala compiler. You may also extend the default phase list for more functionalities. One use case is to check the Scala format.

## Who needs customizable phase?
Customizable phase is an advanced feature for people who want the rules to do more. If you are an experienced Bazel rules developer, we make this powerful API public for you to do custom work without impacting other consumers. If you have no experience on writing Bazel rules, we are happy to help but be aware it may be frucstrating at first.

If you don't need to customize your rules and just need the default setup to work correctly, then just load the following file for default rules:
```
load("@io_bazel_rules_scala//scala:scala.bzl")
```

## As a consumer
You need to load the following 2 files:
```
load("@io_bazel_rules_scala//scala:advanced_usage/providers.bzl", "ScalaRulePhase")
load("@io_bazel_rules_scala//scala:advanced_usage/scala.bzl", "make_scala_binary")
```
`ScalaRulePhase` is a phase provider to pass in custom phases. Rules with `make_` prefix, like `make_scala_binary`, are customizable rules. `make_<RULE_NAME>`s take a dictionary as input. It currently supports appending `attrs` and `outputs` to default rules, as well as modifying the phase list.

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

custom_scala_binary = make_scala_binary(ext_add_custom_phase)
```
`make_<RULE_NAME>`s append `attrs` and `outputs` to the default rule definitions. All items in `attrs` can be accessed by `ctx.attr`, and all items in `outputs` can be accessed by `ctx.outputs`. `phase_providers` takes a list of targets which define how you want to modify phase list.
```
def _add_custom_phase_singleton_implementation(ctx):
    return [
        ScalaRulePhase(
            custom_phases = [
                ("last", "", "custom_write_extra_file", phase_custom_write_extra_file),
            ],
        ),
    ]

add_custom_phase_singleton = rule(
    implementation = _add_custom_phase_singleton_implementation,
)
```
`add_custom_phase_singleton` is a rule solely to pass in custom phases using `ScalaRulePhase`. The `custom_phases` field in `ScalaRulePhase` takes a list of tuples. Each tuple has 4 elements:
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

You should be able to define the files above entirely in your own workspace without making change to the [bazelbuild/rules_scala](https://github.com/bazelbuild/rules_scala). If you believe your custom phase will be valuable to the community, please refer to [As a contributor](#as-a-contributor). Pull requests are welcome.

## As a contributor
Besides the basics in [As a consumer](#as-a-consumer), the followings help you understand how phases are setup if you plan to contribute to [bazelbuild/rules_scala](https://github.com/bazelbuild/rules_scala).

These are the relevant files
 - `scala/private/phases/api.bzl`: the API of executing and modifying the phase list
 - `scala/private/phases/phases.bzl`: re-expose phases for convenience
 - `scala/private/phases/phase_<PHASE_NAME>.bzl`: all the phase definitions

Currently phase architecture is used by 7 rules:
 - scala_library
 - scala_macro_library
 - scala_library_for_plugin_bootstrapping
 - scala_binary
 - scala_test
 - scala_junit_test
 - scala_repl

In each of the rule implementation, it calls `run_phases` and returns the information from `phase_final`, which groups the final returns of the rule. To prevent consumers from accidently removing `phase_final` from the list, we make it a non-customizable phase.

To make a new phase, you have to define a new `phase_<PHASE_NAME>.bzl` in `scala/private/phases/`. Function definition should have 2 arguments, `ctx` and `p`. You may expose the information for later phases by returning a `struct`. In some phases, there are multiple phase functions since different rules may take slightly different input arguemnts. You may want to re-expose the phase definition in `scala/private/phases/phases.bzl`, so it's more convenient to access in rule files.

In the rule implementations, put your new phase in `builtin_customizable_phases` list. The phases are executed sequentially, the order matters if the new phase depends on previous phases.

If you are making new return fields of the rule, remember to modify `phase_final`.

### Phase naming convention
Files in `scala/private/phases/`
 - `phase_<PHASE_NAME>.bzl`: phase definition file

Function names in `phase_<PHASE_NAME>.bzl`
 - `phase_<RULE_NAME>_<PHASE_NAME>`: function with custom inputs of specific rule
 - `phase_common_<PHASE_NAME>`: function without custom inputs
 - `_phase_default_<PHASE_NAME>`: private function that takes `_args` for custom inputs
 - `_phase_<PHASE_NAME>`: private function with the actual logic

See [phase_compile](scala/private/phases/phase_compile.bzl) for example.
