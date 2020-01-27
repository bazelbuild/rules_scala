def phase_discover_tests(ctx, p):
    print('discover tests')

    worker = ctx.attr._discover_tests_worker
    worker_inputs, _, worker_input_manifests = ctx.resolve_command(
        tools = [worker],
    )

    output = ctx.actions.declare_file("{}_discovered_tests.bin".format(ctx.label.name))

    args = ctx.actions.args()
    args.set_param_file_format("multiline")
    args.use_param_file("@%s", use_always = True)

    args.add(output)
    args.add_all(p.compile.full_jars)
    args.add("--")
    args.add_all(p.collect_jars.compile_jars)

    ctx.actions.run(
        mnemonic = "DiscoverTests",
        inputs = worker_inputs + p.collect_jars.compile_jars.to_list() + p.compile.full_jars,
        outputs = [output],
        executable = worker.files_to_run.executable,
        input_manifests = worker_input_manifests,
        execution_requirements = {"supports-workers": "1"},
        arguments = [args],
    )

    return struct(
        files = depset([output]),
        jvm_flags = [
            "-DDiscoveredTestsResult={}".format(output.short_path),
        ],
        runfiles = depset([output]),
    )
