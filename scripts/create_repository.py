#!/usr/bin/env python3
"""Updates jar versions in third_party/repositories/scala_*.bzl files"""

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Self

import argparse
import ast
import hashlib
import json
import re
import shutil
import subprocess
import sys

ROOT_SCALA_VERSIONS = [
    "2.11.12",
    "2.12.20",
    "2.13.16",
    "3.1.3",
    "3.2.2",
    "3.3.5",
    "3.4.3",
    "3.5.2",
    "3.6.4"
]
PARSER_COMBINATORS_VERSION = '1.1.2'
SBT_COMPILER_INTERFACE_VERSION = '1.10.8'
SBT_UTIL_INTERFACE_VERSION = '1.10.11'
SCALATEST_VERSION = "3.2.19"
SCALAFMT_VERSION = "3.9.6"
KIND_PROJECTOR_VERSION = "0.13.3"
PROTOBUF_JAVA_VERSION = "4.30.2"
JLINE_VERSION = '3.29.0'
SCALAPB_VERSION = '1.0.0-alpha.1'
PROTOC_BRIDGE_VERSION = '0.9.8'
GRPC_VERSION = '1.72.0'
GRPC_COMMON_PROTOS_VERSION = '2.55.3'
GRPC_LIBS = ['netty', 'protobuf', 'stub']
GUAVA_VERSION = '33.4.8-jre'

# This should include values corresponding to `MavenCoordinates.artifact_name`,
# i.e., group:artifact after stripping any Scala version suffix from artifact.
EXCLUDED_ARTIFACTS = set(["com.google.guava:listenablefuture"])

THIS_FILE = Path(__file__)
REPO_ROOT = THIS_FILE.parent.parent
OUTPUT_DIR = REPO_ROOT / 'third_party' / 'repositories'
THIS_FILE_RELATIVE_TO_REPO_ROOT = THIS_FILE.relative_to(REPO_ROOT)
DOWNLOADED_ARTIFACTS_FILE = 'repository-artifacts.json'


