import os
import re
import sys

def parse_gen_file_map(filename):
  r = re.compile("(\S+) -> (\S+)")
  with open(filename) as file:
    m = {}
    for line in file:
      g = r.match(line)
      k = g.group(1)
      v = m.get(k, set())
      v.add(g.group(2))
      m[k] = v
  return m

def main(jar_cmd, manifest, output_jar, cmd_file, srcjar_polluted, gen_file_map, include_base, pluck_base, files):

  gen_map = parse_gen_file_map(gen_file_map)
  #TODO we should just walk srcjar_polluted, and only include mentioned sources
  files_to_include = set()
  for file in files:
    for generated_source in gen_map[file]:
      files_to_include.add(os.path.relpath(generated_source, start=include_base))

  first = True
  with open(cmd_file, 'w') as out:
    for root, _, files in os.walk(srcjar_polluted):
      for file in files:
        _file = os.path.join(root, file)
        _relfile = os.path.relpath(_file, start=pluck_base)
        if _relfile in files_to_include:
          jar_flags = "uf"
          if first:
            jar_flags = "cmf " + manifest
            first = False
          cmd = "{jar} {jar_flags} {out} {file}".format(
            jar=jar_cmd,
            jar_flags=jar_flags,
            out=output_jar,
            file=_file,
          )
          out.write(cmd)
          out.write("\n")


if __name__ == '__main__':
  raise Exception(os.getcwd())
  main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6], sys.argv[7], sys.argv[8], sys.argv[9:])