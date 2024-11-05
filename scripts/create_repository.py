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
import urllib.request

ROOT_SCALA_VERSIONS = [
    "2.11.12",
    "2.12.20",
    "2.13.15",
    "3.1.3",
    "3.2.2",
    "3.3.4",
    "3.4.3",
    "3.5.2",
]
SCALATEST_VERSION = "3.2.19"
SCALAFMT_VERSION = "3.8.3"
KIND_PROJECTOR_VERSION = "0.13.3"
PROTOBUF_JAVA_VERSION = "4.28.3"

EXCLUDED_ARTIFACTS = set([
    "org.scala-lang.modules:scala-parser-combinators_2.11:1.0.4",
])

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
    scalatest_major = "3" if is_scala_3 else scala_major
    scalafmt_major = "2.13" if is_scala_3 else scala_major
    scalafmt_version = "2.7.5" if scala_major == "2.11" else SCALAFMT_VERSION

    common_root_artifacts = [
        f"com.google.protobuf:protobuf-java:{PROTOBUF_JAVA_VERSION}",
        f"org.scalatest:scalatest_{scalatest_major}:{SCALATEST_VERSION}",
        f"org.scalameta:scalafmt-core_{scalafmt_major}:{scalafmt_version}",
    ]
    scala_artifacts = [
        f'org.scala-lang:scala3-library_3:{scala_version}',
        f'org.scala-lang:scala3-compiler_3:{scala_version}',
        f'org.scala-lang:scala3-interfaces:{scala_version}',
        f'org.scala-lang:tasty-core_3:{scala_version}',
    ] if scala_major[0] == "3" else [
        f'org.scala-lang:scala-library:{scala_version}',
        f'org.scala-lang:scala-compiler:{scala_version}',
        f'org.scala-lang:scala-reflect:{scala_version}',
        f'org.scalameta:semanticdb-scalac_{scala_version}:4.9.9',
        f'org.typelevel:kind-projector_{scala_version}:' +
            KIND_PROJECTOR_VERSION,
    ]
    return common_root_artifacts + scala_artifacts


class CreateRepositoryError(Exception):
    """Errors raised explicitly by this module."""


