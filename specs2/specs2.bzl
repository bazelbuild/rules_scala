def specs2():

  # org.specs2:specs2-common_2.11:jar:3.8.4
  native.maven_jar(
      name = "org_scala_lang_modules_scala_parser_combinators_2_11",
      artifact = "org.scala-lang.modules:scala-parser-combinators_2.11:1.0.4",
      sha1 = "7369d653bcfa95d321994660477a4d7e81d7f490",
  )

  # org.specs2:specs2-common_2.11:jar:3.8.4
  native.maven_jar(
      name = "org_specs2_specs2_codata_2_11",
      artifact = "org.specs2:specs2-codata_2.11:3.8.4",
      sha1 = "d73d5caeb5cf064d275bf1511b68ab5a13030649",
  )

  # org.scalaz:scalaz-concurrent_2.11:bundle:7.2.3
  # org.scalaz:scalaz-effect_2.11:bundle:7.2.3
  # org.specs2:specs2-common_2.11:jar:3.8.4
  # org.specs2:specs2-codata_2.11:jar:3.8.4
  native.maven_jar(
      name = "org_scalaz_scalaz_core_2_11",
      artifact = "org.scalaz:scalaz-core_2.11:7.2.3",
      sha1 = "58d29a4615430829ef116e86de12327a17fe4827",
  )

  native.maven_jar(
      name = "specs2_core",
      artifact = "org.specs2:specs2-core_2.11:3.8.4",
  )

  # org.specs2:specs2-common_2.11:jar:3.8.4
  # org.specs2:specs2-core_2.11:jar:3.8.4
  native.maven_jar(
      name = "org_scala_lang_scala_reflect",
      artifact = "org.scala-lang:scala-reflect:2.11.8",
      sha1 = "b74530deeba742ab4f3134de0c2da0edc49ca361",
  )

  # org.specs2:specs2-core_2.11:jar:3.8.4
  native.maven_jar(
      name = "org_specs2_specs2_matcher_2_11",
      artifact = "org.specs2:specs2-matcher_2.11:3.8.4",
      sha1 = "51f382c7306cc57aab270e0f4089803dc35a7b1e",
  )

  # org.specs2:specs2-matcher_2.11:jar:3.8.4
  native.maven_jar(
      name = "org_specs2_specs2_common_2_11",
      artifact = "org.specs2:specs2-common_2.11:3.8.4",
      sha1 = "f3b280746b585b6872ef5ada0d78420b54226dfe",
  )

  # org.specs2:specs2-common_2.11:jar:3.8.4
  native.maven_jar(
      name = "org_scala_lang_modules_scala_xml_2_11",
      artifact = "org.scala-lang.modules:scala-xml_2.11:1.0.5",
      sha1 = "77ac9be4033768cf03cc04fbd1fc5e5711de2459",
  )

  # org.specs2:specs2-matcher_2.11:jar:3.8.4
  # org.scalaz:scalaz-concurrent_2.11:bundle:7.2.3
  # org.scala-lang.modules:scala-xml_2.11:bundle:1.0.5 wanted version 2.11.7
  # org.scalaz:scalaz-effect_2.11:bundle:7.2.3
  # org.scalaz:scalaz-core_2.11:bundle:7.2.3
  # org.scala-lang:scala-reflect:jar:2.11.8
  # org.specs2:specs2-common_2.11:jar:3.8.4
  # org.specs2:specs2-codata_2.11:jar:3.8.4
  # org.specs2:specs2-core_2.11:jar:3.8.4
  # org.scala-lang.modules:scala-parser-combinators_2.11:bundle:1.0.4 wanted version 2.11.6
  native.maven_jar(
      name = "org_scala_lang_scala_library",
      artifact = "org.scala-lang:scala-library:2.11.8",
      sha1 = "ddd5a8bced249bedd86fb4578a39b9fb71480573",
  )

  # org.specs2:specs2-common_2.11:jar:3.8.4
  # org.specs2:specs2-codata_2.11:jar:3.8.4
  native.maven_jar(
      name = "org_scalaz_scalaz_concurrent_2_11",
      artifact = "org.scalaz:scalaz-concurrent_2.11:7.2.3",
      sha1 = "4788f84d28f8de6783b60c91de6da14f85980bca",
  )

  # org.scalaz:scalaz-concurrent_2.11:bundle:7.2.3
  # org.specs2:specs2-common_2.11:jar:3.8.4
  # org.specs2:specs2-codata_2.11:jar:3.8.4
  native.maven_jar(
      name = "org_scalaz_scalaz_effect_2_11",
      artifact = "org.scalaz:scalaz-effect_2.11:7.2.3",
      sha1 = "8ab944e32781a44f2aecba99d392c3142b25af1c",
  )
