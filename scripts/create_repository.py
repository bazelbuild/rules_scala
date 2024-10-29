"""Updates jar versions in third_party/repositories/scala_*.bzl files"""

from dataclasses import dataclass
from pathlib import Path
from typing import Dict
from typing import List

import ast
import copy
import glob
import hashlib
import json
import os
import subprocess
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
SCALAFMT_VERSION = "3.0.0"

EXCLUDED_ARTIFACTS = set([
    "org.scala-lang.modules:scala-parser-combinators_2.11:1.0.4",
])

@dataclass
class MavenCoordinates:
    group: str
    artifact: str
    version: str
    coordinate: str

@dataclass
class ResolvedArtifact:
    coordinates: MavenCoordinates
    checksum: str
    direct_dependencies: List[MavenCoordinates]

def select_root_artifacts(scala_version) -> List[str]:
    scala_major = ".".join(scala_version.split(".")[:2])
    scalatest_major = "3" if scala_major >= "3.0" else scala_major
    scalafmt_major = "2.13" if scala_major >= "3.0" else scala_major
    kind_projector_version = "0.13.2" if scala_major < "2.12" else "0.13.3"
    scalafmt_version = "2.7.5" if scala_major == "2.11" else SCALAFMT_VERSION

    common_root_artifacts = [
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
    splitted = artifact.split(':')
    version = splitted[2] if splitted[2][0].isnumeric() else splitted[3]
    return MavenCoordinates(splitted[0], splitted[1], version, artifact)

def get_mavens_coordinates_from_json(artifacts) -> List[MavenCoordinates]:
    return list(map(get_maven_coordinates, artifacts))

def get_artifact_checksum(artifact) -> str:
    output = subprocess.run(
      f'cs fetch {artifact}',
      capture_output=True,
      text=True,
      shell=True,
      check=False,
    ).stdout.splitlines()

    possible_url = [o for o in output if "https" in o][0]
    possible_url = possible_url[possible_url.find("https"):]
    possible_url = possible_url.replace('https/', 'https://')

    try:
        with urllib.request.urlopen(possible_url) as value:
            body = value.read()
            return hashlib.sha256(body).hexdigest()

    except urllib.error.HTTPError as e:
        print(f'RESOURCES NOT FOUND: {possible_url}: {e}')

def get_json_dependencies(artifact) -> List[MavenCoordinates]:
    with open('out.json', 'r', encoding='utf-8') as file:
        data = json.load(file)

    return (
        get_mavens_coordinates_from_json(dependency["directDependencies"])
        if any((dependency := d)["coord"] == artifact
        for d in data["dependencies"])
        else []
    )

COORDINATE_GROUPS = [
    set([
      "com.twitter",
      "javax.annotation"
      "org.scala-lang",
      "org.scalactic",
      "org.scalatest",
    ]),
    set([
      "junit",
      "net.sf.jopt-simple",
      "org.apache.commons",
      "org.hamcrest",
      "org.openjdk.jmh",
      "org.ow2.asm",
      "org.specs2",
    ]),
    set([
      "com.github.spullara.mustache.java",
      "com.github.scopt",
    ]),
    set([
      "com.google.guava"
      "com.thesamet.scalapb",
      "io.grpc",
      "io.netty",
      "io.perfmark",
    ]),
]

def get_label(coordinate) -> str:
    if coordinate.group in COORDINATE_GROUPS[0]:
        return (
            "io_bazel_rules_scala_" +
            coordinate.artifact
                .split('_')[0]
                .replace('-', '_')
        )
    if coordinate.group in COORDINATE_GROUPS[1]:
        return (
            "io_bazel_rules_scala_" +
            coordinate.group
                .replace('.', '_')
                .replace('-', '_') +
            '_' +
            coordinate.artifact
                .split('_')[0]
                .replace('-', '_')
        )
    if coordinate.group in COORDINATE_GROUPS[2]:
        return "io_bazel_rules_scala_" + coordinate.group.split('.')[-1]
    if coordinate.group in COORDINATE_GROUPS[3]:
        return (
            "scala_proto_rules_" +
            coordinate.artifact
                .split('_')[0]
                .replace('-', '_')
        )
    return (
        coordinate.group
            .replace('.', '_')
            .replace('-', '_') +
        '_' +
        coordinate.artifact.split('_')[0]
            .replace('-', '_')
    ).replace('_v2', '')

def map_to_resolved_artifacts(output) -> List[ResolvedArtifact]:
    subprocess.call(
        f'cs fetch {' '.join(output)} --json-output-file out.json', shell=True
    )
    return [
        ResolvedArtifact(
            get_maven_coordinates(artifact),
            get_artifact_checksum(artifact),
            get_json_dependencies(artifact),
        )
        for artifact in [o.replace(':default', '') for o in output]
    ]

def resolve_artifacts_with_checksums_and_direct_dependencies(root_artifacts) \
    -> List[ResolvedArtifact]:
    command = f'cs resolve {' '.join(root_artifacts)}'
    proc = subprocess.run(
      command, capture_output=True, text=True, shell=True, check=False
    )
    print(proc.stderr)
    return map_to_resolved_artifacts(proc.stdout.splitlines())

def to_rules_scala_compatible_dict(artifacts) -> Dict[str, Dict]:
    result = {}

    for a in artifacts:
        label = (
            get_label(a.coordinates)
                .replace('scala3_', 'scala_')
                .replace('scala_tasty_core', 'scala_scala_tasty_core')
        )
        deps = [
            f'@{get_label(dep)}_2'
            if "scala3-library_3" in a.coordinates.artifact
            else f'@{get_label(dep)}'
            for dep in a.direct_dependencies
        ]

        result[label] = {
            "artifact": f"{a.coordinates.coordinate}",
            "sha256": f"{a.checksum}",
        }
        if deps:
            result[label]["deps"] = deps
    return result

def is_that_trailing_comma(content, char, indice) -> bool:
    return (
        content[indice] == char and
        content[indice+1] != ',' and
        content[indice+1] != ':' and
        content[indice+1] != '@' and
        not content[indice+1].isalnum()
    )

def get_with_trailing_commas(content) -> str:
    copied = copy.deepcopy(content)
    content_length = len(copied)
    i = 0

    while i < content_length - 1:
        if is_that_trailing_comma(copied, '"', i):
            copied = copied[:i] + '",' + copied[i + 1:]
            content_length = content_length + 1
            i = i+2
        elif is_that_trailing_comma(copied, ']', i):
            copied = copied[:i] + '],' + copied[i + 1:]
            content_length = content_length + 1
            i = i+2
        elif is_that_trailing_comma(copied, '}', i):
            copied = copied[:i] + '},' + copied[i + 1:]
            content_length = content_length + 1
            i = i+2
        else:
            i = i+1

    return copied

def write_to_file(artifact_dict, version, file):
    with file.open('w') as data:
        data.write(f'scala_version = "{version}"\n')
        data.write('\nartifacts = ')
        data.write(
            f'{get_with_trailing_commas(json.dumps(artifact_dict, indent=4)
                .replace('true', 'True').replace('false', 'False'))}\n'
        )

