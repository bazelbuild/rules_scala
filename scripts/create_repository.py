#!/usr/bin/env python3
"""Updates jar versions in third_party/repositories/scala_*.bzl files"""

from dataclasses import dataclass
from pathlib import Path
from typing import Dict
from typing import List

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
SCALATEST_VERSION = "3.2.9"
SCALAFMT_VERSION = "3.8.3"
PROTOBUF_JAVA_VERSION = "4.28.2"

EXCLUDED_ARTIFACTS = set([
    "org.scala-lang.modules:scala-parser-combinators_2.11:1.0.4",
])

OUTPUT_DIR = Path(__file__).parent.parent / 'third_party' / 'repositories'
DOWNLOADED_ARTIFACTS_FILE = 'repository-artifacts.json'

@dataclass
class MavenCoordinates:
    group: str
    artifact: str
    version: str
    coordinate: str

    def artifact_name(self):
        return f'{self.group}:{self.artifact}'

@dataclass
class ResolvedArtifact:
    coordinates: MavenCoordinates
    checksum: str
    direct_dependencies: List[MavenCoordinates]

class CreateRepositoryError(Exception):
    pass

def select_root_artifacts(scala_version, scala_major, is_scala_3) -> List[str]:
    scalatest_major = "3" if is_scala_3 else scala_major
    scalafmt_major = "2.13" if is_scala_3 else scala_major
    kind_projector_version = "0.13.2" if scala_major < "2.12" else "0.13.3"
    scalafmt_version = "2.7.5" if scala_major == "2.11" else SCALAFMT_VERSION

    common_root_artifacts = [
        f"com.google.protobuf:protobuf-java:{PROTOBUF_JAVA_VERSION}",
        f"org.scalatest:scalatest_{scalatest_major}:{SCALATEST_VERSION}",
        f"org.scalameta:scalafmt-core_{scalafmt_major}:{scalafmt_version}"
    ]
    scala_artifacts = [
        f'org.scala-lang:scala3-library_3:{scala_version}',
        f'org.scala-lang:scala3-compiler_3:{scala_version}',
        f'org.scala-lang:scala3-interfaces:{scala_version}',
        f'org.scala-lang:tasty-core_3:{scala_version}'
    ] if scala_major[0] == "3" else [
        f'org.scala-lang:scala-library:{scala_version}',
        f'org.scala-lang:scala-compiler:{scala_version}',
        f'org.scala-lang:scala-reflect:{scala_version}',
        f'org.scalameta:semanticdb-scalac_{scala_version}:4.9.9',
        f'org.typelevel:kind-projector_{scala_version}:{kind_projector_version}'
    ]
    return common_root_artifacts + scala_artifacts

def get_maven_coordinates(artifact) -> MavenCoordinates:
    # There are Maven artifacts that contain extra components like `:jar` in
    # their coordinates. However, the groupId and artifactId are always the
    # first two components, and the version is the last.
    parts = artifact.split(':')
    return MavenCoordinates(parts[0], parts[1], parts[-1], artifact)

def get_mavens_coordinates_from_json(artifacts) -> List[MavenCoordinates]:
    return list(map(get_maven_coordinates, artifacts))

def run_command(command, description):
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

