import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import List
from typing import Dict
import urllib.request
import time
import hashlib
import json
import ast
import copy
import glob
import os

root_scala_versions = ["3.5.0"]
scala_test_version = "3.2.9"
scala_fmt_version = "3.0.0"

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

  common_root_artifacts = [
    f"org.scalatest:scalatest_{"3" if scala_major >= "3.0" else scala_major}:{scala_test_version}",
    f"org.scalameta:scalafmt-core_{"2.13" if scala_major >= "3.0" else scala_major}:{"2.7.5" if scala_major == "2.11" else scala_fmt_version}"
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
        f'org.typelevel:kind-projector_{scala_version}:{"0.13.2" if scala_major < "2.13" else "0.13.3"}'
  ]

  return common_root_artifacts + scala_artifacts

def get_maven_coordinates(artifact) -> MavenCoordinates:
  splitted = artifact.split(':')
  version = splitted[2] if splitted[2][0].isnumeric() else splitted[3]
  return MavenCoordinates(splitted[0], splitted[1], version, artifact)

def get_mavens_coordinates_from_json(artifacts) -> List[MavenCoordinates]:
  coordinates: List[MavenCoordinates] = []
  for artifact in artifacts:
    splitted = artifact.split(':')
    coordinates.append(MavenCoordinates(splitted[0], splitted[1], splitted[2], artifact))
  return coordinates

def get_artifact_checksum(artifact) -> str:
    output = subprocess.run(f'cs fetch {artifact}', capture_output=True, text=True, shell=True).stdout.splitlines()
    possible_url = [o for o in output if "https" in o][0]
    possible_url = possible_url[possible_url.find("https"):].replace('https/', 'https://')
    try:
        with urllib.request.urlopen(possible_url) as value:
            body = value.read()
            time.sleep(1)
            return hashlib.sha256(body).hexdigest()
    except urllib.error.HTTPError as e:
      print(f'RESOURCES NOT FOUND: {possible_url}')

def get_json_dependencies(artifact) -> List[MavenCoordinates]:
  with open('out.json') as file:
    data = json.load(file)
    for d in data["dependencies"]:
      if(d["coord"] == artifact):
        return get_mavens_coordinates_from_json(d["directDependencies"])
  return []

def get_label(coordinate) -> str:
  if ("org.scala-lang" in coordinate.group or "org.scalatest" in coordinate.group or "org.scalactic" in coordinate.group or "com.twitter" in coordinate.group or "javax.annotation" in coordinate.group) and "scala-collection" not in coordinate.artifact and "scalap" not in coordinate.artifact:
    return "io_bazel_rules_scala_" + coordinate.artifact.split('_')[0].replace('-', '_')
  elif "org.openjdk.jmh" in coordinate.group or "org.ow2.asm" in coordinate.group or "net.sf.jopt-simple" in coordinate.group or "org.apache.commons" in coordinate.group or "junit" in coordinate.group or "org.hamcrest" in coordinate.group or "org.specs2" in coordinate.group:
    return "io_bazel_rules_scala_" + coordinate.group.replace('.', '_').replace('-', '_') + '_' + coordinate.artifact.split('_')[0].replace('-', '_')
  elif "mustache" in coordinate.group or "guava" in coordinate.group or "scopt" in coordinate.group:
    return "io_bazel_rules_scala_" + coordinate.group.split('.')[-1]
  elif "com.thesamet.scalapb" in coordinate.group or "io." in coordinate.group or "com.google.guava" in coordinate.group:
    return "scala_proto_rules_" + coordinate.artifact.split('_')[0].replace('-', '_')
  else:
    return (coordinate.group.replace('.', '_').replace('-', '_') + '_' + coordinate.artifact.split('_')[0].replace('-', '_')).replace('_v2', '')

def map_to_resolved_artifacts(output) -> List[ResolvedArtifact]:
  resolved_artifacts = []
  subprocess.call(f'cs fetch {' '.join(output)} --json-output-file out.json', shell=True)
  for o in output:
    replaced = o.replace(':default','')
    coordinates = get_maven_coordinates(replaced)
    checksum = get_artifact_checksum(replaced)
    direct_dependencies = get_json_dependencies(replaced)
    resolved_artifacts.append(ResolvedArtifact(coordinates, checksum, direct_dependencies))
  return resolved_artifacts

