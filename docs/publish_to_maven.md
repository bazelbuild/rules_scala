# Publish your Scala Libraries to a Maven Repository

## 1. add a dependency on bazel-distribution repo from graknlabs

```py
git_repository(
    name = "graknlabs_bazel_distribution",
    remote = "https://github.com/graknlabs/bazel-distribution",
    commit = "e181add439dc1cfb7b1c27db771ec741d5dd43e6"
)
```

## 2. add aggregate targets

for each artifact you want to publish to maven central,
create an aggregate `scala_library` target that includes sources for all finer-grained targets (if you have
targets with coarse-grained granularity you can skip this step)

```py
scala_library(
    name = "greyhound-core",
    srcs = [
        "//core/src/main/scala/com/wixpress/dst/greyhound/core:sources",
        "//core/src/main/scala/com/wixpress/dst/greyhound/core/admin:sources",
        "//core/src/main/scala/com/wixpress/dst/greyhound/core/consumer:sources",
        "//core/src/main/scala/com/wixpress/dst/greyhound/core/metrics:sources",
        "//core/src/main/scala/com/wixpress/dst/greyhound/core/producer:sources",
    ],
    tags = ["maven_coordinates=com.wix:greyhound-core_2.12:{pom_version}"],
    visibility = ["//:__subpackages__"],
    deps = [
        "@dev_zio_zio_2_12",
        "@org_apache_kafka_kafka_clients",
        "@org_slf4j_slf4j_api",
    ],
)
```

### A few notes

1. All the labels in srcs are actually filegroup with appropriate visibility settings that allow out-of-package dependency:

    ```py
    filegroup(
       name = "sources",
       srcs = glob(["*.java"]) + glob(["*.scala"]),
       visibility = ["//core:__subpackages__"],
    )
    ```

2. There is a special `maven_coordinates` tag that helps the `assemble_maven` rule to fill-in details in the pom file.

3. You also have to add a `maven_coordinates` tag to the 3rd party dependencies (such as `dev_zio_zio_2_12` in the deps attribute of the example above) so that they will appear as dependencies in the pom file.

## 3. Add `assemble_maven` target

Add assemble_maven target for each artifact you want to publish.
It will create all the necessary files for your artifact, including main jar, source jar and pom file. Enter all project details for the pom file.

```py
load("@graknlabs_bazel_distribution//maven/templates:rules.bzl", "deploy_maven", "assemble_maven")

assemble_maven(
    name = "assemble-maven",
    target = "//core:greyhound-core",
    package = "{maven_packages}",
    project_name = "Greyhound Core",
    project_description = "Greyhound - Rich Kafka Client with ZIO API",
    project_url = "https://github.com/wix/greyhound",
    scm_url = "https://github.com/wix/greyhound.git",
    version_file = "//central-sync:VERSION",
    developers = {"1": ["name=Natan Silnitsky", "email=n...@w...m", "organization=Wix"]},
    license = "mit"
)
```

Notes:

1. For the target attribute you should put the label for the `scala_library` target you created in the previous step with all the relevant sources.
2. Make sure the `project_name` and `project_description` are unique for each of these targets/artifacts
3. The `VERSION` file just contains the SEMVER, e.g. 1.0.0
4. Currently supported licenses include `apache` and `MIT`

## 4. Add deploy_maven target

Add `deploy_maven` target for each artifact you want to publish.
The `deployment.properties` file should contain the url for the sonatype stating area:

```txt
repo.maven.release=https://oss.sonatype.org/service/local/staging/deploy/maven2/
```

## 5. Build the assemble_maven target

Build the assemble_maven target and review the generated pom file and jar file in the bazel-bin directory. Change the targets configuration as needed.

For more specific information, see [How to publish artifacts from Bazel to Maven Central](https://medium.com/wix-engineering/how-to-publish-artifacts-from-bazel-to-maven-central-71da0cf990f5).
