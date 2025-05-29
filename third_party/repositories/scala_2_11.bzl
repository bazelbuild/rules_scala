"""Maven artifact repository metadata.

Mostly generated and updated by scripts/create_repository.py.
"""

scala_version = "2.11.12"

artifacts = {
    "com_geirsson_metaconfig_core": {
        "artifact": "com.geirsson:metaconfig-core_2.11:0.9.10",
        "sha256": "c8b8f64e42d52a0bd7af1094c46c1fc15773f3bc62d014b833509679e857035b",
        "deps": [
            "@com_lihaoyi_pprint",
            "@org_scala_lang_modules_scala_collection_compat",
            "@io_bazel_rules_scala_scala_library",
            "@org_typelevel_paiges_core",
        ],
    },
    "com_geirsson_metaconfig_typesafe_config": {
        "artifact": "com.geirsson:metaconfig-typesafe-config_2.11:0.9.10",
        "sha256": "6260f0994d06d666b931d739635fe94b29dbcb758c421553bc4fab8822d650aa",
        "deps": [
            "@com_geirsson_metaconfig_core",
            "@com_typesafe_config",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_github_jnr_jffi_native": {
        "testonly": True,
        "artifact": "com.github.jnr:jffi:jar:native:1.2.17",
        "sha256": "4eb582bc99d96c8df92fc6f0f608fd123d278223982555ba16219bf8be9f75a9",
    },
    "com_google_android_annotations": {
        "artifact": "com.google.android:annotations:4.1.1.4",
        "sha256": "ba734e1e84c09d615af6a09d33034b4f0442f8772dec120efb376d86a565ae15",
    },
    "com_google_code_findbugs_jsr305": {
        "artifact": "com.google.code.findbugs:jsr305:3.0.2",
        "sha256": "766ad2a0783f2687962c8ad74ceecc38a28b9f72a2d085ee438b7813e928d0c7",
    },
    "com_google_code_gson_gson": {
        "artifact": "com.google.code.gson:gson:2.11.0",
        "sha256": "57928d6e5a6edeb2abd3770a8f95ba44dce45f3b23b7a9dc2b309c581552a78b",
        "deps": [
            "@com_google_errorprone_error_prone_annotations",
        ],
    },
    "com_google_errorprone_error_prone_annotations": {
        "artifact": "com.google.errorprone:error_prone_annotations:2.36.0",
        "sha256": "77440e270b0bc9a249903c5a076c36a722c4886ca4f42675f2903a1c53ed61a5",
    },
    "com_google_guava_guava_21_0": {
        "testonly": True,
        "artifact": "com.google.guava:guava:21.0",
        "sha256": "972139718abc8a4893fa78cba8cf7b2c903f35c97aaf44fa3031b0669948b480",
        "deps": [
            "@org_springframework_spring_core",
        ],
    },
    "com_google_guava_guava_21_0_with_file": {
        "testonly": True,
        "artifact": "com.google.guava:guava:21.0",
        "sha256": "972139718abc8a4893fa78cba8cf7b2c903f35c97aaf44fa3031b0669948b480",
    },
    "com_google_j2objc_j2objc_annotations": {
        "artifact": "com.google.j2objc:j2objc-annotations:3.0.0",
        "sha256": "88241573467ddca44ffd4d74aa04c2bbfd11bf7c17e0c342c94c9de7a70a7c64",
    },
    "com_google_protobuf_protobuf_java": {
        "artifact": "com.google.protobuf:protobuf-java:4.31.1",
        "sha256": "d60dfe7c68a0d38a248cca96924f289dc7e1966a887ee7cae397701af08575ae",
    },
    "com_lihaoyi_fansi": {
        "artifact": "com.lihaoyi:fansi_2.11:0.2.6",
        "sha256": "63878260e23a1e28ecd8d6987d5feda9d72507b476137b9f642ac2c75035a9c8",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_lihaoyi_fastparse": {
        "artifact": "com.lihaoyi:fastparse_2.11:2.1.2",
        "sha256": "5c5d81f90ada03ac5b21b161864a52558133951031ee5f6bf4d979e8baa03628",
        "deps": [
            "@com_lihaoyi_sourcecode",
        ],
    },
    "com_lihaoyi_pprint": {
        "artifact": "com.lihaoyi:pprint_2.11:0.5.4",
        "sha256": "9b31150ee7f07212a825e02fca56e0999789d2b8ec720a84b75ce29ca7e195b5",
        "deps": [
            "@com_lihaoyi_fansi",
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_lihaoyi_sourcecode": {
        "artifact": "com.lihaoyi:sourcecode_2.11:0.2.1",
        "sha256": "4b45e8b4efee81457b97439e250cd80a67f1ddbe896735cca0f05c88ebead58c",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_twitter__scalding_date": {
        "testonly": True,
        "artifact": "com.twitter:scalding-date_2.11:0.17.0",
        "sha256": "bf743cd6d224a4568d6486a2b794143e23145d2afd7a1d2de412d49e45bdb308",
    },
    "com_typesafe_config": {
        "artifact": "com.typesafe:config:1.2.1",
        "sha256": "c160fbd78f51a0c2375a794e435ce2112524a6871f64d0331895e9e26ee8b9ee",
    },
    "io_bazel_rules_scala_failureaccess": {
        "artifact": "com.google.guava:failureaccess:1.0.3",
        "sha256": "cbfc3906b19b8f55dd7cfd6dfe0aa4532e834250d7f080bd8d211a3e246b59cb",
    },
    "io_bazel_rules_scala_guava": {
        "artifact": "com.google.guava:guava:33.4.8-jre",
        "sha256": "f3d7f57f67fd622f4d468dfdd692b3a5e3909246c28017ac3263405f0fe617ed",
        "deps": [
            "@com_google_errorprone_error_prone_annotations",
            "@com_google_j2objc_j2objc_annotations",
            "@io_bazel_rules_scala_failureaccess",
            "@org_jspecify_jspecify",
        ],
    },
    "io_bazel_rules_scala_javax_annotation_api": {
        "artifact": "javax.annotation:javax.annotation-api:1.3.2",
        "sha256": "e04ba5195bcd555dc95650f7cc614d151e4bcd52d29a10b8aa2197f3ab89ab9b",
    },
    "io_bazel_rules_scala_junit_junit": {
        "artifact": "junit:junit:4.12",
        "sha256": "59721f0805e223d84b90677887d9ff567dc534d7c502ca903c0c2b17f05c116a",
    },
    "io_bazel_rules_scala_mustache": {
        "artifact": "com.github.spullara.mustache.java:compiler:0.8.18",
        "sha256": "ddabc1ef897fd72319a761d29525fd61be57dc25d04d825f863f83cc89000e66",
    },
    "io_bazel_rules_scala_net_sf_jopt_simple_jopt_simple": {
        "artifact": "net.sf.jopt-simple:jopt-simple:5.0.4",
        "sha256": "df26cc58f235f477db07f753ba5a3ab243ebe5789d9f89ecf68dd62ea9a66c28",
    },
    "io_bazel_rules_scala_org_apache_commons_commons_math3": {
        "artifact": "org.apache.commons:commons-math3:3.6.1",
        "sha256": "1e56d7b058d28b65abd256b8458e3885b674c1d588fa43cd7d1cbb9c7ef2b308",
    },
    "io_bazel_rules_scala_org_hamcrest_hamcrest_core": {
        "artifact": "org.hamcrest:hamcrest-core:1.3",
        "sha256": "66fdef91e9739348df7a096aa384a5685f4e875584cce89386a7a47251c4d8e9",
    },
    "io_bazel_rules_scala_org_openjdk_jmh_jmh_core": {
        "artifact": "org.openjdk.jmh:jmh-core:1.36",
        "sha256": "f90974e37d0da8886b5c05e6e3e7e20556900d747c5a41c1023b47c3301ea73c",
    },
    "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_asm": {
        "artifact": "org.openjdk.jmh:jmh-generator-asm:1.36",
        "sha256": "7460b11b823dee74b3e19617d35d5911b01245303d6e31c30f83417cfc2f54b5",
    },
    "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_reflection": {
        "artifact": "org.openjdk.jmh:jmh-generator-reflection:1.36",
        "sha256": "a9c72760e12c199e2a2c28f1a126ebf0cc5b51c0b58d46472596fc32f7f92534",
    },
    "io_bazel_rules_scala_org_ow2_asm_asm": {
        "artifact": "org.ow2.asm:asm:9.0",
        "sha256": "0df97574914aee92fd349d0cb4e00f3345d45b2c239e0bb50f0a90ead47888e0",
    },
    "io_bazel_rules_scala_org_specs2_specs2_common": {
        "artifact": "org.specs2:specs2-common_2.11:4.4.1",
        "sha256": "52d7c0da58725606e98c6e8c81d2efe632053520a25da9140116d04a4abf9d2c",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_fp",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_core": {
        "artifact": "org.specs2:specs2-core_2.11:4.4.1",
        "sha256": "8e95cb7e347e7a87e7a80466cbd88419ece1aaacb35c32e8bd7d299a623b31b9",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
            "@io_bazel_rules_scala_org_specs2_specs2_matcher",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_fp": {
        "artifact": "org.specs2:specs2-fp_2.11:4.4.1",
        "sha256": "e43006fdd0726ffcd1e04c6c4d795176f5f765cc787cc09baebe1fcb009e4462",
    },
    "io_bazel_rules_scala_org_specs2_specs2_junit": {
        "artifact": "org.specs2:specs2-junit_2.11:4.4.1",
        "sha256": "a8549d52e87896624200fe35ef7b841c1c698a8fb5d97d29bf082762aea9bb72",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_core",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_matcher": {
        "artifact": "org.specs2:specs2-matcher_2.11:4.4.1",
        "sha256": "448e5ab89d4d650d23030fdbee66a010a07dcac5e4c3e73ef5fe39ca1aace1cd",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
        ],
    },
    "io_bazel_rules_scala_scala_compiler": {
        "artifact": "org.scala-lang:scala-compiler:2.11.12",
        "sha256": "3e892546b72ab547cb77de4d840bcfd05c853e73390fed7370a8f19acb0735a0",
        "deps": [
            "@io_bazel_rules_scala_scala_parser_combinators",
            "@io_bazel_rules_scala_scala_xml",
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
        ],
    },
    "io_bazel_rules_scala_scala_library": {
        "artifact": "org.scala-lang:scala-library:2.11.12",
        "sha256": "0b3d6fd42958ee98715ba2ec5fe221f4ca1e694d7c981b0ae0cd68e97baf6dce",
    },
    "io_bazel_rules_scala_scala_parser_combinators": {
        "artifact": "org.scala-lang.modules:scala-parser-combinators_2.11:1.1.2",
        "sha256": "3e0889e95f5324da6420461f7147cb508241ed957ac5cfedc25eef19c5448f26",
    },
    "io_bazel_rules_scala_scala_reflect": {
        "artifact": "org.scala-lang:scala-reflect:2.11.12",
        "sha256": "6ba385b450a6311a15c918cf8688b9af9327c6104f0ecbd35933cfcd3095fe04",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scala_xml": {
        "artifact": "org.scala-lang.modules:scala-xml_2.11:1.3.0",
        "sha256": "0f6dc9b10f2ed3b1cc461330c17e76a2cb7c9874289454407551d4bace712d66",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scalactic": {
        "artifact": "org.scalactic:scalactic_2.11:3.2.19",
        "sha256": "20708ca81baeed428eaf9453f038a37dadba376f5d05e85a3fb882e303040d3d",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
        ],
    },
    "io_bazel_rules_scala_scalatest": {
        "artifact": "org.scalatest:scalatest_2.11:3.2.19",
        "sha256": "6f01d1f8cc8063e989900c954f3378c7cd18b7ccb5c3e54242e1dec7eea0472b",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
            "@io_bazel_rules_scala_scalatest_diagrams",
            "@io_bazel_rules_scala_scalatest_featurespec",
            "@io_bazel_rules_scala_scalatest_flatspec",
            "@io_bazel_rules_scala_scalatest_freespec",
            "@io_bazel_rules_scala_scalatest_funspec",
            "@io_bazel_rules_scala_scalatest_funsuite",
            "@io_bazel_rules_scala_scalatest_matchers_core",
            "@io_bazel_rules_scala_scalatest_mustmatchers",
            "@io_bazel_rules_scala_scalatest_propspec",
            "@io_bazel_rules_scala_scalatest_refspec",
            "@io_bazel_rules_scala_scalatest_shouldmatchers",
            "@io_bazel_rules_scala_scalatest_wordspec",
        ],
    },
    "io_bazel_rules_scala_scalatest_compatible": {
        "artifact": "org.scalatest:scalatest-compatible:3.2.19",
        "sha256": "5dc6b8fa5396fe9e1a7c2b72df174a8eb3e92770cdc3e70636d3eba673cd0da3",
    },
    "io_bazel_rules_scala_scalatest_core": {
        "artifact": "org.scalatest:scalatest-core_2.11:3.2.19",
        "sha256": "763ba4408a4256a1a430b11f15b4d6f1c5f7fcf0be192a6ef4fd1124008330b7",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scala_xml",
            "@io_bazel_rules_scala_scalactic",
            "@io_bazel_rules_scala_scalatest_compatible",
        ],
    },
    "io_bazel_rules_scala_scalatest_diagrams": {
        "artifact": "org.scalatest:scalatest-diagrams_2.11:3.2.19",
        "sha256": "07c86a616aaec57eb211a7cf7a47f7d3cc93f322042419c1f4daef687b5185c4",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_featurespec": {
        "artifact": "org.scalatest:scalatest-featurespec_2.11:3.2.19",
        "sha256": "acc41aa36c8c252a7e0332a3f03b66c09120ff8b7814eab39737ddc11cd9a4d0",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_flatspec": {
        "artifact": "org.scalatest:scalatest-flatspec_2.11:3.2.19",
        "sha256": "1eab3d1d54b8708869c493223db8deee2c0b3b40ce7ae3a79c82f7c2e0451d39",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_freespec": {
        "artifact": "org.scalatest:scalatest-freespec_2.11:3.2.19",
        "sha256": "499508dad83c33f1347f9a7ef6590ebbdba5275c0dba47df1ce1f048a518d1a5",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_funspec": {
        "artifact": "org.scalatest:scalatest-funspec_2.11:3.2.19",
        "sha256": "933d154f2f6fc7e86954760cd534e189ab5c8eab790fc66e41fabb9df4da3bb7",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_funsuite": {
        "artifact": "org.scalatest:scalatest-funsuite_2.11:3.2.19",
        "sha256": "6f7d1679d8d375603b836fab1972d88601d26e1e1322856feb54947b4a534935",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_matchers_core": {
        "artifact": "org.scalatest:scalatest-matchers-core_2.11:3.2.19",
        "sha256": "509771ba2bc172882e0db9d4e8437a032753d4d5a66f9dc61e7f453ecc0057fb",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_mustmatchers": {
        "artifact": "org.scalatest:scalatest-mustmatchers_2.11:3.2.19",
        "sha256": "5cd41cc8607163df9d15d26e12985fa88803c98fefa19b77f8ce466e39062795",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_matchers_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_propspec": {
        "artifact": "org.scalatest:scalatest-propspec_2.11:3.2.19",
        "sha256": "f95779953fd8a5291f66348d999228464494dffbf97a5193583ace1adf9c1ad5",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_refspec": {
        "artifact": "org.scalatest:scalatest-refspec_2.11:3.2.19",
        "sha256": "0b8f0945629d9ea8f0b0f4d9840d4f86df5abba53888b48e559971b887c42946",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_shouldmatchers": {
        "artifact": "org.scalatest:scalatest-shouldmatchers_2.11:3.2.19",
        "sha256": "6537c4948ff42cac2eaa7e3d88dd699bff891c574e252ba65372c7d5ed1cd1f9",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_matchers_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_wordspec": {
        "artifact": "org.scalatest:scalatest-wordspec_2.11:3.2.19",
        "sha256": "eacabc4e1b08cf704ad194b10b325590bc59173832af3e6d3109dd9b900f9fd6",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scopt": {
        "artifact": "com.github.scopt:scopt_2.11:4.0.0-RC2",
        "sha256": "956dfc89d3208e4a6d8bbfe0205410c082cee90c4ce08be30f97c044dffc3435",
    },
    "io_bazel_rules_scala_scrooge_core": {
        "artifact": "com.twitter:scrooge-core_2.11:21.2.0",
        "sha256": "d6cef1408e34b9989ea8bc4c567dac922db6248baffe2eeaa618a5b354edd2bb",
    },
    "io_bazel_rules_scala_scrooge_generator": {
        "artifact": "com.twitter:scrooge-generator_2.11:21.2.0",
        "sha256": "87094f01df2c0670063ab6ebe156bb1a1bcdabeb95bc45552660b030287d6acb",
        "runtime_deps": [
            "@io_bazel_rules_scala_guava",
            "@io_bazel_rules_scala_mustache",
            "@io_bazel_rules_scala_scopt",
        ],
    },
    "io_bazel_rules_scala_util_core": {
        "artifact": "com.twitter:util-core_2.11:21.2.0",
        "sha256": "31c33d494ca5a877c1e5b5c1f569341e1d36e7b2c8b3fb0356fb2b6d4a3907ca",
    },
    "io_bazel_rules_scala_util_logging": {
        "artifact": "com.twitter:util-logging_2.11:21.2.0",
        "sha256": "f3b62465963fbf0fe9860036e6255337996bb48a1a3f21a29503a2750d34f319",
    },
    "libthrift": {
        "artifact": "org.apache.thrift:libthrift:0.10.0",
        "sha256": "8591718c1884ac8001b4c5ca80f349c0a6deec691de0af720c5e3bc3a581dada",
    },
    "org_apache_commons_commons_lang_3_5": {
        "testonly": True,
        "artifact": "org.apache.commons:commons-lang3:3.5",
        "sha256": "8ac96fc686512d777fca85e144f196cd7cfe0c0aec23127229497d1a38ff651c",
    },
    "org_checkerframework_checker_qual": {
        "artifact": "org.checkerframework:checker-qual:3.43.0",
        "sha256": "3fbc2e98f05854c3df16df9abaa955b91b15b3ecac33623208ed6424640ef0f6",
    },
    "org_codehaus_mojo_animal_sniffer_annotations": {
        "artifact": "org.codehaus.mojo:animal-sniffer-annotations:1.24",
        "sha256": "c720e6e5bcbe6b2f48ded75a47bccdb763eede79d14330102e0d352e3d89ed92",
    },
    "org_jspecify_jspecify": {
        "artifact": "org.jspecify:jspecify:1.0.0",
        "sha256": "1fad6e6be7557781e4d33729d49ae1cdc8fdda6fe477bb0cc68ce351eafdfbab",
    },
    "org_scala_lang_modules_scala_collection_compat": {
        "artifact": "org.scala-lang.modules:scala-collection-compat_2.11:2.1.2",
        "sha256": "e9667b8b7276aeb42599f536fe4d7caab06eabc55e9995572267ad60c7a11c8b",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scala_lang_scalap": {
        "artifact": "org.scala-lang:scalap:2.11.12",
        "sha256": "a6dd7203ce4af9d6185023d5dba9993eb8e80584ff4b1f6dec574a2aba4cd2b7",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler",
        ],
    },
    "org_scala_sbt_test_interface": {
        "artifact": "org.scala-sbt:test-interface:1.0",
        "sha256": "15f70b38bb95f3002fec9aea54030f19bb4ecfbad64c67424b5e5fea09cd749e",
    },
    "org_scalacheck_scalacheck": {
        "artifact": "org.scalacheck:scalacheck_2.11:1.14.3",
        "sha256": "3cbc95bb615f1a384b8c4406dfc42b225499f08adf7639de11566069e47d44cf",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_sbt_test_interface",
        ],
    },
    "org_scalameta_common": {
        "artifact": "org.scalameta:common_2.11:4.3.22",
        "sha256": "eaf3bc9c5168a52b4da0e1d39ea1ef2570a675b7de56cce7f64389835b20ac09",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_fastparse": {
        "artifact": "org.scalameta:fastparse_2.11:1.0.1",
        "sha256": "49ecc30a4b47efc0038099da0c97515cf8f754ea631ea9f9935b36ca7d41b733",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_fastparse_utils",
        ],
    },
    "org_scalameta_fastparse_utils": {
        "artifact": "org.scalameta:fastparse-utils_2.11:1.0.1",
        "sha256": "93f58db540e53178a686621f7a9c401307a529b68e051e38804394a2a86cea94",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_parsers": {
        "artifact": "org.scalameta:parsers_2.11:4.3.22",
        "sha256": "c5d2d0e95c5e0fa49c0ad8e269a7e431cd74ec56b7c6bd080a39d102c36cc36d",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_trees",
        ],
    },
    "org_scalameta_scalafmt_core": {
        "artifact": "org.scalameta:scalafmt-core_2.11:2.7.5",
        "sha256": "25cd19d57e0d5e23574ba4a3a200c31432f7ebd0e55ca565cfd06ad71482d940",
        "deps": [
            "@com_geirsson_metaconfig_core",
            "@com_geirsson_metaconfig_typesafe_config",
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@org_scalameta_scalameta",
        ],
    },
    "org_scalameta_scalameta": {
        "artifact": "org.scalameta:scalameta_2.11:4.3.22",
        "sha256": "c66ea80ff72fbb1a5cc0c11c6365106c9750ad05f8cf17adb88ac8b10925ef72",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_scalap",
            "@org_scalameta_parsers",
        ],
    },
    "org_scalameta_semanticdb_scalac": {
        "artifact": "org.scalameta:semanticdb-scalac_2.11.12:4.9.9",
        "sha256": "1adfd051c4b4e1c69a49492cbcf558011beba78e79aaeef1319d29e8408e341d",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_trees": {
        "artifact": "org.scalameta:trees_2.11:4.3.22",
        "sha256": "59c3c27a579d893118e4e6b29db7b17fec010b3bb63cafe995be50fe907d4026",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_common",
            "@org_scalameta_fastparse",
        ],
    },
    "org_scalatestplus_scalacheck_1_14": {
        "artifact": "org.scalatestplus:scalacheck-1-14_2.11:3.1.1.1",
        "sha256": "1acd4045cc97e19bc0cdbdfba387be421dfe9406564834b509a1e3cf3c50cb43",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scalatest",
            "@org_scalacheck_scalacheck",
        ],
    },
    "org_springframework_spring_core": {
        "testonly": True,
        "artifact": "org.springframework:spring-core:5.1.5.RELEASE",
        "sha256": "f771b605019eb9d2cf8f60c25c050233e39487ff54d74c93d687ea8de8b7285a",
    },
    "org_springframework_spring_tx": {
        "testonly": True,
        "artifact": "org.springframework:spring-tx:5.1.5.RELEASE",
        "sha256": "666f72b73c7e6b34e5bb92a0d77a14cdeef491c00fcb07a1e89eb62b08500135",
        "deps": [
            "@org_springframework_spring_core",
        ],
    },
    "org_typelevel__cats_core": {
        "testonly": True,
        "artifact": "org.typelevel:cats-core_2.11:0.9.0",
        "sha256": "3fda7a27114b0d178107ace5c2cf04e91e9951810690421768e65038999ffca5",
    },
    "org_typelevel_kind_projector": {
        "artifact": "org.typelevel:kind-projector_2.11.12:0.13.3",
        "sha256": "fc40476381233d532ed26b64a3643c1bda792d2900a7df697d676dde82e4408d",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_typelevel_paiges_core": {
        "artifact": "org.typelevel:paiges-core_2.11:0.3.0",
        "sha256": "fa697cb6d1e03cb143183c45cc543734e7600dcb4dee63005738d28a722c202e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "scala_proto_rules_disruptor": {
        "artifact": "com.lmax:disruptor:3.4.2",
        "sha256": "f412ecbb235c2460b45e63584109723dea8d94b819c78c9bfc38f50cba8546c0",
    },
    "scala_proto_rules_grpc_api": {
        "artifact": "io.grpc:grpc-api:1.73.0",
        "sha256": "bae13d4e4716a0955d316b5fcb75582504325e5b11ac946b13b64b4fce19bc6e",
        "deps": [
            "@com_google_code_findbugs_jsr305",
            "@com_google_errorprone_error_prone_annotations",
            "@io_bazel_rules_scala_guava",
        ],
    },
    "scala_proto_rules_grpc_context": {
        "artifact": "io.grpc:grpc-context:1.73.0",
        "sha256": "d8d6911e225b55501692651272ce961ba5be1f76662ceb7f0aa79ecce8f63f25",
        "deps": [
            "@scala_proto_rules_grpc_api",
        ],
    },
    "scala_proto_rules_grpc_core": {
        "artifact": "io.grpc:grpc-core:1.73.0",
        "sha256": "cffb55f1e7268e160647e88da142c09c6175ff72970c64f7cb411d78eb661663",
        "deps": [
            "@com_google_android_annotations",
            "@com_google_code_gson_gson",
            "@com_google_errorprone_error_prone_annotations",
            "@io_bazel_rules_scala_guava",
            "@org_codehaus_mojo_animal_sniffer_annotations",
            "@scala_proto_rules_grpc_api",
            "@scala_proto_rules_grpc_context",
            "@scala_proto_rules_perfmark_api",
        ],
    },
    "scala_proto_rules_grpc_netty": {
        "artifact": "io.grpc:grpc-netty:1.73.0",
        "sha256": "435f8ab1e920c0d0decc6a9192389ad64c7820a55bd55267efd15c965f9e0fa5",
        "deps": [
            "@com_google_errorprone_error_prone_annotations",
            "@io_bazel_rules_scala_guava",
            "@org_codehaus_mojo_animal_sniffer_annotations",
            "@scala_proto_rules_grpc_api",
            "@scala_proto_rules_grpc_core",
            "@scala_proto_rules_grpc_util",
            "@scala_proto_rules_netty_codec_http2",
            "@scala_proto_rules_netty_handler_proxy",
            "@scala_proto_rules_netty_transport_native_unix_common",
            "@scala_proto_rules_perfmark_api",
        ],
    },
    "scala_proto_rules_grpc_protobuf": {
        "artifact": "io.grpc:grpc-protobuf:1.73.0",
        "sha256": "5c0ca9e321c02845c47dc6edcef9f22e49015cef7753c54012f5398425163c08",
        "deps": [
            "@com_google_code_findbugs_jsr305",
            "@com_google_protobuf_protobuf_java",
            "@io_bazel_rules_scala_guava",
            "@scala_proto_rules_grpc_api",
            "@scala_proto_rules_grpc_protobuf_lite",
            "@scala_proto_rules_proto_google_common_protos",
        ],
    },
    "scala_proto_rules_grpc_protobuf_lite": {
        "artifact": "io.grpc:grpc-protobuf-lite:1.73.0",
        "sha256": "de8ce5309713e72bb57d5ff2dabdb4c173ae4872bd1439b9c3d3f93430b407d9",
        "deps": [
            "@com_google_code_findbugs_jsr305",
            "@io_bazel_rules_scala_guava",
            "@scala_proto_rules_grpc_api",
        ],
    },
    "scala_proto_rules_grpc_stub": {
        "artifact": "io.grpc:grpc-stub:1.73.0",
        "sha256": "050fe139de47d8937e6b0080e8dff3d0f42df6782f147c10bb298c0e9cd94b2f",
        "deps": [
            "@com_google_errorprone_error_prone_annotations",
            "@io_bazel_rules_scala_guava",
            "@org_codehaus_mojo_animal_sniffer_annotations",
            "@scala_proto_rules_grpc_api",
        ],
    },
    "scala_proto_rules_grpc_util": {
        "artifact": "io.grpc:grpc-util:1.73.0",
        "sha256": "b7df6cbcc30b7a3219f06483a9a9d320a431beda8a1ace5b16d879f84112373f",
        "deps": [
            "@io_bazel_rules_scala_guava",
            "@org_codehaus_mojo_animal_sniffer_annotations",
            "@scala_proto_rules_grpc_api",
            "@scala_proto_rules_grpc_core",
        ],
    },
    "scala_proto_rules_instrumentation_api": {
        "artifact": "com.google.instrumentation:instrumentation-api:0.3.0",
        "sha256": "671f7147487877f606af2c7e39399c8d178c492982827305d3b1c7f5b04f1145",
    },
    "scala_proto_rules_netty_buffer": {
        "artifact": "io.netty:netty-buffer:4.1.110.Final",
        "sha256": "46d74e79125aacc055c31f18152fdc5d4a569aa8d60091203d0baa833973ac3c",
        "deps": [
            "@scala_proto_rules_netty_common",
        ],
    },
    "scala_proto_rules_netty_codec": {
        "artifact": "io.netty:netty-codec:4.1.110.Final",
        "sha256": "9eccce9a8d827bb8ce84f9c3183fec58bd1c96a51010cf711297746034af3701",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_netty_codec_http": {
        "artifact": "io.netty:netty-codec-http:4.1.110.Final",
        "sha256": "dc0d6af5054630a70ff0ef354f20aa7a6e46738c9fc5636ed3d4fe77e38bd48d",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_codec",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_handler",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_netty_codec_http2": {
        "artifact": "io.netty:netty-codec-http2:4.1.110.Final",
        "sha256": "b546c75445a487bb7bcd5a94779caecce33582cf7be31b8b39fc0e65b1ee26fc",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_codec",
            "@scala_proto_rules_netty_codec_http",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_handler",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_netty_codec_socks": {
        "artifact": "io.netty:netty-codec-socks:4.1.110.Final",
        "sha256": "976052a3c9bb280bc6d99f3a29e6404677cf958c3de05b205093d38c006b880c",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_codec",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_netty_common": {
        "artifact": "io.netty:netty-common:4.1.110.Final",
        "sha256": "9851ec66548b9e0d41164ce98943cdd4bbe305f68ddbd24eae52e4501a0d7b1a",
    },
    "scala_proto_rules_netty_handler": {
        "artifact": "io.netty:netty-handler:4.1.110.Final",
        "sha256": "d5a08d7de364912e4285968de4d4cce3f01da4bb048d5c6937e5f2af1f8e148a",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_codec",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_resolver",
            "@scala_proto_rules_netty_transport",
            "@scala_proto_rules_netty_transport_native_unix_common",
        ],
    },
    "scala_proto_rules_netty_handler_proxy": {
        "artifact": "io.netty:netty-handler-proxy:4.1.110.Final",
        "sha256": "ad54ab4fe9c47ef3e723d71251126db53e8db543871adb9eafc94446539eff52",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_codec",
            "@scala_proto_rules_netty_codec_http",
            "@scala_proto_rules_netty_codec_socks",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_netty_resolver": {
        "artifact": "io.netty:netty-resolver:4.1.110.Final",
        "sha256": "a2e9b4ae7caa92fc5bd747e11d1dec20d81b18fc00959554302244ac5c56ce70",
        "deps": [
            "@scala_proto_rules_netty_common",
        ],
    },
    "scala_proto_rules_netty_transport": {
        "artifact": "io.netty:netty-transport:4.1.110.Final",
        "sha256": "a42dd68390ca14b4ff2d40628a096c76485b4adb7c19602d5289321a0669e704",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_resolver",
        ],
    },
    "scala_proto_rules_netty_transport_native_unix_common": {
        "artifact": "io.netty:netty-transport-native-unix-common:4.1.110.Final",
        "sha256": "51717bb7471141950390c6713a449fdb1054d07e60737ee7dda7083796cdee48",
        "deps": [
            "@scala_proto_rules_netty_buffer",
            "@scala_proto_rules_netty_common",
            "@scala_proto_rules_netty_transport",
        ],
    },
    "scala_proto_rules_opencensus_api": {
        "artifact": "io.opencensus:opencensus-api:0.22.1",
        "sha256": "62a0503ee81856ba66e3cde65dee3132facb723a4fa5191609c84ce4cad36127",
    },
    "scala_proto_rules_opencensus_contrib_grpc_metrics": {
        "artifact": "io.opencensus:opencensus-contrib-grpc-metrics:0.22.1",
        "sha256": "3f6f4d5bd332c516282583a01a7c940702608a49ed6e62eb87ef3b1d320d144b",
    },
    "scala_proto_rules_opencensus_impl": {
        "artifact": "io.opencensus:opencensus-impl:0.22.1",
        "sha256": "9e8b209da08d1f5db2b355e781b9b969b2e0dab934cc806e33f1ab3baed4f25a",
    },
    "scala_proto_rules_opencensus_impl_core": {
        "artifact": "io.opencensus:opencensus-impl-core:0.22.1",
        "sha256": "04607d100e34bacdb38f93c571c5b7c642a1a6d873191e25d49899668514db68",
    },
    "scala_proto_rules_perfmark_api": {
        "artifact": "io.perfmark:perfmark-api:0.27.0",
        "sha256": "c7b478503ec524e55df19b424d46d27c8a68aeb801664fadd4f069b71f52d0f6",
    },
    "scala_proto_rules_proto_google_common_protos": {
        "artifact": "com.google.api.grpc:proto-google-common-protos:2.57.0",
        "sha256": "475d3d14197b45a02e8731a5d9736f5f859d459025bc19c7b7f2f74a0f6cb320",
        "deps": [
            "@com_google_protobuf_protobuf_java",
        ],
    },
    "scala_proto_rules_scalapb_compilerplugin": {
        "artifact": "com.thesamet.scalapb:compilerplugin_2.11:0.9.8",
        "sha256": "9fda69065da447cf91aa3c923a95b80c2bdb9f46f95b2c14af97f533b099b5a9",
        "deps": [
            "@com_google_protobuf_protobuf_java",
            "@io_bazel_rules_scala_scala_library",
            "@scala_proto_rules_scalapb_protoc_bridge",
        ],
    },
    "scala_proto_rules_scalapb_lenses": {
        "artifact": "com.thesamet.scalapb:lenses_2.11:0.9.8",
        "sha256": "20556c018aa55b196fef2e54d6f2a14d88821be8d1ba58e2c977fffb01d78972",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "scala_proto_rules_scalapb_protoc_bridge": {
        "artifact": "com.thesamet.scalapb:protoc-bridge_2.11:0.7.14",
        "sha256": "314e34bf331b10758ff7a780560c8b5a5b09e057695a643e33ab548e3d94aa03",
    },
    "scala_proto_rules_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_2.11:0.9.8",
        "sha256": "c973046bff0e396dce25ce56e567a88b84e4b6cde0280964d23a2c1133f09a49",
        "deps": [
            "@com_google_protobuf_protobuf_java",
            "@com_lihaoyi_fastparse",
            "@scala_proto_rules_scalapb_lenses",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "scala_proto_rules_scalapb_runtime_grpc": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime-grpc_2.11:0.9.8",
        "sha256": "6541e7f62c03dd6e63a77943c568b0719b3137e0ada135ad3ef045f7f99eb953",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@scala_proto_rules_grpc_protobuf",
            "@scala_proto_rules_grpc_stub",
            "@scala_proto_rules_scalapb_runtime",
        ],
    },
}
