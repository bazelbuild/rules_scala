"""Utilities for working with Bazel modules"""

def apparent_repo_name(repository_ctx):
    """Generates a repository's apparent name from a repository_ctx object.

    Args:
        repository_ctx: a repository_ctx object

    Returns:
        An apparent repo name derived from repository_ctx.name
    """
    repo_name = repository_ctx.name

    # Bazed on this pattern from the Bazel source:
    # com.google.devtools.build.lib.cmdline.RepositoryName.VALID_REPO_NAME
    for i in range(len(repo_name) - 1, -1, -1):
        c = repo_name[i]
        if not (c.isalnum() or c in "_-."):
            return repo_name[i + 1:]

    return repo_name