def resolve_artifacts_with_checksums_and_direct_dependencies(root_artifacts) -> List[ResolvedArtifact]:
  command = f'cs resolve {' '.join(root_artifacts)}'
  output = subprocess.run(command, capture_output=True, text=True, shell=True).stdout.splitlines()
  artifacts = map_to_resolved_artifacts(output)
  return artifacts

def to_rules_scala_compatible_dict(artifacts, version) -> Dict[str, Dict]:
  temp = {}

  for a in artifacts:
    label = get_label(a.coordinates).replace('scala3_', 'scala_').replace('scala_tasty_core', 'scala_scala_tasty_core')
    deps = ['@' + get_label(dep) for dep in a.direct_dependencies]

    temp[label] = {
        "artifact": f"{a.coordinates.coordinate}",
        "sha256": f"{a.checksum}",
    } if not deps else {
        "artifact": f"{a.coordinates.coordinate}",
        "sha256": f"{a.checksum}",
        "deps:": deps,
      }

  return temp

def is_that_trailing_coma(content, char, indice) -> bool:
  return content[indice] == char and content[indice+1] != ',' and content[indice+1] != ':' and content[indice+1] != '@' and not content[indice+1].isalnum()

def get_with_trailing_commas(content) -> str:
  copied = copy.deepcopy(content)
  content_length = len(copied)
  i = 0

  while i < content_length - 1:
    if is_that_trailing_coma(copied, '"', i):
      copied = copied[:i] + '",' + copied[i + 1:]
      content_length = content_length + 1
      i = i+2
    elif is_that_trailing_coma(copied, ']', i):
      copied = copied[:i] + '],' + copied[i + 1:]
      content_length = content_length + 1
      i = i+2
    elif is_that_trailing_coma(copied, '}', i):
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
    written = get_with_trailing_commas(json.dumps(artifact_dict, indent=4).replace('true', 'True').replace('false', 'False'))
    data.write(written)
    data.write('\n')

def create_file(version):
  path = os.getcwd().replace('/scripts', '/third_party/repositories')
  file = Path(f'{path}/{'scala_' + "_".join(version.split(".")[:2]) + '.bzl'}')

  if not file.exists():
    file_to_copy = Path(sorted(glob.glob(f'{path}/*.bzl'))[-1])
    with file.open('w+') as data, file_to_copy.open('r') as data_to_copy:
      for line_number, line in enumerate(data_to_copy):
        if line_number > 1:
          data.write(line)

  with file.open('r+') as data:
    root_artifacts = select_root_artifacts(version)
    read_data = data.read()
    replaced_data = read_data[read_data.find('{'):]

    original_artifact_dict = ast.literal_eval(replaced_data)
    labels = original_artifact_dict.keys()

    transitive_artifacts: List[ResolvedArtifact] = resolve_artifacts_with_checksums_and_direct_dependencies(root_artifacts)
    generated_artifact_dict = to_rules_scala_compatible_dict(transitive_artifacts, version)
    generated_labels = generated_artifact_dict.keys()

    for label in labels:
      if label in generated_labels and generated_artifact_dict[label]["artifact"] != "org.scala-lang.modules:scala-parser-combinators_2.11:1.0.4":
        artifact = generated_artifact_dict[label]["artifact"]
        sha = generated_artifact_dict[label]["sha256"]
        deps = generated_artifact_dict[label]["deps:"] if "deps:" in generated_artifact_dict[label] else []

        original_artifact_dict[label]["artifact"] = artifact
        original_artifact_dict[label]["sha256"] = sha

        if deps:
          dependencies = [d for d in deps if d[1:] in labels and "runtime" not in d and "runtime" not in artifact]
          if dependencies:
            original_artifact_dict[label]["deps"] = dependencies

  write_to_file(original_artifact_dict, version, file)

for version in root_scala_versions:
  create_file(version)