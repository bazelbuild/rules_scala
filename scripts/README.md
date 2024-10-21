# Update/create scala_x_x.bzl repository file script

- [About](#about)
- [Usage](#usage)
- [Examples](#examples)
- [Debugging](#debugging)
- [Requirements](#requirements)

### About
The script allows to update a certain scala_x_x.bzl file and its content (artifact, sha, dependencies), by changing the value of `root_scala_version` variable.
It can be used to create non-existent file for chosen Scala version. <br>
It's using a [https://get-coursier.io/docs/](coursier) in order to **resolve** lists the transitive dependencies of dependencies and **fetch** the JARs of it.

### Usage
Usage from `/rules_scala/scripts`:
````
python3 create_repository.py
````

### Examples
Current value of `root_scala_versions`:
```
root_scala_versions = ["2.11.12", "2.12.19", "2.13.14", "3.1.3", "3.2.2", "3.3.3", "3.4.3", "3.5.0"]
```

To **update** content of `scala_3_4.bzl` file:
```
root_scala_versions = ["2.11.12", "2.12.19", "2.13.14", "3.1.3", "3.2.2", "3.3.3", "3.4.4", "3.5.0"]
                                                                                   ^^^^^^^ <- updated version
```

To **create** new `scala_3_6.bzl` file:
```
root_scala_versions = ["2.11.12", "2.12.19", "2.13.14", "3.1.3", "3.2.2", "3.3.3", "3.4.3", "3.5.0", "3.6.0"]
                                                                                                     ^^^^^^^ <- new version
```

### Debugging
Certain dependency version may not have a support for chosen Scala version e.g.
```
kind_projector_version = "0.13.2" if scala_major < "2.13" else "0.13.3"
```

In order of that, there may be situations that script won't work. To debug that problem and adjust the values of hard-coded variables:
```
scala_test_major = "3" if scala_major >= "3.0" else scala_major
scala_fmt_major = "2.13" if scala_major >= "3.0" else scala_major
kind_projector_version = "0.13.2" if scala_major < "2.13" else "0.13.3"
f"org.scalameta:scalafmt-core_{scala_fmt_major}:{"2.7.5" if scala_major == "2.11" else scala_fmt_version}"
```
there is an option to print the output of these two subprocesses:

`output = subprocess.run(f'cs fetch {artifact}', capture_output=True, text=True, shell=True).stdout.splitlines()` <br>

```
  command = f'cs resolve {' '.join(root_artifacts)}'
  output = subprocess.run(command, capture_output=True, text=True, shell=True).stdout.splitlines()
```

### Requirements
Installed [Coursier](https://get-coursier.io/) and [Python 3](https://www.python.org/downloads/)