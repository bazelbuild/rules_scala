"""Utilities for working with Bazel modules"""

def _repo_name(label_or_name):
    """Utility to provide Label compatibility with Bazel 5.

    Under Bazel 5, calls `Label.workspace_name`. Otherwise calls
    `Label.repo_name`.

    Args:
        label_or_name: a Label or repository name string

    Returns:
        The repository name returned directly from the Label API, or the
            original string if not a Label
    """
    if hasattr(label_or_name, "repo_name"):
        return label_or_name.repo_name

    return getattr(label_or_name, "workspace_name", label_or_name)

def apparent_repo_name(label_or_name):
    """Return a repository's apparent repository name.

    Can be replaced with a future bazel-skylib implementation, if accepted into
    that repo.

    Args:
        label_or_name: a Label or repository name string

    Returns:
        The apparent repository name
    """
    repo_name = _repo_name(label_or_name).lstrip("@")
    delimiter_indices = []

    # Bazed on this pattern from the Bazel source:
    # com.google.devtools.build.lib.cmdline.RepositoryName.VALID_REPO_NAME
    for i in range(len(repo_name)):
        c = repo_name[i]
        if not (c.isalnum() or c in "_-."):
            delimiter_indices.append(i)

    if len(delimiter_indices) == 0:
        # Already an apparent repo name, apparently.
        return repo_name

    if len(delimiter_indices) == 1:
        # The name is for a top level module, possibly containing a version ID.
        return repo_name[:delimiter_indices[0]]

    return repo_name[delimiter_indices[-1] + 1:]

def apparent_repo_label_string(label):
    """Return a Label string starting with its apparent repo name.

    Args:
        label: a Label instance

    Returns:
        str(label) with its canonical repository name replaced with its apparent
            repository name
    """
    repo_name = _repo_name(label)
    if len(repo_name) == 0:
        return str(label)

    label_str = "@" + str(label).lstrip("@")
    return label_str.replace(label.repo_name, apparent_repo_name(label))

_IS_BZLMOD_ENABLED = str(Label("//:all")).startswith("@@")

_MAIN_REPO_PREFIX = "@@//" if _IS_BZLMOD_ENABLED else "@//"

def adjust_main_repo_prefix(target_pattern):
    """Updates the main repo prefix to match the current Bazel version.

    The main repo prefix will be "@//" for Bazel < 7.1.0, and "@@//" for Bazel
    >= 7.1.0 under Bzlmod. This macro automatically updates strings representing
    include/exclude target patterns so that they match actual main repository
    target Labels correctly.

    Args:
        target_pattern: a string used to match a BUILD target pattern

    Returns:
        the string with any main repository prefix updated to match the current
            Bazel version
    """
    if target_pattern.startswith("@//") or target_pattern.startswith("@@//"):
        return _MAIN_REPO_PREFIX + target_pattern.lstrip("@/")

    return target_pattern
