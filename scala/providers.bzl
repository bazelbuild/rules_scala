ScalaInfo = provider(
    fields = [
        "statsfile"
    ])

JarToLabel = provider(
    fields = [
        "jars_to_labels"
    ])

ExtraInformation = provider(
    fields = [
        "transitive_extra_information"
    ])

def collect_transitive_extra_info(targs):
  extras = []
  for targ in targs:
    print(targ)
    if ExtraInformation in targ:
      print(targ[ExtraInformation])
      extras.append(targ[ExtraInformation].transitive_extra_information)
    else:
      print(str(targ) + " does not have ExtraInformation")
      if JavaInfo in targ:
        print("but does have JavaInfo")
  return depset(transitive = extras)
