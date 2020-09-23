artifacts = {
    "io_bazel_rules_scala_scala_library": {
        "artifact": "org.scala-lang:scala-library:2.12.11",
        "sha256": "dbfe77a3fc7a16c0c7cb6cb2b91fecec5438f2803112a744cb1b187926a138be",
    },
    "io_bazel_rules_scala_scala_compiler": {
        "artifact": "org.scala-lang:scala-compiler:2.12.11",
        "sha256": "e901937dbeeae1715b231a7cfcd547a10d5bbf0dfb9d52d2886eae18b4d62ab6",
    },
    "io_bazel_rules_scala_scala_reflect": {
        "artifact": "org.scala-lang:scala-reflect:2.12.11",
        "sha256": "5f9e156aeba45ef2c4d24b303405db259082739015190b3b334811843bd90d6a",
    },
    "io_bazel_rules_scala_scalatest": {
        "artifact": "org.scalatest:scalatest_2.12:3.0.5",
        "sha256": "b416b5bcef6720da469a8d8a5726e457fc2d1cd5d316e1bc283aa75a2ae005e5",
    },
    "io_bazel_rules_scala_scalactic": {
        "artifact": "org.scalactic:scalactic_2.12:3.0.5",
        "sha256": "57e25b4fd969b1758fe042595112c874dfea99dca5cc48eebe07ac38772a0c41",
    },
    "io_bazel_rules_scala_scala_xml": {
        "artifact": "org.scala-lang.modules:scala-xml_2.12:1.0.5",
        "sha256": "035015366f54f403d076d95f4529ce9eeaf544064dbc17c2d10e4f5908ef4256",
    },
    "io_bazel_rules_scala_scala_parser_combinators": {
        "artifact": "org.scala-lang.modules:scala-parser-combinators_2.12:1.0.4",
        "sha256": "282c78d064d3e8f09b3663190d9494b85e0bb7d96b0da05994fe994384d96111",
    },
    "org_scalameta_common": {
        "artifact": "org.scalameta:common_2.12:4.3.0",
        "sha256": "3bdb2ff71d3e86f94b4d31d2c40442f533655860749a92fd17e1f29b8deb8baa",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "org_scalameta_fastparse": {
        "artifact": "org.scalameta:fastparse_2.12:1.0.1",
        "sha256": "387ced762e93915c5f87fed59d8453e404273f49f812d413405696ce20273aa5",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scalameta_fastparse_utils",
        ],
    },
    "org_scalameta_fastparse_utils": {
        "artifact": "org.scalameta:fastparse-utils_2.12:1.0.1",
        "sha256": "9d8ad97778ef9aedef5d4190879ed0ec54969e2fc951576fe18746ae6ce6cfcf",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "org_scala_lang_modules_scala_collection_compat": {
        "artifact": "org.scala-lang.modules:scala-collection-compat_2.12:2.1.2",
        "sha256": "8aab3e1f9dd7bc392a2e27cf168af94fdc7cc2752131fc852192302fb21efdb4",
        "deps": [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "org_scalameta_parsers": {
        "artifact": "org.scalameta:parsers_2.12:4.3.0",
        "sha256": "d9f87d03b6b5e942f263db6dab75937493bfcb0fe7cfe2cda6567bf30f23ff3a",
        "deps": [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scalameta_trees",
        ],
    },
    "org_scalameta_scalafmt_core": {
        "artifact": "org.scalameta:scalafmt-core_2.12:2.3.2",
        "sha256": "4788e2045e99f4624162d3182016a05032a7ab1324c4a28af433aa070f916773",
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
        "artifact": "org.scalameta:scalameta_2.12:4.3.0",
        "sha256": "4d9487b434cbe9d89033824a4fc902dc7c782eea94961e8575df91ae96b10d6a",
        "deps": [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scala_lang_scalap",
            "@org_scalameta_parsers",
        ],
    },
    "org_scalameta_trees": {
        "artifact": "org.scalameta:trees_2.12:4.3.0",
        "sha256": "020b53681dd8e148d74ffa282276994bcb0f06c3425fb9a4bb9f8d161e22187a",
        "deps": [
            "@com_thesamet_scalapb_scalapb_runtime",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scalameta_common",
            "@org_scalameta_fastparse",
        ],
    },
    "org_typelevel_paiges_core": {
        "artifact": "org.typelevel:paiges-core_2.12:0.2.4",
        "sha256": "594ca130526023e80549484e45400d09810fa39d9fd6b4663830a00be2a8556a",
        "deps": [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "com_typesafe_config": {
        "artifact": "com.typesafe:config:1.3.3",
        "sha256": "b5f1d6071f1548d05be82f59f9039c7d37a1787bd8e3c677e31ee275af4a4621",
    },
    "org_scala_lang_scalap": {
        "artifact": "org.scala-lang:scalap:2.12.10",
        "sha256": "4641b0a55fe1ebec995b4daea9183c21651c03f77d2ed08b345507474eeabe72",
        "deps": [
            "@io_bazel_rules_scala_scala_compiler",
        ],
    },
    "com_thesamet_scalapb_lenses": {
        "artifact": "com.thesamet.scalapb:lenses_2.12:0.9.0",
        "sha256": "0a2fff4de17d270cea561618090c21d50bc891d82c6f9dfccdc20568f18d0260",
        "deps": [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "com_thesamet_scalapb_scalapb_runtime": {
        "artifact": "com.thesamet.scalapb:scalapb-runtime_2.12:0.9.0",
        "sha256": "b905fa66b3fd0fabf3114105cd73ae2bdddbb6e13188a6538a92ae695e7ad6ed",
        "deps": [
            "@com_google_protobuf_protobuf_java",
            "@com_lihaoyi_fastparse",
            "@com_thesamet_scalapb_lenses",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "com_lihaoyi_fansi": {
        "artifact": "com.lihaoyi:fansi_2.12:0.2.5",
        "sha256": "7d752240ec724e7370903c25b69088922fa3fb6831365db845cd72498f826eca",
        "deps": [
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "com_lihaoyi_fastparse": {
        "artifact": "com.lihaoyi:fastparse_2.12:2.1.2",
        "sha256": "92a98f89c4f9559715124599ee5ce8f0d36ee326f5c7ef88b51487de39a3602e",
        "deps": [
            "@com_lihaoyi_sourcecode",
        ],
    },
    "com_lihaoyi_pprint": {
        "artifact": "com.lihaoyi:pprint_2.12:0.5.3",
        "sha256": "2e18aa0884870537bf5c562255fc759d4ebe360882b5cb2141b30eda4034c71d",
        "deps": [
            "@com_lihaoyi_fansi",
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "com_lihaoyi_sourcecode": {
        "artifact": "com.lihaoyi:sourcecode_2.12:0.1.7",
        "sha256": "f07d79f0751ac275cc09b92caf3618f0118d153da7868b8f0c9397ce93c5f926",
        "deps": [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
    },
    "com_google_protobuf_protobuf_java": {
        "artifact": "com.google.protobuf:protobuf-java:3.10.0",
        "sha256": "161d7d61a8cb3970891c299578702fd079646e032329d6c2cabf998d191437c9",
    },
    "com_geirsson_metaconfig_core": {
        "artifact": "com.geirsson:metaconfig-core_2.12:0.9.4",
        "sha256": "970b3d74fc9b2982d9fb31d93f460000b41fff21c0b9d9ef9476ed333a010b2a",
        "deps": [
            "@com_lihaoyi_pprint",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_typelevel_paiges_core",
            "@org_scala_lang_modules_scala_collection_compat",
        ],
    },
    "com_geirsson_metaconfig_typesafe_config": {
        "artifact": "com.geirsson:metaconfig-typesafe-config_2.12:0.9.4",
        "sha256": "3165f30a85d91de7f8ba714e685a6b822bd1cbb365946f5d708163725df3ef5d",
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
