def proto_cross_repo_boundary_repository():
    native.new_local_repository(
        name = "proto_cross_repo_boundary",
        path = "test/proto_cross_repo_boundary/repo",
        build_file = "test/proto_cross_repo_boundary/repo/BUILD.repo",
    )
