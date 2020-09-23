artifacts = {
    "io_bazel_rules_scala_scala_library": {
        "artifact": "org.scala-lang:scala-library:2.11.12",
        "sha256": "0b3d6fd42958ee98715ba2ec5fe221f4ca1e694d7c981b0ae0cd68e97baf6dce",
    },
    "io_bazel_rules_scala_scala_compiler": {
        "artifact": "org.scala-lang:scala-compiler:2.11.12",
        "sha256": "3e892546b72ab547cb77de4d840bcfd05c853e73390fed7370a8f19acb0735a0",
    },
    "io_bazel_rules_scala_scala_reflect": {
        "artifact": "org.scala-lang:scala-reflect:2.11.12",
        "sha256": "6ba385b450a6311a15c918cf8688b9af9327c6104f0ecbd35933cfcd3095fe04",
    },
    "io_bazel_rules_scala_scalatest": {
        "artifact": "org.scalatest:scalatest_2.11:3.0.5",
        "sha256": "2aafeb41257912cbba95f9d747df9ecdc7ff43f039d35014b4c2a8eb7ed9ba2f",
    },
    "io_bazel_rules_scala_scalactic": {
        "artifact": "org.scalactic:scalactic_2.11:3.0.5",
        "sha256": "84723064f5716f38990fe6e65468aa39700c725484efceef015771d267341cf2",
    },
    "io_bazel_rules_scala_scala_xml": {
        "artifact": "org.scala-lang.modules:scala-xml_2.11:1.0.5",
        "sha256": "767e11f33eddcd506980f0ff213f9d553a6a21802e3be1330345f62f7ee3d50f",
    },
    "io_bazel_rules_scala_scala_parser_combinators": {
        "artifact": "org.scala-lang.modules:scala-parser-combinators_2.11:1.0.4",
        "sha256": "0dfaafce29a9a245b0a9180ec2c1073d2bd8f0330f03a9f1f6a74d1bc83f62d6",
    },
    "org_scalameta_common": {
        "artifact": "org.scalameta:common_2.11:4.3.0",
        "sha256": "6330798bcbd78d14d371202749f32efda0465c3be5fd057a6055a67e21335ba0",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "org_scalameta_fastparse": {
        "artifact": "org.scalameta:fastparse_2.11:1.0.1",
        "sha256": "49ecc30a4b47efc0038099da0c97515cf8f754ea631ea9f9935b36ca7d41b733",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scalameta_fastparse_utils",
        ],
    },
    "org_scalameta_fastparse_utils": {
        "artifact": "org.scalameta:fastparse-utils_2.11:1.0.1",
        "sha256": "93f58db540e53178a686621f7a9c401307a529b68e051e38804394a2a86cea94",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "org_scala_lang_modules_scala_collection_compat": {
        "artifact": "org.scala-lang.modules:scala-collection-compat_2.11:2.1.2",
        "sha256": "e9667b8b7276aeb42599f536fe4d7caab06eabc55e9995572267ad60c7a11c8b",
        "deps": [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "org_scalameta_parsers": {
        "artifact": "org.scalameta:parsers_2.11:4.3.0",
        "sha256": "724382abfac27b32dec6c21210562bc7e1b09b5268ccb704abe66dcc8844beeb",
        "deps": [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scalameta_trees",
        ],
    },
    "org_scalameta_scalafmt_core": {
        "artifact": "org.scalameta:scalafmt-core_2.11:2.3.2",
        "sha256": "6bf391e0e1d7369fda83ddaf7be4d267bf4cbccdf2cc31ff941999a78c30e67f",
        "deps": [
            "@com_geirsson_metaconfig_core",
            "@com_geirsson_metaconfig_typesafe_config",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
            "@org_scalameta_scalameta",
            "@org_scala_lang_modules_scala_collection_compat",
        ],
    },
    "org_scalameta_scalameta": {
        "artifact": "org.scalameta:scalameta_2.11:4.3.0",
        "sha256": "94fe739295447cd3ae877c279ccde1def06baea02d9c76a504dda23de1d90516",
        "deps": [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scala_lang_scalap",
            "@org_scalameta_parsers",
        ],
    },
    "org_scalameta_trees": {
        "artifact": "org.scalameta:trees_2.11:4.3.0",
        "sha256": "d24d5d63d8deafe646d455c822593a66adc6fdf17c8373754a3834a6e92a8a72",
        "deps": [
            "@com_thesamet_scalapb_scalapb_runtime",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scalameta_common",
            "@org_scalameta_fastparse",
        ],
    },
    "org_typelevel_paiges_core": {
        "artifact": "org.typelevel:paiges-core_2.11:0.2.4",
        "sha256": "aa66fbe0457ca5cb5b9e522d4cb873623bb376a2e1ff58c464b5194c1d87c241",
        "deps": [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "com_typesafe_config": {
        "artifact": "com.typesafe:config:1.3.3",
        "sha256": "b5f1d6071f1548d05be82f59f9039c7d37a1787bd8e3c677e31ee275af4a4621",
    },
    "org_scala_lang_scalap": {
        "artifact": "org.scala-lang:scalap:2.11.10",
        "sha256": "a6dd7203ce4af9d6185023d5dba9993eb8e80584ff4b1f6dec574a2aba4cd2b7",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler",
        ],
    },
    "com_thesamet_scalapb_lenses": {
        "artifact": "com.thesamet.scalapb:lenses_2.11:0.9.0",
        "sha256": "f4809760edee6abc97a7fe9b7fd6ae5fe1006795b1dc3963ab4e317a72f1a385",
        "deps": [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "com_thesamet_scalapb_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_2.11:0.9.0",
        "sha256": "ab1e449a18a9ce411eb3fec31bdbca5dd5fae4475b1557bb5e235a7b54738757",
        "deps": [
            "@com_google_protobuf_protobuf_java",
            "@com_lihaoyi_fastparse",
            "@com_thesamet_scalapb_lenses",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "com_lihaoyi_fansi": {
        "artifact": "com.lihaoyi:fansi_2.11:0.2.5",
        "sha256": "1ff0a8304f322c1442e6bcf28fab07abf3cf560dd24573dbe671249aee5fc488",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
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
        "artifact": "com.lihaoyi:pprint_2.11:0.5.3",
        "sha256": "fb5e4921e7dff734d049e752a482d3a031380d3eea5caa76c991312dee9e6991",
        "deps": [
            "@com_lihaoyi_fansi",
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "com_lihaoyi_sourcecode": {
        "artifact": "com.lihaoyi:sourcecode_2.11:0.1.7",
        "sha256": "33516d7fd9411f74f05acfd5274e1b1889b7841d1993736118803fc727b2d5fc",
        "deps": [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "com_google_protobuf_protobuf_java": {
        "artifact": "com.google.protobuf:protobuf-java:3.10.0",
        "sha256": "161d7d61a8cb3970891c299578702fd079646e032329d6c2cabf998d191437c9",
    },
    "com_geirsson_metaconfig_core": {
        "artifact": "com.geirsson:metaconfig-core_2.11:0.9.4",
        "sha256": "5d5704a1f1c4f74aed26248eeb9b577274d570b167cec0bf51d2908609c29118",
        "deps": [
            "@com_lihaoyi_pprint",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_typelevel_paiges_core",
            "@org_scala_lang_modules_scala_collection_compat",
        ],
    },
    "com_geirsson_metaconfig_typesafe_config": {
        "artifact": "com.geirsson:metaconfig-typesafe-config_2.11:0.9.4",
        "sha256": "52d2913640f4592402aeb2f0cec5004893d02acf26df4aa1cf8d4dcb0d2b21c7",
        "deps": [
            "@com_geirsson_metaconfig_core",
            "@com_typesafe_config",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scala_lang_modules_scala_collection_compat",
        ],
    },
    "io_bazel_rules_scala_org_openjdk_jmh_jmh_core": {
        "artifact": "org.openjdk.jmh:jmh-core:1.20",
        "sha256": "1688db5110ea6413bf63662113ed38084106ab1149e020c58c5ac22b91b842ca",
    },
    "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_asm": {
        "artifact": "org.openjdk.jmh:jmh-generator-asm:1.20",
        "sha256": "2dd4798b0c9120326310cda3864cc2e0035b8476346713d54a28d1adab1414a5",
    },
    "io_bazel_rules_scala_org_openjdk_jmh_jmh_generator_reflection": {
        "artifact": "org.openjdk.jmh:jmh-generator-reflection:1.20",
        "sha256": "57706f7c8278272594a9afc42753aaf9ba0ba05980bae0673b8195908d21204e",
    },
    "io_bazel_rules_scala_org_ows2_asm_asm": {
        "artifact": "org.ow2.asm:asm:6.1.1",
        "sha256": "dd3b546415dd4bade2ebe3b47c7828ab0623ee2336604068e2d81023f9f8d833",
    },
    "io_bazel_rules_scala_net_sf_jopt_simple_jopt_simple": {
        "artifact": "net.sf.jopt-simple:jopt-simple:4.6",
        "sha256": "3fcfbe3203c2ea521bf7640484fd35d6303186ea2e08e72f032d640ca067ffda",
    },
    "io_bazel_rules_scala_org_apache_commons_commons_math3": {
        "artifact": "org.apache.commons:commons-math3:3.6.1",
        "sha256": "1e56d7b058d28b65abd256b8458e3885b674c1d588fa43cd7d1cbb9c7ef2b308",
    },
}
