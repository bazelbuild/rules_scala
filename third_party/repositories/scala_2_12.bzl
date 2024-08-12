scala_version = "2.12.19"

artifacts = {
    "io_bazel_rules_scala_scala_library": {
        "artifact": "org.scala-lang:scala-library:%s" % scala_version,
        "sha256": "81e32f8e31236ef84c21287f1fbaa916fc6525b2e63220d4a0f2396e91871d50",
    },
    "io_bazel_rules_scala_scala_compiler": {
        "artifact": "org.scala-lang:scala-compiler:%s" % scala_version,
        "sha256": "d12975f4cf9a450ea12870243648a851f92165448fdda5a292747cb3bdaecc4f",
    },
    "io_bazel_rules_scala_scala_reflect": {
        "artifact": "org.scala-lang:scala-reflect:%s" % scala_version,
        "sha256": "ff6eaa5548779d61d35b98cb25e931951c5a9f1abc48741e9df95324ee2ae66c",
    },
    "io_bazel_rules_scala_scalatest": {
        "artifact": "org.scalatest:scalatest_2.12:3.2.19",
        "sha256": "9f7dc750bbd6eeb52f0d8bc7c542ace46da9efdca0128a5a92769a448e065a62",
    },
    "io_bazel_rules_scala_scalatest_compatible": {
        "artifact": "org.scalatest:scalatest-compatible:jar:3.2.19",
        "sha256": "5dc6b8fa5396fe9e1a7c2b72df174a8eb3e92770cdc3e70636d3eba673cd0da3",
    },
    "io_bazel_rules_scala_scalatest_core": {
        "artifact": "org.scalatest:scalatest-core_2.12:3.2.19",
        "sha256": "57b683ac16954fae147182bae9619a1d3070286bc2febc18c059600dd2885a99",
    },
    "io_bazel_rules_scala_scalatest_featurespec": {
        "artifact": "org.scalatest:scalatest-featurespec_2.12:3.2.19",
        "sha256": "a7173e04338830b03cb366839bd03deb1765e06bacd3414c306548ba03280016",
    },
    "io_bazel_rules_scala_scalatest_flatspec": {
        "artifact": "org.scalatest:scalatest-flatspec_2.12:3.2.19",
        "sha256": "b3974fa6f1f4b97b583ac94911adbb5b78a48a5c06101860d015f0e9df0e0131",
    },
    "io_bazel_rules_scala_scalatest_freespec": {
        "artifact": "org.scalatest:scalatest-freespec_2.12:3.2.19",
        "sha256": "008cad5f68215028f3120ce24cd8f40ee435260d14455143884da8f66496c7b2",
    },
    "io_bazel_rules_scala_scalatest_funsuite": {
        "artifact": "org.scalatest:scalatest-funsuite_2.12:3.2.19",
        "sha256": "4ccea10ecf3f1ecfd16d7cab4da2dbec965da1cebc5e956aeddc814e27845ba8",
    },
    "io_bazel_rules_scala_scalatest_funspec": {
        "artifact": "org.scalatest:scalatest-funspec_2.12:3.2.19",
        "sha256": "24646029011aa0528cbba3d14320167f16604225eb72eaf95521134ac82944e6",
    },
    "io_bazel_rules_scala_scalatest_matchers_core": {
        "artifact": "org.scalatest:scalatest-matchers-core_2.12:3.2.19",
        "sha256": "1048196692ce8ad06fed0e6fb41ce87d6b205646be3c2a78d3654ce90a9d5bc5",
    },
    "io_bazel_rules_scala_scalatest_shouldmatchers": {
        "artifact": "org.scalatest:scalatest-shouldmatchers_2.12:3.2.19",
        "sha256": "36e8fa4935945c913c6989e98050355814c2f6ee96b0b350da3cc76e471eb14f",
    },
    "io_bazel_rules_scala_scalatest_mustmatchers": {
        "artifact": "org.scalatest:scalatest-mustmatchers_2.12:3.2.19",
        "sha256": "e879ad96f7c5ab558994b34d9a96cf50dc6b32f7c34e7df0586d72ba6c3cbddc",
    },
    "io_bazel_rules_scala_scalactic": {
        "artifact": "org.scalactic:scalactic_2.12:3.2.19",
        "sha256": "a50a3248208b25e9797c447709fe4276026510beae01e82366f405a66d9a8d57",
    },
    "io_bazel_rules_scala_scala_xml": {
        "artifact": "org.scala-lang.modules:scala-xml_2.12:2.3.0",
        "sha256": "4932c56a2d5aae77ae8d7ac6bed1f21d48268fdbac8b4e5f3ca5196ad10fd93e",
    },
    "io_bazel_rules_scala_scala_parser_combinators": {
        "artifact": "org.scala-lang.modules:scala-parser-combinators_2.12:2.4.0",
        "sha256": "23a8d4ddbb7d116dc7a4c41a33f362e5f908cb6b57210c6ed38e61a6c8e383ea",
    },
    "org_scalameta_common": {
        "artifact": "org.scalameta:common_2.12:4.9.9",
        "sha256": "8b85032d1fd8cb33c091cf560362b5a9ce5cb507ab38e6968d04f7978d18f600",
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
        "artifact": "org.scalameta:fastparse-v2_2.12:2.3.1",
        "sha256": "c8ddc110da4b2e3d204e44b2629f4663edeb61094fa7ab4749f2f82b1b0cb026",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@com_lihaoyi_geny",
        ],
    },
    "org_scalameta_fastparse_utils": {
        "artifact": "org.scalameta:fastparse-utils_2.12:1.0.1",
        "sha256": "9d8ad97778ef9aedef5d4190879ed0ec54969e2fc951576fe18746ae6ce6cfcf",
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
        "artifact": "org.scala-lang.modules:scala-collection-compat_2.12:2.12.0",
        "sha256": "1619c5e4399e1e4793667970aae232652db0549e795c90abf91e44c55ec37cb3",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_parsers": {
        "artifact": "org.scalameta:parsers_2.12:4.9.9",
        "sha256": "69ca8f44ead67cc65f8b4973285b7bdb88c4b29542de287a73e23df3a2614da9",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_trees",
        ],
    },
    "org_scalameta_scalafmt_core": {
        "artifact": "org.scalameta:scalafmt-core_2.12:3.8.3",
        "sha256": "27baf247de01ba6270f0717d9b779a4a6bc9989fa01250b2ea59795e345d4f78",
        "deps": [
            "@com_geirsson_metaconfig_core",
            "@com_geirsson_metaconfig_typesafe_config",
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_reflect",
            "@org_scalameta_scalameta",
        ],
    },
    "org_scalameta_scalameta": {
        "artifact": "org.scalameta:scalameta_2.12:4.9.9",
        "sha256": "0d7bc7ea2186b87c4c2cb117287bbef7bbc601fdf14042475fb7330da2cc73c1",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_scalap",
            "@org_scalameta_parsers",
        ],
    },
    "org_scalameta_trees": {
        "artifact": "org.scalameta:trees_2.12:4.9.9",
        "sha256": "786762689490a14a69ad4ab8879f59e858a7ea6a6b498daa302c0eff1450be01",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_common",
            "@org_scalameta_fastparse",
        ],
    },
    "org_typelevel_paiges_core": {
        "artifact": "org.typelevel:paiges-core_2.12:0.4.4",
        "sha256": "bffacf6bfc346d4822b2c18e62fb39f18418beeb41f849761ff9ac1c20a9aea9",
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
        "artifact": "com.thesamet.scalapb:lenses_2.12:0.11.17",
        "sha256": "c984f7695e9a5034afbf725b7eab919fc00bb24dc30c8f6f923d6d32096a1fa0",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_thesamet_scalapb_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_2.12:0.11.17",
        "sha256": "6624beb8e47c11de33262f867dd86d25e66ddce5507c9c13bfd7cc2f2e7652fe",
        "deps": [
            "@com_google_protobuf_protobuf_java",
            "@com_lihaoyi_fastparse",
            "@com_thesamet_scalapb_lenses",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_lihaoyi_fansi": {
        "artifact": "com.lihaoyi:fansi_2.12:0.5.0",
        "sha256": "8b87d847d06c65c63d38fe4a8b38a2362f2c643928e665686ecaf35cc184f215",
        "deps": [
            "@com_lihaoyi_sourcecode",
        ],
    },
    "com_lihaoyi_fastparse": {
        "artifact": "com.lihaoyi:fastparse_2.12:3.1.1",
        "sha256": "ac898711cfefba3dffc2b32d2c5dfa9fa5bf42f19a8ad3930cae1898e4a43de1",
        "deps": [
            "@com_lihaoyi_sourcecode",
        ],
    },
    "com_lihaoyi_pprint": {
        "artifact": "com.lihaoyi:pprint_2.12:0.9.0",
        "sha256": "aa5c426ec33ba8af1193ffca121d8b189013911b03779582e869bf4c622a6749",
        "deps": [
            "@com_lihaoyi_fansi",
            "@com_lihaoyi_sourcecode",
        ],
    },
    "com_lihaoyi_sourcecode": {
        "artifact": "com.lihaoyi:sourcecode_2.12:0.4.2",
        "sha256": "2f5cc6211c4731a5ef42b74053cc3846666bf9397649399cb24013973c746b2a",
    },
    "com_google_protobuf_protobuf_java": {
        "artifact": "com.google.protobuf:protobuf-java:4.27.3",
        "sha256": "d02f863a90a3ffc77d5eeec031c18e579f30c7cb98f3f3a814fe8b88c43d3bc8",
    },
    "com_geirsson_metaconfig_core": {
        "artifact": "com.geirsson:metaconfig-core_2.12:0.12.0",
        "sha256": "902dba2da97ed2b29f4921fe0bb2f2c58e94840f2e7ece89d5d0f91f6307c21e",
        "deps": [
            "@com_lihaoyi_pprint",
            "@io_bazel_rules_scala_scala_library",
            "@org_typelevel_paiges_core",
            "@org_scala_lang_modules_scala_collection_compat",
        ],
    },
    "com_geirsson_metaconfig_typesafe_config": {
        "artifact": "com.geirsson:metaconfig-typesafe-config_2.12:0.12.0",
        "sha256": "5d4d30072aab5174845cacca85105df2935f9ebe70b6f9d2afd1b85138e42ed9",
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
        "artifact": "org.specs2:specs2-common_2.12:4.20.8",
        "sha256": "3e308f122ebfb3f560602e08a690a0bdd49f4a59a8b6a2f731d09793cd2fb6d3",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_fp",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_core": {
        "artifact": "org.specs2:specs2-core_2.12:4.20.8",
        "sha256": "0f6f970f4a9f38a51e3bbf6b39cc3ac2f6be10b99106dba50692c6664ec9ceba",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
            "@io_bazel_rules_scala_org_specs2_specs2_matcher",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_fp": {
        "artifact": "org.specs2:specs2-fp_2.12:4.20.8",
        "sha256": "1c773a24fad4fe76ceb0623acb3ecc53d7fb2cab21e34051fa8148e232d804a9",
    },
    "io_bazel_rules_scala_org_specs2_specs2_matcher": {
        "artifact": "org.specs2:specs2-matcher_2.12:4.20.8",
        "sha256": "7f14b616ba46cccf4614a8730ef4fb2ce480e42e555afdd5a5f33eda12e384ee",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_junit": {
        "artifact": "org.specs2:specs2-junit_2.12:4.20.8",
        "sha256": "d78146f4b2c46b3b52b58d679484b36d2dea55c96d4ec363ca1ba977439fd462",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_core",
        ],
    },
    "scala_proto_rules_scalapb_plugin": {
        "artifact": "com.thesamet.scalapb:compilerplugin_2.12:0.11.17",
        "sha256": "a9dc6cc0dbe6ff53a7c914433d5a19711018217b432b385c97778cd4050210d0",
    },
    "scala_proto_rules_protoc_bridge": {
        "artifact": "com.thesamet.scalapb:protoc-bridge_2.12:0.9.7",
        "sha256": "6d039a28d29253ac78aec0e3102f6423d269e65203c114a17f0d52a91d4876f4",
    },
    "scala_proto_rules_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_2.12:0.11.17",
        "sha256": "6624beb8e47c11de33262f867dd86d25e66ddce5507c9c13bfd7cc2f2e7652fe",
    },
    "scala_proto_rules_scalapb_runtime_grpc": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime-grpc_2.12:0.11.17",
        "sha256": "7919fbb62f3ae9de9eec3a102b24dc1ef570ff098d1e41e464cf2ac7398cff5f",
    },
    "scala_proto_rules_scalapb_lenses": {
        "artifact": "com.thesamet.scalapb:lenses_2.12:0.11.17",
        "sha256": "c984f7695e9a5034afbf725b7eab919fc00bb24dc30c8f6f923d6d32096a1fa0",
    },
    "scala_proto_rules_scalapb_fastparse": {
        "artifact": "com.lihaoyi:fastparse_2.12:3.1.1",
        "sha256": "ac898711cfefba3dffc2b32d2c5dfa9fa5bf42f19a8ad3930cae1898e4a43de1",
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
        "artifact": "com.twitter:scrooge-core_2.12:24.2.0",
        "sha256": "fe06f346546fba1c5c818aa5291c3937d72227f3b5bcc990d070a6a8e71bb8b4",
    },
    "io_bazel_rules_scala_scrooge_generator": {
        "artifact": "com.twitter:scrooge-generator_2.12:24.2.0",
        "sha256": "3d9ec9f841869f41341d2563eae1f7e55a84131be8a36d5e6faf7c86302856fe",
        "runtime_deps": [
            "@io_bazel_rules_scala_guava",
            "@io_bazel_rules_scala_mustache",
            "@io_bazel_rules_scala_scopt",
        ],
    },
    "io_bazel_rules_scala_util_core": {
        "artifact": "com.twitter:util-core_2.12:24.2.0",
        "sha256": "aafcad854bcf7192506a0b9fb474cc4b2c9ce7c9cd1801e5ad0b9c65d296d3f0",
    },
    "io_bazel_rules_scala_util_logging": {
        "artifact": "com.twitter:util-logging_2.12:24.2.0",
        "sha256": "5dcdf119c2c8a204b43054f93c90dc87632bc436c03350e124fb3ad60f18cf30",
    },
    "io_bazel_rules_scala_javax_annotation_api": {
        "artifact": "javax.annotation:javax.annotation-api:1.3.2",
        "sha256": "e04ba5195bcd555dc95650f7cc614d151e4bcd52d29a10b8aa2197f3ab89ab9b",
    },
    "io_bazel_rules_scala_scopt": {
        "artifact": "com.github.scopt:scopt_2.12:4.1.0",
        "sha256": "10c53971c58821616583c7c8ca039cbaba15d47d1a95e63be4ffee24bf3de8f1",
    },

    # test only
    "com_twitter__scalding_date": {
        "testonly": True,
        "artifact": "com.twitter:scalding-date_2.12:0.17.4",
        "sha256": "f9034bc2b1cc05429df8ceb7d7748d53bcc9ada9b2cacf24830b095cfc29e845",
    },
    "org_typelevel__cats_core": {
        "testonly": True,
        "artifact": "org.typelevel:cats-core_2.12:2.12.0",
        "sha256": "f3b4d616d46b46e46618ee384e79467cbb225692256f6ef389ddb9f960f6f6ea",
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
