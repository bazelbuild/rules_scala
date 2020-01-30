# Phase Scalafmt

## Contents
*  [Overview](#overview)
*  [How to set up](#how-to-set-up)

## Overview
A phase extension `phase_scalafmt` can format Scala source code via [Scalafmt](https://scalameta.org/scalafmt/).

## How to set up
Add this snippet to `WORKSPACE`
```
load("//scala/scalafmt:scalafmt_repositories.bzl", "scalafmt_default_config", "scalafmt_repositories")
scalafmt_default_config()
scalafmt_repositories()
```

To add this phase to a rule, you have to pass the extension to a rule macro. Take `scala_binary` for example,
```
load("//scala:advanced_usage/scala.bzl", "make_scala_binary")
load("//scala/scalafmt:phase_scalafmt_ext.bzl", "ext_scalafmt")

scalafmt_scala_binary = make_scala_binary(ext_scalafmt)
```
Then use `scalafmt_scala_binary` as normal.

The extension adds 2 additional attributes to the rule
 - `format`: enable formatting
 - `config`: the Scalafmt configuration file

When `format` is set to `true`, you can do
```
bazel run <TARGET>.format
```
to format the source code, and do
```
bazel run <TARGET>.format-test
```
to check the format (without modifying source code).

The extension provides default configuration, but there are 2 ways to use custom configuration
 - Put `.scalafmt.conf` at root of your workspace
 - Pass `.scalafmt.conf` in via `config` attribute
