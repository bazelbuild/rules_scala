ThriftInfo = provider(fields = [
    "srcs",  # The source files in this rule
    "transitive_srcs",  # the transitive version of the above
    "external_jars",  # external jars of thrift files
    "transitive_external_jars",  # transitive version of the above
])