def select_root_artifacts(scala_version, scala_major, is_scala_3) -> List[str]:
    """Returns the list of artifacts to resolve and potentially update.

    Edit this function to add more root artifacts to automatically resolve and
    update. Add a version constant to the top of the implementation file to make
    updating versions easier.

    This function could derive the values for the `scala_major` and `is_scala_3`
    args from `scala_version`. However, the caller of this function already
    computes these values, so we pass them through.

    Args:
        scala_version: the version of Scala for which to resolve artifacts
        scala_major: the first two components of scala_version
        is_scala_3: True if scala_version is in the 3.x line, false otherwise

    Returns:
        the list of root artifacts to resolve and potentially update in the
            repository file
    """
    max_scala_2_version = max(
        v for v in ROOT_SCALA_VERSIONS if v.startswith('2.')
    )
    max_scala_2_major = '.'.join(max_scala_2_version.split('.')[:2])
    minor_version = int(scala_version.split('.')[1])

    scala_2_version = scala_version
    scala_2_major = scala_major
    scalapb_major = scala_2_major

    if is_scala_3:
        scala_2_version = max_scala_2_version
        scala_2_major = max_scala_2_major
        scala_major = '3'
        scalapb_major = scala_2_major if minor_version < 3 else scala_major

    # For some reason, com.thesamet.scalapb:compilerplugin_3:0.11.17 depends on
    # com.thesamet.scalapb:protoc-gen_2.13:0.9.7. Trying to use
    # com.thesamet.scalapb:protoc-gen_3:0.9.8 causes a crash, saying:
    # `java.lang.NoClassDefFoundError: Could not initialize class
    # scalapb.ScalaPbCodeGenerator$`, even though that class is definitely in
    # that jar. So we stick with protoc-gen_2.13 for now.
    protoc_bridge_major = scala_2_major

    scalafmt_version = SCALAFMT_VERSION
    scalapb_version = SCALAPB_VERSION
    protoc_bridge_version = PROTOC_BRIDGE_VERSION

    if scala_major == '2.11':
        scalafmt_version = '2.7.5'
        scalapb_version = '0.9.8'
        protoc_bridge_version = '0.7.14'

    root_artifacts = [
        'com.google.api.grpc:proto-google-common-protos:' +
            GRPC_COMMON_PROTOS_VERSION,
        f'com.google.guava:guava:{GUAVA_VERSION}',
        f'com.google.protobuf:protobuf-java:{PROTOBUF_JAVA_VERSION}',
        f'com.thesamet.scalapb:compilerplugin_{scalapb_major}:' +
            scalapb_version,
        f'com.thesamet.scalapb:protoc-bridge_{protoc_bridge_major}:' +
            protoc_bridge_version,
        f'com.thesamet.scalapb:scalapb-runtime_{scalapb_major}:' +
            scalapb_version,
        f'com.thesamet.scalapb:scalapb-runtime-grpc_{scalapb_major}:' +
            scalapb_version,
        f'org.scala-lang.modules:scala-parser-combinators_{scala_2_major}:' +
            PARSER_COMBINATORS_VERSION,
        f'org.scala-lang:scala-compiler:{scala_2_version}',
        f'org.scala-lang:scala-library:{scala_2_version}',
        f'org.scala-lang:scala-reflect:{scala_2_version}',
        f'org.scala-lang:scalap:{scala_2_version}',
        f'org.scalameta:scalafmt-core_{scala_2_major}:{scalafmt_version}',
        f'org.scalatest:scalatest_{scala_major}:{SCALATEST_VERSION}',
        f'org.typelevel:kind-projector_{scala_2_version}:' +
            KIND_PROJECTOR_VERSION,
    ] + [f'io.grpc:grpc-{lib}:{GRPC_VERSION}' for lib in GRPC_LIBS]

    if scala_major != '2.11':
        root_artifacts.append(
            f'com.thesamet.scalapb:protoc-gen_{protoc_bridge_major}:' +
            protoc_bridge_version,
        )

    if scala_version == max_scala_2_version or is_scala_3:
        # Since the Scala 2.13 compiler is included in Scala 3 deps.
        root_artifacts.append('org.jline:jline:' + JLINE_VERSION)

    if is_scala_3:
        root_artifacts.extend([
            f'org.scala-lang:scala3-library_3:{scala_version}',
            f'org.scala-lang:scala3-compiler_3:{scala_version}',
            f'org.scala-lang:scala3-interfaces:{scala_version}',
            f'org.scala-lang:tasty-core_3:{scala_version}',
            'org.scala-sbt:compiler-interface:' +
                SBT_COMPILER_INTERFACE_VERSION,
            f'org.scala-sbt:util-interface:{SBT_UTIL_INTERFACE_VERSION}',
            f'org.jline:jline-reader:{JLINE_VERSION}',
            f'org.jline:jline-terminal:{JLINE_VERSION}',
            f'org.jline:jline-terminal-jna:{JLINE_VERSION}',
            f'org.jline:jline-terminal-jni:{JLINE_VERSION}',
        ])

    else:
        root_artifacts.extend([
            f'org.scalameta:semanticdb-scalac_{scala_version}:4.9.9',
        ])

    return root_artifacts


class CreateRepositoryError(Exception):
    """Errors raised explicitly by this module."""


