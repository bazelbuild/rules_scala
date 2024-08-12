scala_version = "2.11.12"

artifacts = {
    "io_bazel_rules_scala_scala_library": {
        "artifact": "org.scala-lang:scala-library:%s" % scala_version,
        "sha256": "0b3d6fd42958ee98715ba2ec5fe221f4ca1e694d7c981b0ae0cd68e97baf6dce",
    },
    "io_bazel_rules_scala_scala_compiler": {
        "artifact": "org.scala-lang:scala-compiler:%s" % scala_version,
        "sha256": "3e892546b72ab547cb77de4d840bcfd05c853e73390fed7370a8f19acb0735a0",
    },
    "io_bazel_rules_scala_scala_reflect": {
        "artifact": "org.scala-lang:scala-reflect:%s" % scala_version,
        "sha256": "6ba385b450a6311a15c918cf8688b9af9327c6104f0ecbd35933cfcd3095fe04",
    },
    "io_bazel_rules_scala_scalatest": {
        "artifact": "org.scalatest:scalatest_2.11:3.2.19",
        "sha256": "6f01d1f8cc8063e989900c954f3378c7cd18b7ccb5c3e54242e1dec7eea0472b",
    },
    "io_bazel_rules_scala_scalatest_compatible": {
        "artifact": "org.scalatest:scalatest-compatible:jar:3.2.19",
        "sha256": "5dc6b8fa5396fe9e1a7c2b72df174a8eb3e92770cdc3e70636d3eba673cd0da3",
    },
    "io_bazel_rules_scala_scalatest_core": {
        "artifact": "org.scalatest:scalatest-core_2.11:3.2.19",
        "sha256": "763ba4408a4256a1a430b11f15b4d6f1c5f7fcf0be192a6ef4fd1124008330b7",
    },
    "io_bazel_rules_scala_scalatest_featurespec": {
        "artifact": "org.scalatest:scalatest-featurespec_2.11:3.2.19",
        "sha256": "acc41aa36c8c252a7e0332a3f03b66c09120ff8b7814eab39737ddc11cd9a4d0",
    },
    "io_bazel_rules_scala_scalatest_flatspec": {
        "artifact": "org.scalatest:scalatest-flatspec_2.11:3.2.19",
        "sha256": "1eab3d1d54b8708869c493223db8deee2c0b3b40ce7ae3a79c82f7c2e0451d39",
    },
    "io_bazel_rules_scala_scalatest_freespec": {
        "artifact": "org.scalatest:scalatest-freespec_2.11:3.2.19",
        "sha256": "499508dad83c33f1347f9a7ef6590ebbdba5275c0dba47df1ce1f048a518d1a5",
    },
    "io_bazel_rules_scala_scalatest_funsuite": {
        "artifact": "org.scalatest:scalatest-funsuite_2.11:3.2.19",
        "sha256": "6f7d1679d8d375603b836fab1972d88601d26e1e1322856feb54947b4a534935",
    },
    "io_bazel_rules_scala_scalatest_funspec": {
        "artifact": "org.scalatest:scalatest-funspec_2.11:3.2.19",
        "sha256": "933d154f2f6fc7e86954760cd534e189ab5c8eab790fc66e41fabb9df4da3bb7",
    },
    "io_bazel_rules_scala_scalatest_matchers_core": {
        "artifact": "org.scalatest:scalatest-matchers-core_2.11:3.2.19",
        "sha256": "509771ba2bc172882e0db9d4e8437a032753d4d5a66f9dc61e7f453ecc0057fb",
    },
    "io_bazel_rules_scala_scalatest_shouldmatchers": {
        "artifact": "org.scalatest:scalatest-shouldmatchers_2.11:3.2.19",
        "sha256": "6537c4948ff42cac2eaa7e3d88dd699bff891c574e252ba65372c7d5ed1cd1f9",
    },
    "io_bazel_rules_scala_scalatest_mustmatchers": {
        "artifact": "org.scalatest:scalatest-mustmatchers_2.11:3.2.19",
        "sha256": "5cd41cc8607163df9d15d26e12985fa88803c98fefa19b77f8ce466e39062795",
    },
    "io_bazel_rules_scala_scalactic": {
        "artifact": "org.scalactic:scalactic_2.11:3.2.19",
        "sha256": "20708ca81baeed428eaf9453f038a37dadba376f5d05e85a3fb882e303040d3d",
    },
    "io_bazel_rules_scala_scala_xml": {
        "artifact": "org.scala-lang.modules:scala-xml_2.11:1.3.1",
        "sha256": "257152734155119d159b4a1c8c5aaadb628654681e8e62e02386010de0bd891d",
    },
    "io_bazel_rules_scala_scala_parser_combinators": {
        "artifact": "org.scala-lang.modules:scala-parser-combinators_2.11:2.2.0",
        "sha256": "5c2d82aa2ee4c396619bf1bdec92b6f8911aba6a5fa47529d80029bfa70c3589",
    },
    "org_scalameta_common": {
        "artifact": "org.scalameta:common_2.11:4.9.9",
        "sha256": "7fd057aa7f192c86c38dd627a709825aa13fb69c47b540567996216745492339",
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
    "org_scala_lang_modules_scala_collection_compat": {
        "artifact": "org.scala-lang.modules:scala-collection-compat_2.11:2.12.0",
        "sha256": "2bee698dde419b520552664336e50fdb774aef2c5e859e4738f007ff5e8fdbcb",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "org_scalameta_parsers": {
        "artifact": "org.scalameta:parsers_2.11:4.9.9",
        "sha256": "d971a72dcd800e81fb57598f7e9cad42b0a2468b642bcdfc4c9ba8a30eeb20aa",
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
        "artifact": "org.scalameta:scalameta_2.11:4.9.9",
        "sha256": "07dd85a3f3de5259f436d3f7be3c0efca7685713c853548e8cb1aaa11877f2e0",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
            "@org_scala_lang_scalap",
            "@org_scalameta_parsers",
        ],
    },
    "org_scalameta_trees": {
        "artifact": "org.scalameta:trees_2.11:4.9.9",
        "sha256": "a10ac1ba2c47e992884c7784420e90807a5c1c6105865ec2615e47e4e3cff0c1",
        "deps": [
            "@com_thesamet_scalapb_scalapb_runtime",
            "@io_bazel_rules_scala_scala_library",
            "@org_scalameta_common",
            "@org_scalameta_fastparse",
        ],
    },
    "org_typelevel_paiges_core": {
        "artifact": "org.typelevel:paiges-core_2.11:0.3.0",
        "sha256": "fa697cb6d1e03cb143183c45cc543734e7600dcb4dee63005738d28a722c202e",
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
        "artifact": "com.thesamet.scalapb:lenses_2.11:0.9.8",
        "sha256": "20556c018aa55b196fef2e54d6f2a14d88821be8d1ba58e2c977fffb01d78972",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_thesamet_scalapb_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_2.11:0.9.8",
        "sha256": "c973046bff0e396dce25ce56e567a88b84e4b6cde0280964d23a2c1133f09a49",
        "deps": [
            "@com_google_protobuf_protobuf_java",
            "@com_lihaoyi_fastparse",
            "@com_thesamet_scalapb_lenses",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_lihaoyi_fansi": {
        "artifact": "com.lihaoyi:fansi_2.11:0.4.0",
        "sha256": "08f6400ff3e92fa3d215788fb3ef7bb7bf1344c71f4d4d4199fec9b0e6d91432",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_lihaoyi_fastparse": {
        "artifact": "com.lihaoyi:fastparse_2.11:3.0.2",
        "sha256": "6c5633ca76c8c69e275b7674c14c21cfc60820a875a98541cd9176d8f321c8cf",
        "deps": [
            "@com_lihaoyi_sourcecode",
        ],
    },
    "com_lihaoyi_pprint": {
        "artifact": "com.lihaoyi:pprint_2.11:0.8.1",
        "sha256": "3755b8e5d1423931219ab607e8fd9b6db472740dd5f815f8b0715312e11d06fe",
        "deps": [
            "@com_lihaoyi_fansi",
            "@com_lihaoyi_sourcecode",
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_lihaoyi_sourcecode": {
        "artifact": "com.lihaoyi:sourcecode_2.11:0.3.1",
        "sha256": "52b38f0d291bab3555bd6b4324a1e86d1acbb347ffc763b154f220d7ce54f31b",
        "deps": [
            "@io_bazel_rules_scala_scala_library",
        ],
    },
    "com_google_protobuf_protobuf_java": {
        "artifact": "com.google.protobuf:protobuf-java:4.27.3",
        "sha256": "d02f863a90a3ffc77d5eeec031c18e579f30c7cb98f3f3a814fe8b88c43d3bc8",
    },
    "com_geirsson_metaconfig_core": {
        "artifact": "com.geirsson:metaconfig-core_2.11:0.9.10",
        "sha256": "c8b8f64e42d52a0bd7af1094c46c1fc15773f3bc62d014b833509679e857035b",
        "deps": [
            "@com_lihaoyi_pprint",
            "@io_bazel_rules_scala_scala_library",
            "@org_typelevel_paiges_core",
            "@org_scala_lang_modules_scala_collection_compat",
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
        "artifact": "org.specs2:specs2-common_2.11:4.10.6",
        "sha256": "823bdd776b3c4759506b527e0e58d31f9eebbba7b16858ad0fef4b29559dcb5d",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_fp",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_core": {
        "artifact": "org.specs2:specs2-core_2.11:4.10.6",
        "sha256": "dbd85edf0b399f98a4494c7e5a2ff1868a5c2c6f06e34e56d0e2e2b5b9d9431e",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
            "@io_bazel_rules_scala_org_specs2_specs2_matcher",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_fp": {
        "artifact": "org.specs2:specs2-fp_2.11:4.10.6",
        "sha256": "afe794801e0adb93c353bf1c8b4a10b44d5f8ead52449ee17b3284613eac0f5e",
    },
    "io_bazel_rules_scala_org_specs2_specs2_matcher": {
        "artifact": "org.specs2:specs2-matcher_2.11:4.10.6",
        "sha256": "c788968cfef1377bc9025f96a4ff86fc2a44c5fd36762683a6c7d597b14692ef",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
        ],
    },
    "io_bazel_rules_scala_org_specs2_specs2_junit": {
        "artifact": "org.specs2:specs2-junit_2.11:4.10.6",
        "sha256": "b09bb5324b339b022ccf23a669c815084249299e5014097195a0f671d4b89eb3",
        "deps": [
            "@io_bazel_rules_scala_org_specs2_specs2_core",
        ],
    },
    "scala_proto_rules_scalapb_plugin": {
        "artifact": "com.thesamet.scalapb:compilerplugin_2.11:0.9.8",
        "sha256": "9fda69065da447cf91aa3c923a95b80c2bdb9f46f95b2c14af97f533b099b5a9",
    },
    "scala_proto_rules_protoc_bridge": {
        "artifact": "com.thesamet.scalapb:protoc-bridge_2.11:0.7.14",
        "sha256": "314e34bf331b10758ff7a780560c8b5a5b09e057695a643e33ab548e3d94aa03",
    },
    "scala_proto_rules_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_2.11:0.9.8",
        "sha256": "c973046bff0e396dce25ce56e567a88b84e4b6cde0280964d23a2c1133f09a49",
    },
    "scala_proto_rules_scalapb_runtime_grpc": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime-grpc_2.11:0.9.8",
        "sha256": "6541e7f62c03dd6e63a77943c568b0719b3137e0ada135ad3ef045f7f99eb953",
    },
    "scala_proto_rules_scalapb_lenses": {
        "artifact": "com.thesamet.scalapb:lenses_2.11:0.9.8",
        "sha256": "20556c018aa55b196fef2e54d6f2a14d88821be8d1ba58e2c977fffb01d78972",
    },
    "scala_proto_rules_scalapb_fastparse": {
        "artifact": "com.lihaoyi:fastparse_2.11:3.0.2",
        "sha256": "6c5633ca76c8c69e275b7674c14c21cfc60820a875a98541cd9176d8f321c8cf",
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
        "artifact": "com.twitter:scrooge-core_2.11:21.2.0",
        "sha256": "d6cef1408e34b9989ea8bc4c567dac922db6248baffe2eeaa618a5b354edd2bb",
    },
    "io_bazel_rules_scala_scrooge_generator": {
        "artifact": "com.twitter:scrooge-generator_2.11:21.5.0",
        "sha256": "da03f5e1ab127acee6db6f61ed36d4d497e42ce70f53aa63a4717e79509d6d12",
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
    "io_bazel_rules_scala_javax_annotation_api": {
        "artifact": "javax.annotation:javax.annotation-api:1.3.2",
        "sha256": "e04ba5195bcd555dc95650f7cc614d151e4bcd52d29a10b8aa2197f3ab89ab9b",
    },
    "io_bazel_rules_scala_scopt": {
        "artifact": "com.github.scopt:scopt_2.11:4.1.0",
        "sha256": "def09e4fa5dcbb411f30483e640a647852d5c7265d6ff47019d61ce4af3e28fc",
    },

    # test only
    "com_twitter__scalding_date": {
        "testonly": True,
        "artifact": "com.twitter:scalding-date_2.11:0.17.4",
        "sha256": "754333f2b41a00910052eb92c85000945760592a7de0713ba3f95db841f603f7",
    },
    "org_typelevel__cats_core": {
        "testonly": True,
        "artifact": "org.typelevel:cats-core_2.11:2.0.0",
        "sha256": "ce2ecbeee121ef1746fbf2cf23bc34dfac8fbdb0f9e616aa47ec815b9b117b11",
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