def get_artifact_checksum(artifact) -> str:
    proc = run_command(
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

def get_json_dependencies(artifact) -> List[MavenCoordinates]:
    with open(DOWNLOADED_ARTIFACTS_FILE, 'r', encoding='utf-8') as file:
        data = json.load(file)

    return (
        get_mavens_coordinates_from_json(dep["directDependencies"])
        if any((dep := d)["coord"] == artifact for d in data["dependencies"])
        else []
    )

ARTIFACT_LABEL_ONLY_GROUPS = set([
  "com.twitter",
  "javax.annotation",
  "org.scalactic",
  "org.scalatest",
])

GROUP_AND_ARTIFACT_LABEL_GROUPS = set([
  "junit",
  "net.sf.jopt-simple",
  "org.apache.commons",
  "org.hamcrest",
  "org.openjdk.jmh",
  "org.ow2.asm",
  "org.specs2",
])

LAST_GROUP_COMPONENT_GROUPS = set([
    "com.google.guava"
    "com.github.scopt",
])

NEXT_TO_LAST_GROUP_COMPONENT_GROUPS = set([
    "com.github.spullara.mustache.java",
])

SCALA_PROTO_RULES_GROUPS = set([
    "com.google.instrumentation",
    "com.lmax",
    "com.thesamet.scalapb",
    "io.grpc",
    "io.netty",
    "io.opencensus",
    "io.perfmark",
])

SCALA_LANG_GROUPS = set(['org.scala-lang', 'org.scala-lang.modules'])
SCALA_2_ARTIFACTS = set(['scala-library', 'scala-compiler', 'scala-reflect'])

def get_scala_lang_label(artifact_label, is_scala_3, coordinates):
    artifact = coordinates.artifact
    if artifact == 'scalap':
        return 'org_scala_lang_scalap'

    label = f'io_bazel_rules_scala_{artifact_label}'

    if is_scala_3 and artifact in SCALA_2_ARTIFACTS:
        return label + '_2'
    if artifact.startswith('scala3-'):
        return label.replace('scala3_', 'scala_')
    return label.replace('scala_tasty_core', 'scala_scala_tasty_core')

def get_scala_proto_label(artifact_label, coordinates):
    if (
        coordinates.group == "com.thesamet.scalapb" and
        not artifact_label.startswith("scalapb_")
    ):
        artifact_label = "scalapb_" + artifact_label
    return f'scala_proto_rules_{artifact_label}'

def get_label(coordinates, is_scala_3) -> str:
    group = coordinates.group
    group_label = group.replace('.', '_').replace('-', '_')
    artifact_label = coordinates.artifact.split('_')[0].replace('-', '_')

    if group in SCALA_LANG_GROUPS:
        return get_scala_lang_label(artifact_label, is_scala_3, coordinates)
    if group in ARTIFACT_LABEL_ONLY_GROUPS:
        return f'io_bazel_rules_scala_{artifact_label}'
    if group in GROUP_AND_ARTIFACT_LABEL_GROUPS:
        return f'io_bazel_rules_scala_{group_label}_{artifact_label}'
    if group in LAST_GROUP_COMPONENT_GROUPS:
        return f'io_bazel_rules_scala_{group.split('.')[-1]}'
    if group in NEXT_TO_LAST_GROUP_COMPONENT_GROUPS:
        return f'io_bazel_rules_scala_{group.split('.')[-2]}'
    if group in SCALA_PROTO_RULES_GROUPS:
        return get_scala_proto_label(artifact_label, coordinates)
    return f'{group_label}_{artifact_label}'.replace('_v2', '')

def is_newer_version(coords_to_check, current_artifact):
    """Determines if the coords_to_check is newer than the current_artifact.

    The idea is to prevent downgrades of versions already in the artifacts file.
    If they are later versions, presumably they were updated to that version for
    a good reason.

    Args:
        coords_to_check (MavenCoordinates): a potentially newer artifact
        current_artifact (ResolvedArtifact): the current artifact information in
            the repo config file, or None if it doesn't exist

    Returns:
        True if current_artifact is none or coords_to_check.version is newer than
            current_artifact.coordinates.version, or if current_artifact is None
        False otherwise
    """
    if current_artifact is None:
        return True

    check_parts = coords_to_check.version.split(".")
    current_parts = current_artifact.coordinates.version.split(".")

    for check_part, current_part in zip(check_parts, current_parts):
        if check_part == current_part:
            continue
        if check_part.isdecimal() and current_part.isdecimal():
            return int(current_part) < int(check_part)
        return current_part < check_part

    return len(current_parts) < len(check_parts)

def map_to_resolved_artifacts(
    output, current_resolved_artifacts_map,
) -> List[ResolvedArtifact]:
    command = (
        f'cs fetch {' '.join(output)} --json-output-file ' +
        DOWNLOADED_ARTIFACTS_FILE
    )
    proc = run_command(command, 'Fetching resolved artifacts')
    resolved = []

    for line in output:
        coords = line.replace(':default', '')
        mvn_coords = get_maven_coordinates(coords)
        deps = get_json_dependencies(coords)
        current = current_resolved_artifacts_map.get(mvn_coords.artifact_name())

        if is_newer_version(mvn_coords, current):
            resolved.append(ResolvedArtifact(
                mvn_coords, get_artifact_checksum(coords), deps
            ))

    return resolved

def resolve_artifacts_with_checksums_and_direct_dependencies(
    root_artifacts, current_resolved_artifacts_map
) -> List[ResolvedArtifact]:
    proc = run_command(
        f'cs resolve {' '.join(root_artifacts)}', 'Resolving root artifacts'
    )

    return map_to_resolved_artifacts(
        proc.stdout.splitlines(), current_resolved_artifacts_map,
    )

def to_rules_scala_compatible_dict(artifacts, is_scala_3) -> Dict[str, Dict]:
    result = {}

    for a in artifacts:
        coordinates = a.coordinates
        result[get_label(coordinates, is_scala_3)] = {
            "artifact": f"{coordinates.coordinate}",
            "sha256": f"{a.checksum}",
            "deps": sorted([
                f'@{get_label(d, is_scala_3)}' for d in a.direct_dependencies
            ]),
        }

    return result

def write_to_file(artifact_dict, version, file):
    artifacts = (
        json.dumps(artifact_dict, indent=4)
            .replace('true', 'True')
            .replace('false', 'False')
    )
    # Add trailing commas.
    artifacts = re.sub(r'([]}"])\n', r'\1,\n', artifacts) + '\n'

    with file.open('w', encoding='utf-8') as data:
        data.write(f'scala_version = "{version}"\n')
        data.write('\nartifacts = ')
        data.write(artifacts)

def create_current_resolved_artifacts_map(original_artifacts):
    result = {}
    for metadata in original_artifacts.values():
        coordinates = get_maven_coordinates(metadata['artifact'])
        artifact_name = coordinates.artifact_name()

        if artifact_name not in result and metadata.get('testonly') is not True:
            result[artifact_name] = ResolvedArtifact(
                coordinates, metadata['sha256'], metadata.get('deps', [])
            )
    return result

def copy_previous_version_or_create_new_file_if_missing(file_path, output_dir):
    if file_path.exists():
        return

    existing_files = sorted(output_dir.glob('scala_*.bzl'))
    if existing_files:
        shutil.copyfile(existing_files[-1], file_path)
        return

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write('{}\n')

def create_or_update_repository_file(version, output_dir):
    file = output_dir / f'scala_{"_".join(version.split(".")[:2])}.bzl'
    copy_previous_version_or_create_new_file_if_missing(file, output_dir)

    print('\nUPDATING:', file)
    with file.open('r', encoding='utf-8') as data:
        read_data = data.read()

    scala_major = ".".join(version.split(".")[:2])
    is_scala_3 = scala_major.startswith("3.")
    root_artifacts = select_root_artifacts(version, scala_major, is_scala_3)
    replaced_data = read_data[read_data.find('{'):]

    original_artifacts = ast.literal_eval(replaced_data)

    transitive_artifacts: List[ResolvedArtifact] = (
       resolve_artifacts_with_checksums_and_direct_dependencies(
            root_artifacts,
            create_current_resolved_artifacts_map(original_artifacts),
       )
    )
    generated_artifacts = to_rules_scala_compatible_dict(
        transitive_artifacts, is_scala_3
    )

    for label, generated_metadata in generated_artifacts.items():
        artifact = generated_metadata["artifact"]
        if artifact in EXCLUDED_ARTIFACTS:
            continue

        metadata = original_artifacts.setdefault(label, {})
        metadata["artifact"] = artifact
        metadata["sha256"] = generated_metadata["sha256"]
        dependencies = generated_metadata["deps"]

        if dependencies:
            metadata["deps"] = dependencies

    write_to_file(original_artifacts, version, file)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(
            'Sets up repository configuration files ' +
            'for different Scala versions.'
        )
    )
    parser.add_argument(
        '--version',
        type=str,
        choices=ROOT_SCALA_VERSIONS,
        metavar='SCALA_VERSION',
        help=(
            'Scala version to bootstrap or update repository. ' +
            'If not provided, updates all supported versions. ' +
            f'(default: {', '.join(ROOT_SCALA_VERSIONS)})'
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

    try:
        for version in [args.version] if args.version else ROOT_SCALA_VERSIONS:
            create_or_update_repository_file(version, output_dir)

    except CreateRepositoryError as err:
        print(f'Failed to update version {version}: {err}', file=sys.stderr)
        sys.exit(1)

    finally:
        artifacts_file = Path(DOWNLOADED_ARTIFACTS_FILE)
        if artifacts_file.exists():
            artifacts_file.unlink()
