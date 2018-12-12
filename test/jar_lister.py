from __future__ import print_function
import zipfile
import sys

for n in zipfile.ZipFile(sys.argv[1]).namelist():
  print(n)
