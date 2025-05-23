load("@rules_java//java/common:java_info.bzl", "JavaInfo")

#
# PHASE: jvm flags
#
# DOCUMENT THIS
#
def phase_jvm_flags(ctx, p):
    if ctx.attr.tests_from:
        archives = _get_test_archive_jars(ctx, ctx.attr.tests_from)
    else:
        archives = p.compile.merged_provider.runtime_output_jars

    serialized_archives = _serialize_archives_short_path(archives)
    test_suite = _gen_test_suite_flags_based_on_prefixes_and_suffixes(
        ctx,
        serialized_archives,
    )
    return [
        "-ea",
        test_suite.archiveFlag,
        test_suite.prefixesFlag,
        test_suite.suffixesFlag,
        test_suite.printFlag,
        test_suite.testSuiteFlag,
    ]

def _gen_test_suite_flags_based_on_prefixes_and_suffixes(ctx, archives):
    return struct(
        archiveFlag = "-Dbazel.discover.classes.archives.file.paths=%s" %
                      archives,
        prefixesFlag = "-Dbazel.discover.classes.prefixes=%s" % ",".join(
            ctx.attr.prefixes,
        ),
        printFlag = "-Dbazel.discover.classes.print.discovered=%s" %
                    ctx.attr.print_discovered_classes,
        suffixesFlag = "-Dbazel.discover.classes.suffixes=%s" % ",".join(
            ctx.attr.suffixes,
        ),
        testSuiteFlag = "-Dbazel.test_suite=%s" % ctx.attr.suite_class,
    )

def _serialize_archives_short_path(archives):
    archives_short_path = ""
    for archive in archives:
        archives_short_path += archive.short_path + ","
    return archives_short_path[:-1]  #remove redundant comma

def _get_test_archive_jars(ctx, test_archives):
    flattened_list = []
    for archive in test_archives:
        class_jars = [java_output.class_jar for java_output in archive[JavaInfo].outputs.jars]
        flattened_list.extend(class_jars)
    return flattened_list
