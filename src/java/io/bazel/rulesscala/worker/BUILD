java_library(name = "worker",
  srcs = [
      "Processor.java",
      "GenericWorker.java",
      ],
  deps = [
    "//src/java/com/google/devtools/build/lib:worker",
  ],
  visibility = ["//visibility:public"],
)

filegroup(
    name = "sources",
    data = glob(["**"]),
    visibility = ["//visibility:public"]
    )