@dataclass
class MavenCoordinates:
    """Contains the components parsed from a set of Maven coordinates."""
    group: str
    artifact: str
    version: str
    coordinate: str

    # The `artifact` with the Scala version suffix stripped
    unversioned_artifact: str

    # The Scala version suffix stripped from `unversioned_artifact`
    scala_version: str

    # Canonical name for comparing new and existing artifacts
    artifact_name: str

    @staticmethod
    def new(coords) -> Self:
        """Creates a new MavenCoordinates from a Maven coordinate string."""
        # There are Maven artifacts that contain extra components like `:jar` in
        # their coordinates. However, the groupId and artifactId are always the
        # first two components, and the version is the last.
        parts = coords.split(':')
        group, artifact, vers = parts[0], parts[1], parts[-1]

        # Remove any Scala version suffix from what will become the
        # `artifact_name`. This is to avoid consecutive runs of the script
        # flipping between the `_2.x` and `_3` versions of some artifacts.
        #
        # Specifically, there are ScalaPB root artifacts specified by this
        # script that end in `_3` yet still transitively depend on artifacts
        # ending in `_2.13`. However, some of these transitive dependencies are
        # also specified as root artifacts ending in `_3`.
        #
        # Without trimming the version suffix, the script would see the `_3`
        # root artifacts and the `_2.13` transitive dependency artifacts as
        # entirely different. However, their computed repository labels would be
        # the same, causing one version to replace the other on consecutive
        # runs.
        artifact_parts = artifact.rsplit('_', 1)
        scala_version = ''

        if len(artifact_parts) != 1:
            version_suffix = artifact_parts[-1]

            # "Why does `'2.13'.isdecimal()` return `False`, sir?"
            # "Nobody knows."
            # See: https://youtu.be/JYqfVE-fykk (couldn't resist!)
            if version_suffix.split('.')[0].isdigit():
                scala_version = version_suffix
                del artifact_parts[-1]

        unversioned_artifact = '_'.join(artifact_parts)
        artifact_name = f'{group}:{unversioned_artifact}'
        return MavenCoordinates(
            group,
            artifact,
            vers,
            coords,
            unversioned_artifact,
            scala_version,
            artifact_name,
        )

    def is_newer_than(self, other):
        """Determines if this artifact is newer than the other.

        The idea is to prevent downgrades of versions already in the artifacts
        file. If they are later versions, presumably they were updated to that
        version for a good reason.

        Args:
            other: the current artifact coodinates from the repo config file

        Returns:
            True if self.version is newer than other.version, False otherwise

        Raises:
            CreateRepositoryError if other doesn't match self.group and
                self.artifact
        """
        if self.artifact_name != other.artifact_name:
            raise CreateRepositoryError(
                f'Expected {self.group}:{self.artifact}, ' +
                f'got {other.group}:{other.artifact}'
            )
        return self.__compare_versions(other.version, self.version)

    def __compare_versions(self, lhs, rhs):
        lhs_parts = lhs.split('.')
        rhs_parts = rhs.split('.')

        for lhs_part, rhs_part in zip(lhs_parts, rhs_parts):
            if lhs_part == rhs_part:
                continue
            if lhs_part.isdecimal() and rhs_part.isdecimal():
                return int(lhs_part) < int(rhs_part)
            return lhs_part < rhs_part

        return len(lhs_parts) < len(rhs_parts)


@dataclass
class ResolvedArtifact:
    """Coordinates, checksum, and dependencies of a resolved Maven artifact."""
    coordinates: MavenCoordinates
    checksum: str
    direct_dependencies: List[MavenCoordinates]


