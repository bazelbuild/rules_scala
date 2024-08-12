scala_version = "2.13.14"

artifacts = {
    "io_bazel_rules_scala_scala_library": {
        "artifact": "org.scala-lang:scala-library:%s" % scala_version,
        "sha256": "43e0ca1583df1966eaf02f0fbddcfb3784b995dd06bfc907209347758ce4b7e3",
    },
    "io_bazel_rules_scala_scala_compiler": {
        "artifact": "org.scala-lang:scala-compiler:%s" % scala_version,
        "sha256": "17b7e1dd95900420816a3bc2788c8c7358c2a3c42899765a5c463a46bfa569a6",
    },
    "io_bazel_rules_scala_scala_reflect": {
        "artifact": "org.scala-lang:scala-reflect:%s" % scala_version,
        "sha256": "8846baaa8cf43b1b19725ab737abff145ca58d14a4d02e75d71ca8f7ca5f2926",
    },
    "io_bazel_rules_scala_scala_parallel_collections": {
        "artifact": "org.scala-lang.modules:scala-parallel-collections_2.13:1.0.4",
        "sha256": "68f266c4fa37cb20a76e905ad940e241190ce288b7e4a9877f1dd1261cd1a9a7",
    },
    "io_bazel_rules_scala_scalatest": {
        "artifact": "org.scalatest:scalatest_2.13:3.2.19",
        "sha256": "c37d97f16172d45b2aef0cebbe59dd2174b7d1ff2c2f272516707cf923015a52",
    },
    "io_bazel_rules_scala_scalatest_compatible": {
        "artifact": "org.scalatest:scalatest-compatible:jar:3.2.19",
        "sha256": "5dc6b8fa5396fe9e1a7c2b72df174a8eb3e92770cdc3e70636d3eba673cd0da3",
    },
    "io_bazel_rules_scala_scalatest_core": {
        "artifact": "org.scalatest:scalatest-core_2.13:3.2.19",
        "sha256": "30230081d029f6341b83fe7f157d336113e1c97497fe950169293d28a5bf2936",
    },
    "io_bazel_rules_scala_scalatest_featurespec": {
        "artifact": "org.scalatest:scalatest-featurespec_2.13:3.2.19",
        "sha256": "58a44e6be12409596feab4d4123900ef2af55d3fcb72033412059ce055e91dee",
    },
    "io_bazel_rules_scala_scalatest_flatspec": {
        "artifact": "org.scalatest:scalatest-flatspec_2.13:3.2.19",
        "sha256": "de4d28423dc69e91fdc8f3a03a4fb6b443c5626b819c896e5fbe4a73a375654a",
    },
    "io_bazel_rules_scala_scalatest_freespec": {
        "artifact": "org.scalatest:scalatest-freespec_2.13:3.2.19",
        "sha256": "f3e463422cca38117bb48665602543474fbc2c37427b1133a9c34332f895b08a",
    },
    "io_bazel_rules_scala_scalatest_funsuite": {
        "artifact": "org.scalatest:scalatest-funsuite_2.13:3.2.19",
        "sha256": "926aeb37193ad79d0b380160765c9ab61d4367b994c1ab715896fe4961241d5e",
    },
    "io_bazel_rules_scala_scalatest_funspec": {
        "artifact": "org.scalatest:scalatest-funspec_2.13:3.2.19",
        "sha256": "4c682781b67c5daeeebb9e132a78929b824f88747b963b9aa8bd24a0a7d6893b",
    },
    "io_bazel_rules_scala_scalatest_matchers_core": {
        "artifact": "org.scalatest:scalatest-matchers-core_2.13:3.2.19",
        "sha256": "033f16c1143fbe51675d080b13ac319d98581d0331ba3ccebb121e3904a774a3",
    },
    "io_bazel_rules_scala_scalatest_shouldmatchers": {
        "artifact": "org.scalatest:scalatest-shouldmatchers_2.13:3.2.19",
        "sha256": "64658d736039267baae0108af620617e8ce88b2f4683112e2e31e4ad2a603c0f",
    },
    "io_bazel_rules_scala_scalatest_mustmatchers": {
        "artifact": "org.scalatest:scalatest-mustmatchers_2.13:3.2.19",
        "sha256": "8ebbd5c12843d75f15283f31c35994b6e733ce737f666b05528fa8b6e67ad32e",
    },
    "io_bazel_rules_scala_scalactic": {
        "artifact": "org.scalactic:scalactic_2.13:3.2.19",
        "sha256": "c27c33de17d450e29e66c16c5af4cfa33e8ffcf03c124f0a3d249d848cccd4af",
    },
    "io_bazel_rules_scala_scala_xml": {
        "artifact": "org.scala-lang.modules:scala-xml_2.13:2.3.0",
        "sha256": "4b4d6698c74bff84a105102bbf58390980dc7bb8c40bdea4bc727040b3f966bd",
    },
    "io_bazel_rules_scala_scala_parser_combinators": {
        "artifact": "org.scala-lang.modules:scala-parser-combinators_2.13:2.4.0",
        "sha256": "e36dccdc21fd4bc770907a9e126d7e3901e71a191eb9ea8e93a0227774e0945d",
    },
    "org_scalameta_common": {
        "artifact": "org.scalameta:common_2.13:4.9.9",
        "sha256": "be66ba789863c65abfc9c1e448339ce915f2bc778daf348d884a967e8eb473ee",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_semanticdb_scalac": {
        "artifact": "org.scalameta:semanticdb-scalac_%s:4.9.9" % scala_version,
        "sha256": "1adfd051c4b4e1c69a49492cbcf558011beba78e79aaeef1319d29e8408e341d",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_fastparse": {
        "artifact": "org.scalameta:fastparse-v2_2.13:2.3.1",
        "sha256": "8fca8597ad6d7c13c48009ee13bbe80c176b08ab12e68af54a50f7f69d8447c5",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@com_lihaoyi_geny",
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
    "com_lihaoyi_geny": {
        "artifact": "com.lihaoyi:geny_2.13:1.1.1",
        "sha256": "20af231c222fc71c29e06b3cd8d9190a16b412da83cc49fb0b778cf2dc6f94d2",
    },
    "org_scala_lang_modules_scala_collection_compat": {
        "artifact": "org.scala-lang.modules:scala-collection-compat_2.13:2.12.0",
        "sha256": "befff482233cd7f9a7ca1e1f5a36ede421c018e6ce82358978c475d45532755f",
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
    "org_scalameta_scalafmt_core": {
        "artifact": "org.scalameta:scalafmt-core_2.13:3.8.3",
        "sha256": "c214d16a746ceab8ac47b97c18d2817f726174dd58da75d43472d045ddc25009",
        "deps": [
            "@com_geirsson_metaconfig_core",
            "@com_geirsson_metaconfig_typesafe_config",
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@org_scalameta_scalameta",
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
    "org_scalameta_trees": {
        "artifact": "org.scalameta:trees_2.13:4.9.9",
        "sha256": "d016cde916b19d6c814ac296544a1882b96664ac03e5ef27019a518482c3db49",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_common",
            "@org_scalameta_fastparse",
        ],
    },
    "org_typelevel_paiges_core": {
        "artifact": "org.typelevel:paiges-core_2.13:0.4.4",
        "sha256": "ffbd59d3648e71c5b8f4474a54121fb3512707e7901245831669aa9e85f3bbf0",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_typesafe_config": {
        "artifact": "com.typesafe:config:1.4.3",
        "sha256": "8ada4c185ce72416712d63e0b5afdc5f009c0cdf405e5f26efecdf156aa5dfb6",
    },
    "org_scala_lang_scalap": {
        "artifact": "org.scala-lang:scalap:2.13.14",
        "sha256": "b92a0f32ae645064f828005f883ce4aeec110fe6971f1b030643ff005a77e7c0",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler",
        ],
    },
    "com_thesamet_scalapb_lenses": {
        "artifact": "com.thesamet.scalapb:lenses_2.13:0.11.17",
        "sha256": "4abe3fe573b8505a633414b0fbbcae4240250690ba48a9d4a6eeb3dfc3302ddf",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_thesamet_scalapb_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_2.13:0.11.17",
        "sha256": "fe91faf58bccef68be348e76cab339a5fe2c215e48f7bd8f836190449ed94077",
        "deps": [
            "@com_google_protobuf_protobuf_java",
            "@com_lihaoyi_fastparse",
            "@com_thesamet_scalapb_lenses",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_lihaoyi_fansi": {
        "artifact": "com.lihaoyi:fansi_2.13:0.5.0",
        "sha256": "fcae26580f7d6e72adbd6e5c504bb1715fbe3f5fb814d70e84bc5427a835e42c",
        "deps": [
            "@com_lihaoyi_sourcecode",
        ],
    },
    "com_lihaoyi_fastparse": {
        "artifact": "com.lihaoyi:fastparse_2.13:3.1.1",
        "sha256": "ff3f37dad0f89c9cff494cb984edc122a3c282f063790949e825ae039dcad9d5",
        "deps": [
            "@com_lihaoyi_sourcecode",
        ],
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
    "com_google_protobuf_protobuf_java": {
        "artifact": "com.google.protobuf:protobuf-java:4.27.3",
        "sha256": "d02f863a90a3ffc77d5eeec031c18e579f30c7cb98f3f3a814fe8b88c43d3bc8",
    },
    "com_geirsson_metaconfig_core": {
        "artifact": "com.geirsson:metaconfig-core_2.13:0.12.0",
        "sha256": "2c91199ae5b206afdd52538f8c4da67c1794bcce0b5b06cf25679db00cf32c19",
        "deps": [
            "@com_lihaoyi_pprint",
            "@io_bazel_rules_scala_scala_library",
            "@org_typelevel_paiges_core",
            "@org_scala_lang_modules_scala_collection_compat",
        ],
    },
    "com_geirsson_metaconfig_typesafe_config": {
        "artifact": "com.geirsson:metaconfig-typesafe-config_2.13:0.12.0",
        "sha256": "b4c5dbf863dadde363d8bd24333ce1091fec94fc5b88efd04607a26f3eab61b8",
        "deps": [
            "@com_geirsson_metaconfig_core",
            "@com_typesafe_config",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "io_bazel_rules_scala_org_openjdk_jmh_jmh_core": {
        "artifact": "org.openjdk.jmh:jmh-core:1.37",
        "sha256": "dc0eaf2bbf0036a70b60798c785d6e03a9daf06b68b8edb0f1ba9eb3421baeb3",
    },
    "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_asm": {
        "artifact": "org.openjdk.jmh:jmh-generator-asm:1.37",
        "sha256": "de29bacc5c3a413215800f57de9017fdda1b3cb6e5359ea0c84ebe13c9610222",
    },
    "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_reflection": {
        "artifact": "org.openjdk.jmh:jmh-generator-reflection:1.37",
        "sha256": "a0421dbbe5e77690df2dfdef98618b62852d816bbb814c5cbd0b4d464bff32b0",
    },
    "io_bazel_rules_scala_org_ows2_asm_asm": {
        "artifact": "org.ow2.asm:asm:9.7",
        "sha256": "adf46d5e34940bdf148ecdd26a9ee8eea94496a72034ff7141066b3eea5c4e9d",
    },
    "io_bazel_rules_scala_net_sf_jopt_simple_jopt_simple": {
        "artifact": "net.sf.jopt-simple:jopt-simple:5.0.4",
        "sha256": "df26cc58f235f477db07f753ba5a3ab243ebe5789d9f89ecf68dd62ea9a66c28",
    },
    "io_bazel_rules_scala_org_apache_commons_commons_math3": {
        "artifact": "org.apache.commons:commons-math3:3.6.1",
        "sha256": "1e56d7b058d28b65abd256b8458e3885b674c1d588fa43cd7d1cbb9c7ef2b308",
    },
    "io_bazel_rules_scala_junit_junit": {
        "artifact": "junit:junit:4.13.2",
        "sha256": "8e495b634469d64fb8acfa3495a065cbacc8a0fff55ce1e31007be4c16dc57d3",
    },
    "io_bazel_rules_scala_org_hamcrest_hamcrest_core": {
        "artifact": "org.hamcrest:hamcrest-core:3.0",
        "sha256": "b78a3a81692f421cc01fc17ded9a45e9fb6f3949c712f8ec4d01da6b8c06bc6e",
    },
    "io_bazel_rules_scala_org_specs2_specs2_common": {
        "artifact": "org.specs2:specs2-common_2.13:4.20.8",
        "sha256": "b39b2424545e5d37143a7eae598d9b9084ffdbdb2b7b24ec89b8665bf190907a",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_fp",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_core": {
        "artifact": "org.specs2:specs2-core_2.13:4.20.8",
        "sha256": "ce7e74b558f918114c086b87021a441c980b00964e45bbc24a167e1e6c6c7f81",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
            "@io_bazel_rules_scala_org_specs2_specs2_matcher",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_fp": {
        "artifact": "org.specs2:specs2-fp_2.13:4.20.8",
        "sha256": "8f50a66880fa88ca499b78d19b4133e34832a1578d180dd9af9b3dab3b4cd5c1",
    },
    "io_bazel_rules_scala_org_specs2_specs2_matcher": {
        "artifact": "org.specs2:specs2-matcher_2.13:4.20.8",
        "sha256": "196c945e3afc44b4d696fdf8d402dacc8aac7b36e790af7e32557ef7691a9eb4",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_junit": {
        "artifact": "org.specs2:specs2-junit_2.13:4.20.8",
        "sha256": "2071a325ba34766b9360e9a72ab74615c7116c3e3ae7f4955c5e5a774ea92114",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_core",
        ],
    },
    "scala_proto_rules_scalapb_plugin": {
        "artifact": "com.thesamet.scalapb:compilerplugin_2.13:0.11.17",
        "sha256": "d36b84059289c7aa2f2bf08eeab7e85084fcf72bf58b337edf167c73218880d7",
    },
    "scala_proto_rules_protoc_bridge": {
        "artifact": "com.thesamet.scalapb:protoc-bridge_2.13:0.9.7",
        "sha256": "403f0e7223c8fd052cff0fbf977f3696c387a696a3a12d7b031d95660c7552f5",
    },
    "scala_proto_rules_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_2.13:0.11.17",
        "sha256": "fe91faf58bccef68be348e76cab339a5fe2c215e48f7bd8f836190449ed94077",
    },
    "scala_proto_rules_scalapb_runtime_grpc": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime-grpc_2.13:0.11.17",
        "sha256": "c03687c038f2a45bb413551519542069a59faf322de29fd1f9e06f2dd65003d0",
    },
    "scala_proto_rules_scalapb_lenses": {
        "artifact": "com.thesamet.scalapb:lenses_2.13:0.11.17",
        "sha256": "4abe3fe573b8505a633414b0fbbcae4240250690ba48a9d4a6eeb3dfc3302ddf",
    },
    "scala_proto_rules_scalapb_fastparse": {
        "artifact": "com.lihaoyi:fastparse_2.13:3.1.1",
        "sha256": "ff3f37dad0f89c9cff494cb984edc122a3c282f063790949e825ae039dcad9d5",
    },
    "scala_proto_rules_grpc_core": {
        "artifact": "io.grpc:grpc-core:1.66.0",
        "sha256": "136b7a7c411a45089dc2b26f0f032f4ae466d9b5d3bfe3a513421d6f35d2c2bd",
    },
    "scala_proto_rules_grpc_api": {
        "artifact": "io.grpc:grpc-api:1.66.0",
        "sha256": "8fadb1f4f0a18971c082497f34cbb78a51897ca8af4b212aa2a99c7de9ad995c",
    },
    "scala_proto_rules_grpc_stub": {
        "artifact": "io.grpc:grpc-stub:1.66.0",
        "sha256": "39a32906304c7f442dfa56dfc6ea88887287fb398621d549e15dfdeaffae194a",
    },
    "scala_proto_rules_grpc_protobuf": {
        "artifact": "io.grpc:grpc-protobuf:1.66.0",
        "sha256": "5942dd582be6c0319bf2af9dd94886f631927b7126d57c8d84fbddd796fd7eb5",
    },
    "scala_proto_rules_grpc_netty": {
        "artifact": "io.grpc:grpc-netty:1.66.0",
        "sha256": "77f7c0ccd77df1d62a8508fef6676fa80b388e3ef4f67fceb99a7d5eaa73b7c9",
    },
    "scala_proto_rules_grpc_context": {
        "artifact": "io.grpc:grpc-context:1.66.0",
        "sha256": "7b7521aa2116014d08dc08825e13d70eac8eb646d09dd44980b6f4d1883e6713",
    },
    "scala_proto_rules_perfmark_api": {
        "artifact": "io.perfmark:perfmark-api:0.27.0",
        "sha256": "c7b478503ec524e55df19b424d46d27c8a68aeb801664fadd4f069b71f52d0f6",
    },
    "scala_proto_rules_guava": {
        "artifact": "com.google.guava:guava:33.2.1-android",
        "sha256": "6b55fbe6ffee621454c03df7bea720d189789e136391a524e29506ff40654180",
    },
    "scala_proto_rules_google_instrumentation": {
        "artifact": "com.google.instrumentation:instrumentation-api:0.4.3",
        "sha256": "9502d5622fea56e5b3fbe4a5263ad3bfd93487869813304c36831e1cb1d88bd5",
    },
    "scala_proto_rules_netty_codec": {
        "artifact": "io.netty:netty-codec:4.1.112.Final",
        "sha256": "72db4f93629f7ea520d2998c08e2b1d69f9c6a4792b53da5e9a001d24c78b151",
    },
    "scala_proto_rules_netty_codec_http": {
        "artifact": "io.netty:netty-codec-http:4.1.112.Final",
        "sha256": "21b502d1374d6992728d004e0c1c95544d46d971f55ea78dcb854ce1ac0c83bc",
    },
    "scala_proto_rules_netty_codec_socks": {
        "artifact": "io.netty:netty-codec-socks:4.1.112.Final",
        "sha256": "069f14507676282a8c4b871b27332aa4491c16339ec0e86f4d86d45a953b51f5",
    },
    "scala_proto_rules_netty_codec_http2": {
        "artifact": "io.netty:netty-codec-http2:4.1.112.Final",
        "sha256": "7f73efc845e8818d71da23b21dc65d69132dd0e12ed0e80cc937bd79ab7d5749",
    },
    "scala_proto_rules_netty_handler": {
        "artifact": "io.netty:netty-handler:4.1.112.Final",
        "sha256": "ea4d6062a5fb10a6e2364d8bbdebc1cfa814f1fc9f910ef57e5caf02fb15c588",
    },
    "scala_proto_rules_netty_buffer": {
        "artifact": "io.netty:netty-buffer:4.1.112.Final",
        "sha256": "bc182c48f5369d48cd8370d2ab0c5b8d99dd8ffa4a0f8ac701652d57bd380eff",
    },
    "scala_proto_rules_netty_transport": {
        "artifact": "io.netty:netty-transport:4.1.112.Final",
        "sha256": "d38e31624d25ca790ee413d529c152170217ebedbcdcf61164fa6291f3a56c92",
    },
    "scala_proto_rules_netty_resolver": {
        "artifact": "io.netty:netty-resolver:4.1.112.Final",
        "sha256": "6b4ac9f3b67f562f0770d57c389279ff9c708eb401e1a3635f52297f0f897edc",
    },
    "scala_proto_rules_netty_common": {
        "artifact": "io.netty:netty-common:4.1.112.Final",
        "sha256": "b03967f32c65de5ed339b97729170e0289b22ffa5729e7f45f68bf6b431fb567",
    },
    "scala_proto_rules_netty_handler_proxy": {
        "artifact": "io.netty:netty-handler-proxy:4.1.112.Final",
        "sha256": "91f7c93dfe4b7a13198d40af39edac0adb0c33f08d9759242997b89176130c8c",
    },
    "scala_proto_rules_opencensus_api": {
        "artifact": "io.opencensus:opencensus-api:0.31.1",
        "sha256": "f1474d47f4b6b001558ad27b952e35eda5cc7146788877fc52938c6eba24b382",
    },
    "scala_proto_rules_opencensus_impl": {
        "artifact": "io.opencensus:opencensus-impl:0.31.1",
        "sha256": "8249a5c7a6bb172a48c12dae9da30305e5b91ae7a900b2ff4234b75debff4c88",
    },
    "scala_proto_rules_disruptor": {
        "artifact": "com.lmax:disruptor:4.0.0.RC1",
        "sha256": "946f79e5a116dc5651e67220578a497bc241fd004ddf91066884f5b14e99f2e0",
    },
    "scala_proto_rules_opencensus_impl_core": {
        "artifact": "io.opencensus:opencensus-impl-core:0.31.1",
        "sha256": "78ecb82f6694a03e76a75b984c533b9449c731d9832782bafb906df925d71983",
    },
    "scala_proto_rules_opencensus_contrib_grpc_metrics": {
        "artifact": "io.opencensus:opencensus-contrib-grpc-metrics:0.31.1",
        "sha256": "c862a1d783652405512e26443f6139e6586f335086e5e1f1dca2b0c4e338a174",
    },
    "io_bazel_rules_scala_mustache": {
        "artifact": "com.github.spullara.mustache.java:compiler:0.9.14",
        "sha256": "99a7e7855609135006f078e6de7ee69daad9c42f98e679d56f80653cb17526b9",
    },
    "io_bazel_rules_scala_guava": {
        "artifact": "com.google.guava:guava:21.0",
        "sha256": "972139718abc8a4893fa78cba8cf7b2c903f35c97aaf44fa3031b0669948b480",
    },
    "libthrift": {
        "artifact": "org.apache.thrift:libthrift:0.20.0",
        "sha256": "52b4ccf7d4cd5cab6429b2507c31d8c1a358ea9d8ae0ba109dd2d865856e7c12",
    },
    "io_bazel_rules_scala_scrooge_core": {
        "artifact": "com.twitter:scrooge-core_2.13:24.2.0",
        "sha256": "992ac9bacebc82d0fa8b91b9d439718af8fda182b4d21a5051eafdca2830232a",
    },
    "io_bazel_rules_scala_scrooge_generator": {
        "artifact": "com.twitter:scrooge-generator_2.13:24.2.0",
        "sha256": "6539e8791806edccbcd414dc0c7fec0f8a4264f9c6ef6befd4149026f83e2bca",
        "runtime_deps": [
            "@io_bazel_rules_scala_guava",
            "@io_bazel_rules_scala_mustache",
            "@io_bazel_rules_scala_scopt",
        ],
    },
    "io_bazel_rules_scala_util_core": {
        "artifact": "com.twitter:util-core_2.13:24.2.0",
        "sha256": "078f2b590926b8f2e5e7cea2466aafe26275f0d733194bc7d046daf56928adbf",
    },
    "io_bazel_rules_scala_util_logging": {
        "artifact": "com.twitter:util-logging_2.13:24.2.0",
        "sha256": "b050e7f5b85289b0065ffaabc8bea389d57c877cb0a13380dbff28ea3b16a948",
    },
    "io_bazel_rules_scala_javax_annotation_api": {
        "artifact": "javax.annotation:javax.annotation-api:1.3.2",
        "sha256": "e04ba5195bcd555dc95650f7cc614d151e4bcd52d29a10b8aa2197f3ab89ab9b",
    },
    "io_bazel_rules_scala_scopt": {
        "artifact": "com.github.scopt:scopt_2.13:4.1.0",
        "sha256": "2e5037bda974630b046794274e344273919abf4727acfcd86352617dce68f82b",
    },

    # test only
    "com_twitter__scalding_date": {
        "testonly": True,
        "artifact": "com.twitter:scalding-date_2.12:0.17.4",
        "sha256": "f9034bc2b1cc05429df8ceb7d7748d53bcc9ada9b2cacf24830b095cfc29e845",
    },
    "org_typelevel__cats_core": {
        "testonly": True,
        "artifact": "org.typelevel:cats-core_2.13:2.12.0",
        "sha256": "0d57ee8ad9d969245ece5a0030f46066bd48898107edfba4b0295123daeff65d",
    },
    "com_google_guava_guava_21_0_with_file": {
        "testonly": True,
        "artifact": "com.google.guava:guava:21.0",
        "sha256": "972139718abc8a4893fa78cba8cf7b2c903f35c97aaf44fa3031b0669948b480",
    },
    "com_github_jnr_jffi_native": {
        "testonly": True,
        "artifact": "com.github.jnr:jffi:jar:native:1.3.13",
        "sha256": "78df5fb05d7e2541b867bedc538b18840245a601bb2160fa26824bb67ed93878",
    },
    "org_apache_commons_commons_lang_3_5": {
        "testonly": True,
        "artifact": "org.apache.commons:commons-lang3:3.16.0",
        "sha256": "08709dd74d602b705ce4017d26544210056a4ba583d5b20c09373406fe7a00f8",
    },
    "org_springframework_spring_core": {
        "testonly": True,
        "artifact": "org.springframework:spring-core:6.1.11",
        "sha256": "1f87efb8202638aa87dc01da3a7ff7cc2a72442b2e00bb5e420d20e4ccb05204",
    },
    "org_springframework_spring_tx": {
        "testonly": True,
        "artifact": "org.springframework:spring-tx:6.1.11",
        "sha256": "6e54e6e7b7d66359cee3366299e34fdbac3ef5f2d0ea6da158f80179ff9ac5c9",
        "deps": [
            "@org_springframework_spring_core",
        ],
    },
    "com_google_guava_guava_21_0": {
        "testonly": True,
        "artifact": "com.google.guava:guava:21.0",
        "sha256": "972139718abc8a4893fa78cba8cf7b2c903f35c97aaf44fa3031b0669948b480",
        "deps": [
            "@org_springframework_spring_core",
        ],
    },
    "org_typelevel_kind_projector": {
        "testonly": True,
        "artifact": "org.typelevel:kind-projector_%s:0.13.3" % scala_version,
        "sha256": "fc40476381233d532ed26b64a3643c1bda792d2900a7df697d676dde82e4408d",
    },
}
