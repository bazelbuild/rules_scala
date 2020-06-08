load("@io_bazel_rules_scala//twitter_scrooge:twitter_scrooge.bzl", "twitter_scrooge", "defaulted_twitter_scrooge_dependency")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "extract_major_version")

def twitter_scrooge_with_custom_dep_version(twitter_scrooge_deps_version, scala_version, version_shas):
  scala_major_version = extract_major_version(scala_version)

  scrooge_core_label = defaulted_twitter_scrooge_dependency(
    "scrooge-core",
    twitter_scrooge_deps_version,
    version_shas[twitter_scrooge_deps_version]["scrooge-core"],
    scala_major_version,
  )
  scrooge_generator_label = defaulted_twitter_scrooge_dependency(
    "scrooge-generator",
    twitter_scrooge_deps_version,
    version_shas[twitter_scrooge_deps_version]["scrooge-generator"],
    scala_major_version,
  )
  util_core_label = defaulted_twitter_scrooge_dependency(
    "util-core",
    twitter_scrooge_deps_version,
    version_shas[twitter_scrooge_deps_version]["util-core"],
    scala_major_version,
  )
  util_logging_label = defaulted_twitter_scrooge_dependency(
    "util-logging",
    twitter_scrooge_deps_version,
    version_shas[twitter_scrooge_deps_version]["util-logging"],
    scala_major_version,
  )
  twitter_scrooge(
    scala_version,
    scrooge_core=scrooge_core_label,
    scrooge_generator=scrooge_generator_label,
    util_core=util_core_label,
    util_logging=util_logging_label,
  )