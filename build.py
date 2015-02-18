#!/usr/bin/env python3

"""This is a build system for the addressbook project."""

import copy
from fnmatch import fnmatch
import os
import sys

class BuildError(Exception):
  def __init__(self, message, code):
    super(BuildError, self).__init__(message)
    self.code = code


class FileSet(object):
  def __init__(self):
    self._files = set()

  def files(self):
    return self._files()

  def add(self, file):
    self._files.add(file)

  def remove(self, file):
    self._files.remove(remove)

  def __len__(self):
    return len(self._files)

  def clone(self):
    fs = FileSet()
    fs._files = copy.deepcopy(self._files)
    return fs

  @staticmethod
  def find(dir, *patterns):
    fs = FileSet()
    for root, dirnames, filenames in os.walk(dir):
      for filename in filenames:
        fullname = os.path.join(root, filename)
        for pattern in patterns:
          if fnmatch(fullname, pattern):
            fs._files.add(fullname)
            break
    return fs

  def infilter(self, *patterns):
    return self.__filter(True, patterns)

  def exfilter(self, *patterns):
    return self.__filter(False, patterns)

  def __filter(self, include, patterns):
    fs = FileSet()
    for filename in self._files:
      matched = False
      for pattern in patterns:
        if fnmatch(filename, pattern):
          matched = True
          break
      if matched:
        if include:
          fs._files.add(filename)
      else:
        if not include:
          fs._files.add(filename)
    return fs

  def split(self, *patterns):
    """Splits the FileSet into sub FileSets based on specified patterns.

    Args:
      *patterns : patterns on which to split this FileSet

    Returns:
      A tuple of FileSets one per each pattern. If files do not match any
      pattern, an additional FileSet will be created to hold them.
    """

    fss = [FileSet() for ugh in range(0, len(patterns) + 1)]
    for filename in self._files:
      matched = False
      for idx, pattern in enumerate(patterns):
        if fnmatch(filename, pattern):
          fss[idx]._files.add(filename)
          matched = True
          break
      if not matched:
        fss[-1]._files.add(filename)
    if len(fss[-1]) == 0:
      fss = fss[:-1]
    return tuple(fss)

  def __iter__(self):
    return self._files.__iter__()

  def __next__(self):
    return self._files.__next__()

  def __str__(self):
    return self._files.__str__()

  def __add__(self, other):
    fs = FileSet()
    fs._files = self._files
    for file in other._files:
      fs._files.add(file)
    return fs

  def __sub__(self, other):
    fs = FileSet()
    fs._files = self._files
    for file in other._files:
      fs._files.remove(file)
    return fs


#class Node(object):
#  """This is a graph node in the build system."""
#
#  def __init__(self, name):
#    self.name = name
#    self.inputs = set()
#    self.hash = None

class CppBuild(object):
  def __init__(self, cxx, cflags, ldflags):
    self.cxx = cxx
    self.cflags = cflags
    self.ldflags = ldflags

  def dependencies(src):


def main(argv=sys.argv):
  # get the user input target
  if len(argv) < 2:
    raise BuildError('no target given', -1)
  target = argv[1]

  # group input files
  all_files = FileSet.find('src', '*.proto', '*.h', '*.cc').exfilter('*.pb.*')
  all_pbs, all_hdrs, all_srcs = all_files.split('*.proto', '*.h', '*.cc')
  tst_pbs, app_pbs = all_pbs.split('*_TEST*')
  tst_hdrs, app_hdrs = all_hdrs.split('*_TEST*')
  tst_srcs, app_srcs = all_srcs.split('*_TEST*')

  ##############################
  # make a Makefile
  makefile = open('/tmp/makefile', 'w')

  for src in all_srcs:
    print('

  # build the dependency graph


if __name__ == '__main__':
  try:
    main()
    sys.exit(0)
  except BuildError as ex:
    print(ex.message, file=sys.stderr)
    sys.exit(ex.code)