# pylint: disable=too-few-public-methods
class ArtifactLabelMaker:
    """Creates artifact repository labels."""

    def __init__(self, is_scala_3):
        self._is_scala_3 = is_scala_3
        self._cache = {}

    def get_label(self, coordinates) -> str:
        """Creates a repository label from an artifact's Maven coordinates."""
        coords = coordinates.coordinate

        if coords not in self._cache:
            self._cache[coords] = self._get_label_impl(coordinates)
        return self._cache[coords]

    def _get_label_impl(self, coordinates) -> str:
        group = coordinates.group
        group_label = self._labelize(group)
        artifact_label = self._labelize(coordinates.unversioned_artifact)

        if group in self._SCALA_LANG_GROUPS:
            return self._get_scala_lang_label(artifact_label, coordinates)
        if group in self._ARTIFACT_LABEL_ONLY_GROUPS:
            return f'io_bazel_rules_scala_{artifact_label}'
        if group in self._GROUP_AND_ARTIFACT_LABEL_GROUPS:
            return f'io_bazel_rules_scala_{group_label}_{artifact_label}'
        if group in self._SCALA_PROTO_RULES_GROUPS:
            return self._get_scala_proto_label(artifact_label, coordinates)

        artifact_name = coordinates.artifact_name

        if artifact_name in self._SPECIAL_CASE_ARTIFACT_LABELS:
            return self._SPECIAL_CASE_ARTIFACT_LABELS[artifact_name]
        return f'{group_label}_{artifact_label}'.replace('_v2', '')

    @staticmethod
    def _labelize(s):
        return s.replace('.', '_').replace('-', '_')

    _ARTIFACT_LABEL_ONLY_GROUPS = set([
        "com.google.guava",
        "com.twitter",
        "javax.annotation",
        "org.scalactic",
        "org.scalatest",
    ])

    _GROUP_AND_ARTIFACT_LABEL_GROUPS = set([
        "junit",
        "net.sf.jopt-simple",
        "org.apache.commons",
        "org.hamcrest",
        "org.openjdk.jmh",
        "org.ow2.asm",
        "org.specs2",
    ])

    _SCALA_PROTO_RULES_GROUPS = set([
        "com.google.api.grpc",
        "com.google.instrumentation",
        "com.lmax",
        "com.thesamet.scalapb",
        "dev.dirs.directories",
        "io.grpc",
        "io.netty",
        "io.opencensus",
        "io.perfmark",
    ])

    _SPECIAL_CASE_ARTIFACT_LABELS = {
        "com.github.scopt:scopt": "io_bazel_rules_scala_scopt",
        "com.github.spullara.mustache.java:compiler":
            "io_bazel_rules_scala_mustache",
        "org.apache.thrift:libthrift": "libthrift",
    }

    _SCALA_LANG_GROUPS = set(['org.scala-lang', 'org.scala-lang.modules'])
    _SCALA_2_ARTIFACTS = set([
        'scala-library', 'scala-compiler', 'scala-reflect'
    ])

    def _get_scala_lang_label(self, artifact_label, coordinates):
        artifact = coordinates.artifact
        if artifact == 'scalap':
            return 'org_scala_lang_scalap'
        if artifact.startswith('scala-collection-compat'):
            return 'org_scala_lang_modules_scala_collection_compat'

        label = f'io_bazel_rules_scala_{artifact_label}'

        if self._is_scala_3 and artifact in self._SCALA_2_ARTIFACTS:
            return label + '_2'
        if artifact.startswith('scala3-'):
            return label.replace('scala3_', 'scala_')
        return label.replace('scala_tasty_core', 'scala_scala_tasty_core')

    def _get_scala_proto_label(self, artifact_label, coordinates):
        if (
            coordinates.group == "com.thesamet.scalapb" and
            not artifact_label.startswith("scalapb_")
        ):
            artifact_label = "scalapb_" + artifact_label
        return f'scala_proto_rules_{artifact_label}'


class ArtifactResolver:
    """Resolves root artifacts and their transitive dependencies."""

    def __init__(self, downloaded_artifacts_file):
        self._downloaded_artifacts_file = downloaded_artifacts_file
        self._artifact_cache = {}

    def resolve_artifacts(
        self, root_artifacts, current_artifacts
    ) -> List[ResolvedArtifact]:
        """Resolves a list of Maven artifacts as a list of `ResolvedArtifact`s.

        The returned list will not contain `ResolvedArtifact`s that are older
        versions than those present in `current_artifacts`.

        Args:
            root_artifacts: the Maven coordinates of artifacts to resolve
            current_artifacts: the current artifact repository dictionary

        Returns:
            a list of `ResolvedArtifact` objects representing the most up to
                date versions of the `root_artifacts` and their dependencies
        """
        artifacts_data = self._fetch_artifacts_data(root_artifacts)
        current_artifacts_map = self._create_current_artifacts_map(
            current_artifacts
        )
        resolved = []

        for artifact in artifacts_data['dependencies']:
            coords = MavenCoordinates.new(artifact['coord'])
            current = current_artifacts_map.get(coords.artifact_name)

            if coords.artifact_name in EXCLUDED_ARTIFACTS:
                continue

            if current is None or coords.is_newer_than(current.coordinates):
                print(f'  {artifact['coord']}')
                checksum, deps = self._get_artifact_metadata(artifact)
                resolved.append(ResolvedArtifact(coords, checksum, deps))

        return resolved

    def _fetch_artifacts_data(self, root_artifacts):
        try:
            artifacts_file = Path(self._downloaded_artifacts_file)
            command = (
                f'cs fetch {' '.join(root_artifacts)} --json-output-file ' +
                self._downloaded_artifacts_file
            )
            self._run_command(command, 'Fetching resolved artifacts')

            with open(artifacts_file, 'r', encoding='utf-8') as f:
                return json.load(f)

        finally:
            if artifacts_file.exists():
                artifacts_file.unlink()

    @staticmethod
    def _create_current_artifacts_map(original_artifacts):
        result = {}

        for metadata in original_artifacts.values():
            coordinates = MavenCoordinates.new(metadata['artifact'])
            name = coordinates.artifact_name

            if name not in result and metadata.get('testonly') is not True:
                result[name] = ResolvedArtifact(
                    coordinates, metadata['sha256'], metadata.get('deps', [])
                )

        return result

    def _get_artifact_metadata(self, artifact) -> str:
        metadata = self._artifact_cache.setdefault(artifact['coord'], {})

        if not metadata:
            deps = [
                MavenCoordinates.new(d) for d in artifact['directDependencies']
            ]
            metadata['deps'] = [
                d for d in deps if d.artifact_name not in EXCLUDED_ARTIFACTS
            ]
            with open(artifact['file'], 'rb') as f:
                metadata['checksum'] = hashlib.sha256(f.read()).hexdigest()

        return metadata['checksum'], metadata['deps']

    @staticmethod
    def _run_command(command, description):
        """Runs a command and emits its output only on error.

        Args:
            command: the shell command to run
            description: prefixed to the error message on failure

        Returns:
            the CompletedProcess object on success, None on error

        Raises:
            CreateRepositoryError if the command fails
        """
        try:
            return subprocess.run(
                command, capture_output=True, text=True, shell=True, check=True
            )

        except subprocess.CalledProcessError as err:
            err_msg = "\n".join([
                f'{description} failed for command: {err.cmd}',
                err.stderr
            ])
            raise CreateRepositoryError(err_msg) from err


