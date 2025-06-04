# Development helper scripts

## [`create_repository.py`](./create_repository.py)

Creates and updates `scala_x_x.bzl` files in
[`//third_party/repositories`](../third_party/repositories) that list toolchain
dependency Maven artifacts.

It uses [https://get-coursier.io/docs/](coursier) to **resolve** the transitive
dependencies of root artifacts and **fetch** their JARs.

The script will not update any entry that:

- already matches the version resolved by `cs` (executed by
    `ArtifactResolver._fetch_artifact_data()`)
- has `"testonly": True` set
- has a version newer than the resolved version

In other words, if the script doesn't see a need to update the artifact version,
it won't change it (the "if it ain't broke" principle).

When it does update an artifact's entry, it will also set its `deps` field
accordingly, even if it didn't have one before.

### Requirements

Install [Coursier](https://get-coursier.io/) and
[Python 3](https://www.python.org/downloads/) before running the script.

### Usage

Update the `ROOT_SCALA_VERSIONS` or other root artifact version constants at the top of the file, then run:

```txt
./scripts/create_repository.py
```

You can also run it for a specific Scala version, or generate files in a
different directory:

```txt
$ usage: create_repository.py [-h] [--version SCALA_VERSION]
                            [--output_dir OUTPUT_DIR]

Creates or updates repository configuration files for different Scala
versions.

options:
  -h, --help            show this help message and exit
  --version SCALA_VERSION
                        Scala version for which to update repository
                        information; if not provided, updates all supported
                        versions: 2.11.12, 2.12.20, 2.13.16, 3.1.3, 3.2.2,
                        3.3.6, 3.4.3, 3.5.2, 3.6.4, 3.7.1
  --output_dir OUTPUT_DIR
                        Directory in which to generate or update repository
                        files (default: .../third_party/repositories)
```

To **update** the `scala_3_4.bzl` file:

```py
ROOT_SCALA_VERSIONS = [
    "2.11.12",
    "2.12.19",
    "2.13.14",
    "3.1.3",
    "3.2.2",
    "3.3.3",
    "3.4.4",  # <- updated version
    "3.5.0"
    "3.6.0"
]
```

To **create** a new `scala_3_7.bzl` file:

```py
ROOT_SCALA_VERSIONS = [
    "2.11.12",
    "2.12.19",
    "2.13.14",
    "3.1.3",
    "3.2.2",
    "3.3.3",
    "3.4.3",
    "3.5.0",
    "3.6.0",
    "3.7.0",  # <- new version
]
```

There are other variables after `ROOT_SCALA_VERSIONS` for the root artifacts
used to resolve all dependencies.

If you need to add a new root artifact, or add constraints to existing ones,
edit the `select_root_artifacts()` function accordingly.

### `testonly` artifacts

Artifacts marked as "testonly" are manually updated. The script will not change them.

### Update an existing entry without changing its version

To force an update of an artifact, while keeping its same version, remove its
existing entry from the `third_party/repositories/scala_*.bzl` file, and the
script will add it back. Alternatively, artificially set the entry to reference
an older artifact version.

## [`sync_bazelversion.sh`](./sync-bazelversion.sh)

Synchronizes all of the `.bazelversion` files in the project with the top level
`.bazelversion`.

The [bazelisk](https://github.com/bazelbuild/bazelisk) wrapper for Bazel uses
`.bazelversion` files select a Bazel version. While `USE_BAZEL_VERSION` can
also override the Bazel version, keeping the `.bazelversion` files synchronized
helps avoid suprises when not using `USE_BAZEL_VERSION`.

## [`update_protoc_integrity.py`](./update_protoc_integrity.py)

Updates `protoc/private/protoc_integrity.bzl`.

Upon a new release of
[`protocolbuffers/protobuf`](https://github.com/protocolbuffers/protobuf/releases)
add the new version to the `PROTOC_VERSIONS` at the top of this file and run it.
