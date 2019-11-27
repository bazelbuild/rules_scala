# Customizable Phase

## Overview
Phases increase configurability.

## Who needs customizable phases
Customizable phases is an advanced feature for people who want the rules to do more.

If you don't need to customize your rules and just need the default setup to work correctly, then just load the following file for default rules:
```
load("@io_bazel_rules_scala//scala:scala.bzl")
```
You may skip the rest of the documentation.

## As a Consumer
You need to load the following two files:
```
load("@io_bazel_rules_scala//scala:advanced_usage/providers.bzl", _ScalaRulePhase = "ScalaRulePhase")
load("@io_bazel_rules_scala//scala:advanced_usage/scala.bzl")
```

## As a Contributor
These are the relevant files
 - `scala/private/phases/api.bzl`
 - `scala/private/phases/phases.bzl`