class ArtifactUpdater:
    """Resolves Maven artifacts and updates repository dictionary files."""

    def __init__(self, artifact_resolver, output_dir_path):
        self._resolver = artifact_resolver
        self._output_dir = output_dir_path

    def create_or_update_repository_file(self, scala_version):
        """Creates or updates the artifact repository file for `scala_version`.

        Args:
            scala_version: the version of Scala for which to update its artifact
                repository file
        """
        version_parts = scala_version.split('.')[:2]
        is_scala_3 = scala_version.startswith('3.')

        file_path = self._output_dir / f'scala_{'_'.join(version_parts)}.bzl'
        print('\nUPDATING:', file_path)

        labeler = ArtifactLabelMaker(is_scala_3)
        original_artifacts = self._get_original_artifacts(file_path, labeler)
        resolved_artifacts = self._to_rules_scala_compatible_dict(
            self._resolver.resolve_artifacts(
                select_root_artifacts(
                    scala_version, '.'.join(version_parts), is_scala_3
                ),
                original_artifacts
            ),
            labeler,
        )
        self._update_artifacts(original_artifacts, resolved_artifacts)
        self._write_to_file(original_artifacts, scala_version, file_path)

    def _get_original_artifacts(self, file_path, labeler):
        self._copy_previous_version_or_create_new_file(file_path)

        with file_path.open('r', encoding='utf-8') as data:
            read_data = data.read()

        artifacts = ast.literal_eval(read_data[read_data.find('{'):])
        return self._update_artifact_labels(artifacts, labeler)

    def _copy_previous_version_or_create_new_file(self, file_path):
        if file_path.exists():
            return

        existing_files = sorted(self._output_dir.glob('scala_*.bzl'))
        if existing_files:
            shutil.copyfile(existing_files[-1], file_path)
            return

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write('{}\n')

    @staticmethod
    def _update_artifact_labels(artifacts, labeler):
        """Transforms existing artifact labels to ensure consistency.

        Specifically, this function ensures consistency when running
        `ArtifactLabelMaker.get_label` on existing artifact metadata for the
        first time, and whenever that function changes thereafter.

        Artifacts appearing under different labels will be merged into a single
        entry, keeping the metadata from the newest version.

        It will also remove any entries for `EXCLUDED_ARTIFACTS` and any `deps`
        labels for such artifacts appearing in other artifact entries.

        Entries marked as `testonly` remain unchanged.

        Args:
            artifacts: a dictionary of repository labels to Maven artifact
                repository metadata
            labeler: an `ArtifactLabelMaker` instance configured for the current
                Scala version

        Returns:
            the dictionary of repository labels to Maven artifact repository
                metadata with any repository labels updated as needed
        """
        result = {}
        updated_labels = {}

        for existing_label, metadata in artifacts.items():
            coords = MavenCoordinates.new(metadata['artifact'])

            if coords.artifact_name in EXCLUDED_ARTIFACTS:
                continue

            label = (
                labeler.get_label(coords) if not metadata.get('testonly')
                else existing_label
            )

            if label in result:
                # If we originally have multiple versions of the same artifact
                # keyed by different repository labels, keep the newer version's
                # metadata entry.
                other_metadata = result[label]
                other_coords = MavenCoordinates.new(other_metadata['artifact'])
                metadata = (
                    metadata if coords.is_newer_than(other_coords)
                    else other_metadata
                )

            # We'll use `updated_labels` to update `deps` labels and filter out
            # stale labels belonging to `EXCLUDED_ARTIFACTS` in the next loop.
            updated_labels['@' + existing_label] = '@' + label
            result[label] = metadata

        for metadata in result.values():
            deps = [
                updated_labels[d] for d in metadata.get('deps', [])
                if d in updated_labels
            ]

            if deps:
                metadata['deps'] = deps
            elif 'deps' in metadata:
                del metadata['deps']

        return result

    @staticmethod
    def _to_rules_scala_compatible_dict(artifacts, labeler) -> Dict[str, Dict]:
        result = {}

        for a in artifacts:
            coordinates = a.coordinates
            result[labeler.get_label(coordinates)] = {
                "artifact": f"{coordinates.coordinate}",
                "sha256": f"{a.checksum}",
                "deps": sorted([
                    f'@{labeler.get_label(d)}' for d in a.direct_dependencies
                ]),
            }

        return result

    @staticmethod
    def _update_artifacts(original_artifacts, resolved_artifacts):
        for label, resolved_metadata in resolved_artifacts.items():
            metadata = original_artifacts.setdefault(label, {})
            metadata['artifact'] = resolved_metadata['artifact']
            metadata['sha256'] = resolved_metadata['sha256']
            dependencies = resolved_metadata['deps']

            if dependencies:
                metadata['deps'] = dependencies
            if 'testonly' in metadata:
                del metadata['testonly']

    @staticmethod
    def _write_to_file(artifact_dict, scala_version, file):
        artifacts = (
            json.dumps(dict(sorted(artifact_dict.items())), indent=4)
                .replace('true', 'True')
                .replace('false', 'False')
        )
        # Add trailing commas.
        artifacts = re.sub(r'([]}"])\n', r'\1,\n', artifacts) + '\n'

        with file.open('w', encoding='utf-8') as data:
            data.write('\n'.join([
                '"""Maven artifact repository metadata.\n',
                'Mostly generated and updated by ' +
                f'{THIS_FILE_RELATIVE_TO_REPO_ROOT}.',
                '"""\n',
                f'scala_version = "{scala_version}"\n',
                'artifacts = ',
            ]))
            data.write(artifacts)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(
            'Creates or updates repository configuration files ' +
            'for different Scala versions.'
        )
    )
    parser.add_argument(
        '--version',
        type=str,
        choices=ROOT_SCALA_VERSIONS,
        metavar='SCALA_VERSION',
        help=(
            'Scala version for which to update repository information; ' +
            'if not provided, updates all supported versions: ' +
            ', '.join(ROOT_SCALA_VERSIONS)
        ),
    )
    parser.add_argument(
        '--output_dir',
        type=str,
        default=str(OUTPUT_DIR),
        help=(
            'Directory in which to generate or update repository files ' +
            f'(default: {OUTPUT_DIR})'
        ),
    )

    args = parser.parse_args()
    output_dir = Path(args.output_dir)
    output_dir.mkdir(mode=0o755, parents=True, exist_ok=True)
    updater = ArtifactUpdater(
        ArtifactResolver(DOWNLOADED_ARTIFACTS_FILE), output_dir
    )

    try:
        for version in [args.version] if args.version else ROOT_SCALA_VERSIONS:
            updater.create_or_update_repository_file(version)

    except CreateRepositoryError as err:
        print(f'Failed to update version {version}: {err}', file=sys.stderr)
        sys.exit(1)