def create_file(version):
    path = os.getcwd().replace('/scripts', '/third_party/repositories')
    file = Path(
        f'{path}/{'scala_' + "_".join(version.split(".")[:2]) + '.bzl'}'
    )

    if not file.exists():
        file_to_copy = Path(sorted(glob.glob(f'{path}/*.bzl'))[-1])
        with (
            file.open('w+', encoding='utf-8') as data,
            file_to_copy.open('r', encoding='utf-8') as data_to_copy,
        ):
            for line in data_to_copy:
                data.write(line)

    with file.open('r+', encoding='utf-8') as data:
        read_data = data.read()

    root_artifacts = select_root_artifacts(version)
    replaced_data = read_data[read_data.find('{'):]

    original_artifacts = ast.literal_eval(replaced_data)

    transitive_artifacts: List[ResolvedArtifact] = (
       resolve_artifacts_with_checksums_and_direct_dependencies(root_artifacts)
    )
    generated_artifacts = to_rules_scala_compatible_dict(transitive_artifacts)

    for label, original_metadata in original_artifacts.items():
        metadata = generated_artifacts.get(label, None)
        if metadata is None:
            continue

        artifact = metadata["artifact"]
        if artifact in EXCLUDED_ARTIFACTS:
            continue

        original_metadata["artifact"] = artifact
        original_metadata["sha256"] = metadata["sha256"]
        dependencies = [
            d for d in metadata.get("deps:", []) if (
                d[1:] in original_artifacts and
                "runtime" not in d and
                "runtime" not in artifact
            )
        ]
        if dependencies:
            original_metadata["deps"] = dependencies

    write_to_file(original_artifacts, version, file)

for root_scala_version in ROOT_SCALA_VERSIONS:
    create_file(root_scala_version)
