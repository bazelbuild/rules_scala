"""Maven artifact repository metadata.

Mostly generated and updated by scripts/create_repository.py.
"""

scala_version = "2.13.15"

artifacts = {
    "com_geirsson_metaconfig_core": {
        "artifact": "com.geirsson:metaconfig-core_2.13:0.12.0",
        "sha256": "2c91199ae5b206afdd52538f8c4da67c1794bcce0b5b06cf25679db00cf32c19",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@com_geirsson_metaconfig_pprint",
            "@org_scala_lang_modules_scala_collection_compat",
            "@org_typelevel_paiges_core",
        ],
    },
    "com_geirsson_metaconfig_pprint": {
        "artifact": "com.geirsson:metaconfig-pprint_2.13:0.12.0",
        "sha256": "6d8b0b4279116c11d4f29443bd2a9411bedb3d86ccaf964599a9420f530ed062",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler",
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@com_lihaoyi_fansi",
        ],
    },
    "com_geirsson_metaconfig_typesafe_config": {
        "artifact": "com.geirsson:metaconfig-typesafe-config_2.13:0.12.0",
        "sha256": "b4c5dbf863dadde363d8bd24333ce1091fec94fc5b88efd04607a26f3eab61b8",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@com_geirsson_metaconfig_core",
            "@com_typesafe_config",
        ],
    },
    "com_github_jnr_jffi_native": {
        "testonly": True,
        "artifact": "com.github.jnr:jffi:jar:native:1.2.17",
        "sha256": "4eb582bc99d96c8df92fc6f0f608fd123d278223982555ba16219bf8be9f75a9",
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
    "com_google_protobuf_protobuf_java": {
        "artifact": "com.google.protobuf:protobuf-java:4.28.3",
        "sha256": "ba02977c0fef8b40af9f85fe69af362d8e13f2685b49a9752750b18da726157e",
    },
    "com_lihaoyi_fansi": {
        "artifact": "com.lihaoyi:fansi_2.13:0.4.0",
        "sha256": "0eb11a2a905d608033ec1642b0a9f0d8444daa4ad465f684b50bdc7e7a41bf53",
        "deps": [
            "@com_lihaoyi_sourcecode",
        ],
    },
    "com_lihaoyi_fastparse": {
        "artifact": "com.lihaoyi:fastparse_2.13:2.1.3",
        "sha256": "5064d3984aab8c48d2dbd6285787ac5c6d84a6bebfc02c6d431ce153cf91dec1",
        "deps": [
            "@com_lihaoyi_sourcecode",
        ],
    },
    "com_lihaoyi_geny": {
        "artifact": "com.lihaoyi:geny_2.13:0.6.5",
        "sha256": "ca3857a3f95266e0d87e1a1f26c8592c53c12ac7203f911759415f6c8a43df7d",
    },
    "com_lihaoyi_pprint": {
        "artifact": "com.lihaoyi:pprint_2.13:0.9.0",
        "sha256": "5dd36b65addcd47bccc68d36dd00bee93e2def439f1a36d02a450308e8d9a3d3",
        "deps": [
            "@com_lihaoyi_fansi",
            "@com_lihaoyi_sourcecode",
        ],
    },
    "com_lihaoyi_sourcecode": {
        "artifact": "com.lihaoyi:sourcecode_2.13:0.4.2",
        "sha256": "fbace2b994a7184f6b38ee98630be61f21948008a4a56cd83c7f86c1c1de743d",
    },
    "com_twitter__scalding_date": {
        "testonly": True,
        "artifact": "com.twitter:scalding-date_2.13:0.17.0",
        "sha256": "973a7198121cc8dac9eeb3f325c93c497fe3b682f68ba56e34c1b210af7b15b4",
    },
    "com_typesafe_config": {
        "artifact": "com.typesafe:config:1.4.1",
        "sha256": "4c0aa7e223c75c8840c41fc183d4cd3118140a1ee503e3e08ce66ed2794c948f",
    },
    "io_bazel_rules_scala_guava": {
        "artifact": "com.google.guava:guava:26.0-android",
        "sha256": "1d044ebb866ef08b7d04e998b4260c9b52fab6e6d6b68d207859486bb3686cd5",
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
        "artifact": "org.specs2:specs2-common_2.13:4.10.3",
        "sha256": "51636fb6a904b3c807de0673f283a971379c9886e03aedbecbf5d787b22346b0",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_fp",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_core": {
        "artifact": "org.specs2:specs2-core_2.13:4.10.3",
        "sha256": "9cc55eb11781c9b77689cf8175795fad34b060718b04a225fffb0613a181256b",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
            "@io_bazel_rules_scala_org_specs2_specs2_matcher",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_fp": {
        "artifact": "org.specs2:specs2-fp_2.13:4.10.3",
        "sha256": "48a908b345c93a3387ddd157ab338686513f450c7dd8afe0f32b6edc7ff15239",
    },
    "io_bazel_rules_scala_org_specs2_specs2_junit": {
        "artifact": "org.specs2:specs2-junit_2.13:4.10.3",
        "sha256": "49c4e7cf5483aada90852314983fc046f72092da1a4e7900ace6574444f581ea",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_core",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_matcher": {
        "artifact": "org.specs2:specs2-matcher_2.13:4.10.3",
        "sha256": "754465f58dad8f59b3bb299d5dc127027bf0c0c9ad25250260fc95abd705363b",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
        ],
    },
    "io_bazel_rules_scala_scala_compiler": {
        "artifact": "org.scala-lang:scala-compiler:2.13.15",
        "sha256": "4c200cd193c082bec14a2a2dffe6a1ba5f8130b1b27c79ee54c936dfcafc8ed9",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
        ],
    },
    "io_bazel_rules_scala_scala_library": {
        "artifact": "org.scala-lang:scala-library:2.13.15",
        "sha256": "8e4dbc3becf70d59c787118f6ad06fab6790136a0699cd6412bc9da3d336944e",
    },
    "io_bazel_rules_scala_scala_parallel_collections": {
        "artifact": "org.scala-lang.modules:scala-parallel-collections_2.13:1.0.4",
        "sha256": "68f266c4fa37cb20a76e905ad940e241190ce288b7e4a9877f1dd1261cd1a9a7",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scala_parser_combinators": {
        "artifact": "org.scala-lang.modules:scala-parser-combinators_2.13:1.1.2",
        "sha256": "5c285b72e6dc0a98e99ae0a1ceeb4027dab9adfa441844046bd3f19e0efdcb54",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scala_reflect": {
        "artifact": "org.scala-lang:scala-reflect:2.13.15",
        "sha256": "78d0cc350e1ee42d87c6e11cf5b0dc7bf0b70829c00aa38f27bfb019d439dc11",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scala_xml": {
        "artifact": "org.scala-lang.modules:scala-xml_2.13:2.1.0",
        "sha256": "d122cbf93115ee714570de6a9c18e53001fedb474911d4cb5091758ee51f053a",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_scalactic": {
        "artifact": "org.scalactic:scalactic_2.13:3.2.19",
        "sha256": "c27c33de17d450e29e66c16c5af4cfa33e8ffcf03c124f0a3d249d848cccd4af",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
        ],
    },
    "io_bazel_rules_scala_scalatest": {
        "artifact": "org.scalatest:scalatest_2.13:3.2.19",
        "sha256": "c37d97f16172d45b2aef0cebbe59dd2174b7d1ff2c2f272516707cf923015a52",
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
        "artifact": "org.scalatest:scalatest-core_2.13:3.2.19",
        "sha256": "30230081d029f6341b83fe7f157d336113e1c97497fe950169293d28a5bf2936",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scala_xml",
            "@io_bazel_rules_scala_scalactic",
            "@io_bazel_rules_scala_scalatest_compatible",
        ],
    },
    "io_bazel_rules_scala_scalatest_diagrams": {
        "artifact": "org.scalatest:scalatest-diagrams_2.13:3.2.19",
        "sha256": "a77294d3d5a564e1d8cd6550d4ac795ac042fa90efa91d139da123d7ec5f3bec",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_featurespec": {
        "artifact": "org.scalatest:scalatest-featurespec_2.13:3.2.19",
        "sha256": "58a44e6be12409596feab4d4123900ef2af55d3fcb72033412059ce055e91dee",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_flatspec": {
        "artifact": "org.scalatest:scalatest-flatspec_2.13:3.2.19",
        "sha256": "de4d28423dc69e91fdc8f3a03a4fb6b443c5626b819c896e5fbe4a73a375654a",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_freespec": {
        "artifact": "org.scalatest:scalatest-freespec_2.13:3.2.19",
        "sha256": "f3e463422cca38117bb48665602543474fbc2c37427b1133a9c34332f895b08a",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_funspec": {
        "artifact": "org.scalatest:scalatest-funspec_2.13:3.2.19",
        "sha256": "4c682781b67c5daeeebb9e132a78929b824f88747b963b9aa8bd24a0a7d6893b",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_funsuite": {
        "artifact": "org.scalatest:scalatest-funsuite_2.13:3.2.19",
        "sha256": "926aeb37193ad79d0b380160765c9ab61d4367b994c1ab715896fe4961241d5e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_matchers_core": {
        "artifact": "org.scalatest:scalatest-matchers-core_2.13:3.2.19",
        "sha256": "033f16c1143fbe51675d080b13ac319d98581d0331ba3ccebb121e3904a774a3",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_mustmatchers": {
        "artifact": "org.scalatest:scalatest-mustmatchers_2.13:3.2.19",
        "sha256": "8ebbd5c12843d75f15283f31c35994b6e733ce737f666b05528fa8b6e67ad32e",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_matchers_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_propspec": {
        "artifact": "org.scalatest:scalatest-propspec_2.13:3.2.19",
        "sha256": "6c1c7d557485861d920b1c26748a871232b626e93d466a3d9bb8dbbc6e38485d",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_refspec": {
        "artifact": "org.scalatest:scalatest-refspec_2.13:3.2.19",
        "sha256": "7a4c836cf66c99c1e12ca96e6d94c4f68b7dbb49144f9e13af73ada4df752652",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_shouldmatchers": {
        "artifact": "org.scalatest:scalatest-shouldmatchers_2.13:3.2.19",
        "sha256": "64658d736039267baae0108af620617e8ce88b2f4683112e2e31e4ad2a603c0f",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_matchers_core",
        ],
    },
    "io_bazel_rules_scala_scalatest_wordspec": {
        "artifact": "org.scalatest:scalatest-wordspec_2.13:3.2.19",
        "sha256": "08050f3d05c72575cac29a1483185b443d5f9f34c1fcf80c683083330385ef93",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@io_bazel_rules_scala_scalatest_core",
        ],
    },
    "io_bazel_rules_scala_scopt": {
        "artifact": "com.github.scopt:scopt_2.13:4.0.0-RC2",
        "sha256": "07c1937cba53f7509d2ac62a0fc375943a3e0fef346625414c15d41b5a6cfb34",
    },
    "io_bazel_rules_scala_scrooge_core": {
        "artifact": "com.twitter:scrooge-core_2.13:21.2.0",
        "sha256": "a93f179b96e13bd172e5164c587a3645122f45f6d6370304e06d52e2ab0e456f",
    },
    "io_bazel_rules_scala_scrooge_generator": {
        "artifact": "com.twitter:scrooge-generator_2.13:21.2.0",
        "sha256": "1293391da7df25497cad7c56cf8ecaeb672496a548d144d7a2a1cfcf748bed6c",
        "runtime_deps": [
            "@io_bazel_rules_scala_guava",
            "@io_bazel_rules_scala_mustache",
            "@io_bazel_rules_scala_scopt",
        ],
    },
    "io_bazel_rules_scala_util_core": {
        "artifact": "com.twitter:util-core_2.13:21.2.0",
        "sha256": "da8e149b8f0646316787b29f6e254250da10b4b31d9a96c32e42f613574678cd",
    },
    "io_bazel_rules_scala_util_logging": {
        "artifact": "com.twitter:util-logging_2.13:21.2.0",
        "sha256": "90bd8318329907dcf7e161287473e27272b38ee6857e9d56ee8a1958608cc49d",
    },
    "io_github_java_diff_utils_java_diff_utils": {
        "artifact": "io.github.java-diff-utils:java-diff-utils:4.12",
        "sha256": "9990a2039778f6b4cc94790141c2868864eacee0620c6c459451121a901cd5b5",
    },
    "libthrift": {
        "artifact": "org.apache.thrift:libthrift:0.8.0",
        "sha256": "adea029247c3f16e55e29c1708b897812fd1fe335ac55fe3903e5d2f428ef4b3",
    },
    "net_java_dev_jna_jna": {
        "artifact": "net.java.dev.jna:jna:5.14.0",
        "sha256": "34ed1e1f27fa896bca50dbc4e99cf3732967cec387a7a0d5e3486c09673fe8c6",
    },
    "org_apache_commons_commons_lang_3_5": {
        "testonly": True,
        "artifact": "org.apache.commons:commons-lang3:3.5",
        "sha256": "8ac96fc686512d777fca85e144f196cd7cfe0c0aec23127229497d1a38ff651c",
    },
    "org_jline_jline": {
        "artifact": "org.jline:jline:3.27.1",
        "sha256": "72fcbc58da05092067739ded62ed6b1ba9075ecd0fee1caa634c2cbf1a16fe7a",
    },
    "org_scala_lang_modules_scala_collection_compat": {
        "artifact": "org.scala-lang.modules:scala-collection-compat_2.13:2.11.0",
        "sha256": "0c1108883b7b97851750e8932f9584346ccb23f1260c197f97295ac2e6c56cec",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scala_lang_scalap": {
        "artifact": "org.scala-lang:scalap:2.13.15",
        "sha256": "78991282d73e9d20cbf187bab8549ce2ef940269409d47df2a71faaf9afc4616",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler",
        ],
    },
    "org_scalameta_common": {
        "artifact": "org.scalameta:common_2.13:4.9.9",
        "sha256": "be66ba789863c65abfc9c1e448339ce915f2bc778daf348d884a967e8eb473ee",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_fastparse": {
        "artifact": "org.scalameta:fastparse-v2_2.13:2.3.1",
        "sha256": "8fca8597ad6d7c13c48009ee13bbe80c176b08ab12e68af54a50f7f69d8447c5",
        "deps": [
            "@com_lihaoyi_geny",
            "@com_lihaoyi_sourcecode",
        ],
    },
    "org_scalameta_fastparse_utils": {
        "artifact": "org.scalameta:fastparse-utils_2.13:1.0.1",
        "sha256": "9d650543903836684a808bb4c5ff775a4cae4b38c3a47ce946b572237fde340f",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_mdoc_parser": {
        "artifact": "org.scalameta:mdoc-parser_2.13:2.5.4",
        "sha256": "a36fc6125666047b653f8acb1aad16db4aefaaaffdc3f53d2b9eeec83dc580bf",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_parsers": {
        "artifact": "org.scalameta:parsers_2.13:4.9.9",
        "sha256": "ab4198d993b4214d9b98277f96c4ac76a72b87a1fea8df96e9be8e3e98176d7a",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_trees",
        ],
    },
    "org_scalameta_scalafmt_config": {
        "artifact": "org.scalameta:scalafmt-config_2.13:3.8.3",
        "sha256": "175c7e345baccb75e0f79aa9d8c821834b4b232d3917039c44ca2f0265f2110a",
        "deps": [
            "@com_geirsson_metaconfig_core",
            "@com_geirsson_metaconfig_typesafe_config",
        ],
    },
    "org_scalameta_scalafmt_core": {
        "artifact": "org.scalameta:scalafmt-core_2.13:3.8.3",
        "sha256": "c214d16a746ceab8ac47b97c18d2817f726174dd58da75d43472d045ddc25009",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@org_scalameta_mdoc_parser",
            "@org_scalameta_scalafmt_config",
            "@org_scalameta_scalafmt_sysops",
            "@org_scalameta_scalameta",
        ],
    },
    "org_scalameta_scalafmt_sysops": {
        "artifact": "org.scalameta:scalafmt-sysops_2.13:3.8.3",
        "sha256": "981b5455b956ece0e7f2c0825241c6f99b2d70cc2352700a2fcffa5c01ed6633",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_parallel_collections",
        ],
    },
    "org_scalameta_scalameta": {
        "artifact": "org.scalameta:scalameta_2.13:4.9.9",
        "sha256": "01a3c1130202400dbcf4ea0f42374c8e392b9199716ddf605217f4bf1f61cb1d",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_scalap",
            "@org_scalameta_parsers",
        ],
    },
    "org_scalameta_semanticdb_scalac": {
        "artifact": "org.scalameta:semanticdb-scalac_2.13.15:4.9.9",
        "sha256": "409194fee7eeb3da25733f6fc0c2d62b9ef53ddecdc50b6c922fdc695b250fe7",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_trees": {
        "artifact": "org.scalameta:trees_2.13:4.9.9",
        "sha256": "d016cde916b19d6c814ac296544a1882b96664ac03e5ef27019a518482c3db49",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_common",
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
        "artifact": "org.typelevel:cats-core_2.13:2.2.0",
        "sha256": "6058d02418e4eb5f1919a1156d63d2d1b93f2c6190b1a1806ee2b73f8726a92f",
    },
    "org_typelevel_kind_projector": {
        "artifact": "org.typelevel:kind-projector_2.13.15:0.13.3",
        "sha256": "569fec54deba82cd143f05a6a0456c9e3bf56bff310b0968f0adb5fb3b352d92",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_typelevel_paiges_core": {
        "artifact": "org.typelevel:paiges-core_2.13:0.4.3",
        "sha256": "4daa8b180b466634b66be040e1097c107981c0ba0b7c605e2f7c0b66ae1b99b5",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "scala_proto_rules_disruptor": {
        "artifact": "com.lmax:disruptor:3.4.2",
        "sha256": "f412ecbb235c2460b45e63584109723dea8d94b819c78c9bfc38f50cba8546c0",
    },
    "scala_proto_rules_grpc_api": {
        "artifact": "io.grpc:grpc-api:1.24.0",
        "sha256": "553978366e04ee8ddba64afde3b3cf2ac021a2f3c2db2831b6491d742b558598",
    },
    "scala_proto_rules_grpc_context": {
        "artifact": "io.grpc:grpc-context:1.24.0",
        "sha256": "1f0546e18789f7445d1c5a157010a11bc038bbb31544cdb60d9da3848efcfeea",
    },
    "scala_proto_rules_grpc_core": {
        "artifact": "io.grpc:grpc-core:1.24.0",
        "sha256": "8fc900625a9330b1c155b5423844d21be0a5574fe218a63170a16796c6f7880e",
    },
    "scala_proto_rules_grpc_netty": {
        "artifact": "io.grpc:grpc-netty:1.24.0",
        "sha256": "8478333706ba442a354c2ddb8832d80a5aef71016e8a9cf07e7bf6e8c298f042",
    },
    "scala_proto_rules_grpc_protobuf": {
        "artifact": "io.grpc:grpc-protobuf:1.24.0",
        "sha256": "88cd0838ea32893d92cb214ea58908351854ed8de7730be07d5f7d19025dd0bc",
    },
    "scala_proto_rules_grpc_stub": {
        "artifact": "io.grpc:grpc-stub:1.24.0",
        "sha256": "eaa9201896a77a0822e26621b538c7154f00441a51c9b14dc9e1ec1f2acfb815",
    },
    "scala_proto_rules_instrumentation_api": {
        "artifact": "com.google.instrumentation:instrumentation-api:0.3.0",
        "sha256": "671f7147487877f606af2c7e39399c8d178c492982827305d3b1c7f5b04f1145",
    },
    "scala_proto_rules_netty_buffer": {
        "artifact": "io.netty:netty-buffer:4.1.32.Final",
        "sha256": "8ac0e30048636bd79ae205c4f9f5d7544290abd3a7ed39d8b6d97dfe3795afc1",
    },
    "scala_proto_rules_netty_codec": {
        "artifact": "io.netty:netty-codec:4.1.32.Final",
        "sha256": "dbd6cea7d7bf5a2604e87337cb67c9468730d599be56511ed0979aacb309f879",
    },
    "scala_proto_rules_netty_codec_http": {
        "artifact": "io.netty:netty-codec-http:4.1.32.Final",
        "sha256": "db2c22744f6a4950d1817e4e1a26692e53052c5d54abe6cceecd7df33f4eaac3",
    },
    "scala_proto_rules_netty_codec_http2": {
        "artifact": "io.netty:netty-codec-http2:4.1.32.Final",
        "sha256": "4d4c6cfc1f19efb969b9b0ae6cc977462d202867f7dcfee6e9069977e623a2f5",
    },
    "scala_proto_rules_netty_codec_socks": {
        "artifact": "io.netty:netty-codec-socks:4.1.32.Final",
        "sha256": "fe2f2e97d6c65dc280623dcfd24337d8a5c7377049c120842f2c59fb83d7408a",
    },
    "scala_proto_rules_netty_common": {
        "artifact": "io.netty:netty-common:4.1.32.Final",
        "sha256": "cc993e660f8f8e3b033f1d25a9e2f70151666bdf878d460a6508cb23daa696dc",
    },
    "scala_proto_rules_netty_handler": {
        "artifact": "io.netty:netty-handler:4.1.32.Final",
        "sha256": "07d9756e48b5f6edc756e33e8b848fb27ff0b1ae087dab5addca6c6bf17cac2d",
    },
    "scala_proto_rules_netty_handler_proxy": {
        "artifact": "io.netty:netty-handler-proxy:4.1.32.Final",
        "sha256": "10d1081ed114bb0e76ebbb5331b66a6c3189cbdefdba232733fc9ca308a6ea34",
    },
    "scala_proto_rules_netty_resolver": {
        "artifact": "io.netty:netty-resolver:4.1.32.Final",
        "sha256": "9b4a19982047a95ea4791a7ad7ad385c7a08c2ac75f0a3509cc213cb32a726ae",
    },
    "scala_proto_rules_netty_transport": {
        "artifact": "io.netty:netty-transport:4.1.32.Final",
        "sha256": "175bae0d227d7932c0c965c983efbb3cf01f39abe934f5c4071d0319784715fb",
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
        "artifact": "io.perfmark:perfmark-api:0.17.0",
        "sha256": "816c11409b8a0c6c9ce1cda14bed526e7b4da0e772da67c5b7b88eefd41520f9",
    },
    "scala_proto_rules_scalapb_compilerplugin": {
        "artifact": "com.thesamet.scalapb:compilerplugin_2.13:0.9.7",
        "sha256": "ac29c2f01b0b1e39c4226915000505643d586234d586247e1fd97133e20bcc60",
    },
    "scala_proto_rules_scalapb_lenses": {
        "artifact": "com.thesamet.scalapb:lenses_2.13:0.9.8",
        "sha256": "ec82e4d41487165c5dc52ef5e0ebd8565550b02e23583a8fbf5f87d6be90583a",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "scala_proto_rules_scalapb_protoc_bridge": {
        "artifact": "com.thesamet.scalapb:protoc-bridge_2.13:0.7.14",
        "sha256": "0704f2379374205e7130018e3df6b3d50a4d330c3e447ca39b5075ecb4c93cd1",
    },
    "scala_proto_rules_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_2.13:0.9.8",
        "sha256": "622282915e669a175fa1e1e647985c1e9bd0dbb143836bb8f7943a3e8138c46d",
        "deps": [
            "@com_google_protobuf_protobuf_java",
            "@com_lihaoyi_fastparse",
            "@io_bazel_rules_scala_scala_library",
            "@scala_proto_rules_scalapb_lenses",
        ],
    },
    "scala_proto_rules_scalapb_runtime_grpc": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime-grpc_2.13:0.9.7",
        "sha256": "950984d4a3b21925d3156dd98cddb4e7c2f429aad81aa25bb5a3792d41fd7c76",
    },
}
