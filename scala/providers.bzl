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
    if ExtraInformation in targ:
      extras.append(targ[ExtraInformation].transitive_extra_information)
  return depset(transitive = extras)
