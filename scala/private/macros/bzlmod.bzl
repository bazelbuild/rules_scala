"""Utilities for working with Bazel modules"""

_repo_attr = (
    "repo_name" if hasattr(Label("//:all"), "repo_name") else "workspace_name"
)

def apparent_repo_name(label_or_name):
    """Return a repository's apparent repository name.

    Can be replaced with a future bazel-skylib implementation, if accepted into
    that repo.

    Args:
        label_or_name: a Label or repository name string

    Returns:
        The apparent repository name
    """
    repo_name = getattr(label_or_name, _repo_attr, label_or_name).lstrip("@")
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
