#!/usr/bin/env python3
"""Count files in a ZIP (exclude directory entries)."""
import os
import sys
import zipfile

path = sys.argv[1]
names = zipfile.ZipFile(path).namelist()
files = [n for n in names if not n.endswith("/")]
print("%d files in %s" % (len(files), path))
print("%d bytes" % os.path.getsize(path))
