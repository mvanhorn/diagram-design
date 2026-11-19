#!/usr/bin/env python3
"""Print the first names in a ZIP, then the file count."""
import sys
import zipfile

path = sys.argv[1]
limit = int(sys.argv[2]) if len(sys.argv) > 2 else 14
names = zipfile.ZipFile(path).namelist()
for n in names[:limit]:
    print(n)
files = [n for n in names if not n.endswith("/")]
print("... %d files" % len(files))
