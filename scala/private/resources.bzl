def paths(resources, resource_strip_prefix):
    """Return a list of path tuples (target, source) where:
        target - is a path in the archive (with given prefix stripped off)
        source - is an absolute path of the resource file

    Tuple ordering is aligned with zipper format ie zip_path=file

    Args:
        resources: list of file objects
        resource_strip_prefix: string to strip from resource path
    """
    resources_zip_path_real_path_pairs = [(_target_path(resource, resource_strip_prefix), resource.path) for resource in resources]

    # Explicitly output directory mapping in the zip file, because directory matters as well.
    # E.g. if a/b/c.txt is selected, then we need to make sure a/ and a/b/ is in the zip file.
    # Otherwise getClass.getResource("/a/b") will return null.
    directory_mapping = dict()
    for (path_zip, path_real) in resources_zip_path_real_path_pairs:
        # 1M because there's no while loop, and there is no way for a dir
        # to contain 1M "/"s.
        for i in range(0, 1000000):
            # META-INF was already properly handled.
            if "/" not in path_zip or "META-INF/" in path_zip:
                break
            path_zip_dir = "/".join(path_zip.split("/")[:-1])
            path_real_dir = "/".join(path_real.split("/")[:-1])
            if path_zip_dir in directory_mapping:
                break
#            print("zzz", path_zip, path_real)
            directory_mapping[path_zip_dir] = path_real_dir
            path_zip = path_zip_dir
            path_real = path_real_dir
    for k, v in directory_mapping.items():
        resources_zip_path_real_path_pairs.append((k, v))
        print(k, v)

    return resources_zip_path_real_path_pairs

def _target_path(resource, resource_strip_prefix):
    path = _target_path_by_strip_prefix(resource, resource_strip_prefix) if resource_strip_prefix else _target_path_by_default_prefixes(resource)
    return _strip_prefix(path, "/")

def _target_path_by_strip_prefix(resource, resource_strip_prefix):
    # Start from absolute resource path and then strip roots so we get to correct short path
    # resource.short_path sometimes give weird results ie '../' prefix
    path = resource.path
    if resource_strip_prefix != resource.owner.workspace_root:
        path = _strip_prefix(path, resource.owner.workspace_root + "/")
    path = _strip_prefix(path, resource.root.path + "/")

    # proto_library translates strip_import_prefix to proto_source_root which includes root so we have to strip it
    prefix = _strip_prefix(resource_strip_prefix, resource.root.path + "/")
    if not path.startswith(prefix):
        fail("Resource file %s is not under the specified prefix %s to strip" % (path, prefix))
    return path[len(prefix):]

def _target_path_by_default_prefixes(resource):
    path = resource.path

    #  Here we are looking to find out the offset of this resource inside
    #  any resources folder. We want to return the root to the resources folder
    #  and then the sub path inside it
    dir_1, dir_2, rel_path = path.partition("resources")
    if rel_path:
        return rel_path

    #  The same as the above but just looking for java
    (dir_1, dir_2, rel_path) = path.partition("java")
    if rel_path:
        return rel_path

    # Both short_path and path have quirks we wish to avoid, in short_path there are times where
    # it is prefixed by `../` instead of `external/`. And in .path it will instead return the entire
    # bazel-out/... path, which is also wanting to be avoided. So instead, we return the short-path if
    # path starts with bazel-out and the entire path if it does not.
    return resource.short_path if path.startswith("bazel-out") else path

def _strip_prefix(path, prefix):
    return path[len(prefix):] if path.startswith(prefix) else path