@dataclass
class MavenCoordinates:
    """Contains the components parsed from a set of Maven coordinates."""
    group: str
    artifact: str
    version: str
    coordinate: str

    @staticmethod
    def new(artifact) -> Self:
        """Creates a new MavenCoordinates from a Maven coordinate string."""
        # There are Maven artifacts that contain extra components like `:jar` in
        # their coordinates. However, the groupId and artifactId are always the
        # first two components, and the version is the last.
        parts = artifact.split(':')
        return MavenCoordinates(parts[0], parts[1], parts[-1], artifact)

    def artifact_name(self):
        """Returns the name to use as a hash key for existing artifacts."""
        return f'{self.group}:{self.artifact}'

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
        if (self.group != other.group) or (self.artifact != other.artifact):
            raise CreateRepositoryError(
                f'Expected {self.group}:{self.artifact}, ' +
                f'got {other.group}:{other.artifact}'
            )

        lhs_parts = self.version.split(".")
        rhs_parts = other.version.split(".")

        for lhs_part, rhs_part in zip(lhs_parts, rhs_parts):
            if lhs_part == rhs_part:
                continue
            if lhs_part.isdecimal() and rhs_part.isdecimal():
                return int(rhs_part) < int(lhs_part)
            return rhs_part < lhs_part

        return len(rhs_parts) < len(lhs_parts)


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

    def get_label(self, coordinates) -> str:
        """Creates a repository label from an artifact's Maven coordinates."""
        group = coordinates.group
        group_label = group.replace('.', '_').replace('-', '_')
        artifact_label = coordinates.artifact.split('_')[0].replace('-', '_')

        if group in self._SCALA_LANG_GROUPS:
            return self._get_scala_lang_label(artifact_label, coordinates)
        if group in self._ARTIFACT_LABEL_ONLY_GROUPS:
            return f'io_bazel_rules_scala_{artifact_label}'
        if group in self._GROUP_AND_ARTIFACT_LABEL_GROUPS:
            return f'io_bazel_rules_scala_{group_label}_{artifact_label}'
        if group in self._SCALA_PROTO_RULES_GROUPS:
            return self._get_scala_proto_label(artifact_label, coordinates)
        if group in self._SPECIAL_CASE_GROUP_LABELS:
            return self._SPECIAL_CASE_GROUP_LABELS['group']
        return f'{group_label}_{artifact_label}'.replace('_v2', '')

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

    _SPECIAL_CASE_GROUP_LABELS = {
        "com.github.scopt": "io_bazel_rules_scala_scopt",
        "com.github.spullara.mustache.java": "io_bazel_rules_scala_mustache",
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
        proc = self._run_command(
            f'cs resolve {' '.join(root_artifacts)}',
            'Resolving root artifacts',
        )

        try:
            return self._map_to_resolved_artifacts(
                proc.stdout.splitlines(), current_artifacts,
            )
        finally:
            artifacts_file = Path(self._downloaded_artifacts_file)
            if artifacts_file.exists():
                artifacts_file.unlink()


    def _map_to_resolved_artifacts(
        self, output, current_artifacts,
    ) -> List[ResolvedArtifact]:
        command = (
            f'cs fetch {' '.join(output)} --json-output-file ' +
            self._downloaded_artifacts_file
        )
        self._run_command(command, 'Fetching resolved artifacts')
        resolved = []
        current_artifacts_map = self._create_current_artifacts_map(
            current_artifacts
        )

        for line in output:
            coords = line.replace(':default', '')
            mvn_coords = MavenCoordinates.new(coords)
            deps = self._get_json_dependencies(coords)
            current = current_artifacts_map.get(mvn_coords.artifact_name())

            if current is None or mvn_coords.is_newer_than(current.coordinates):
                resolved.append(ResolvedArtifact(
                    mvn_coords, self._get_artifact_checksum(coords), deps
                ))

        return resolved

    @staticmethod
    def _create_current_artifacts_map(original_artifacts):
        result = {}

        for metadata in original_artifacts.values():
            coordinates = MavenCoordinates.new(metadata['artifact'])
            name = coordinates.artifact_name()

            if name not in result and metadata.get('testonly') is not True:
                result[name] = ResolvedArtifact(
                    coordinates, metadata['sha256'], metadata.get('deps', [])
                )

        return result

    def _get_json_dependencies(self, artifact) -> List[MavenCoordinates]:
        with open(self._downloaded_artifacts_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        return (
            [MavenCoordinates.new(d) for d in a["directDependencies"]]
            if any((a := d)["coord"] == artifact for d in data["dependencies"])
            else []
        )

    @staticmethod
    def _get_artifact_checksum(artifact) -> str:
        proc = ArtifactResolver._run_command(
            f'cs fetch {artifact}', 'Fetching artifact for checksumming',
        )

        possible_url = [o for o in proc.stdout.splitlines() if "https" in o][0]
        possible_url = possible_url[possible_url.find("https"):]
        possible_url = possible_url.replace('https/', 'https://')

        try:
            with urllib.request.urlopen(possible_url) as value:
                return hashlib.sha256(value.read()).hexdigest()

        except urllib.error.HTTPError as e:
            print(f'RESOURCES NOT FOUND: {possible_url}: {e}')
            return 'NO_CHECKSUM_FOUND'

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

        original_artifacts = self._get_original_artifacts(file_path)
        resolved_artifacts = self._to_rules_scala_compatible_dict(
            self._resolver.resolve_artifacts(
                select_root_artifacts(
                    scala_version, '.'.join(version_parts), is_scala_3
                ),
                original_artifacts
            ),
            ArtifactLabelMaker(is_scala_3),
        )
        self._update_artifacts(original_artifacts, resolved_artifacts)
        self._write_to_file(original_artifacts, scala_version, file_path)

    def _get_original_artifacts(self, file_path):
        self._copy_previous_version_or_create_new_file(file_path)

        with file_path.open('r', encoding='utf-8') as data:
            read_data = data.read()

        return ast.literal_eval(read_data[read_data.find('{'):])

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
            artifact = resolved_metadata['artifact']
            if artifact in EXCLUDED_ARTIFACTS:
                continue

            metadata = original_artifacts.setdefault(label, {})
            metadata['artifact'] = artifact
            metadata['sha256'] = resolved_metadata['sha256']
            dependencies = resolved_metadata['deps']

            if dependencies:
                metadata['deps'] = dependencies
            if 'testonly' in metadata:
                del metadata['testonly']

    @staticmethod
    def _write_to_file(artifact_dict, scala_version, file):
        artifacts = (
            json.dumps(artifact_dict, indent=4)
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
