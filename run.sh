#!/bin/bash
#
# Usage:
#   ./run.sh <function name>

set -o nounset
set -o pipefail
set -o errexit

readonly PY27='Python-2.7.13'

readonly CC=${CC:-cc}  # cc should be on POSIX systems
readonly BASE_CFLAGS='-fno-strict-aliasing -fwrapv -Wall -Wstrict-prototypes'
readonly INCLUDE_PATHS=(-I . -I Include)

readonly EMPTY_STR='""'

# Using OVM_SLICE instead of OVM_MAIN

# Stub out a few variables
readonly PREPROC_FLAGS=(
  -D OVM_SLICE \
  -D PYTHONPATH="$EMPTY_STR" \
  -D VERSION="$EMPTY_STR" \
  -D VPATH="$EMPTY_STR" \
  -D Py_BUILD_CORE \
  # Python already has support for disabling complex numbers!
  -D WITHOUT_COMPLEX
)

readonly PREFIX=/usr/local

_build() {
  mkdir -p _tmp
  local out=$PWD/_tmp/ovm2

  pushd $PY27

  time $CC \
    ${BASE_CFLAGS} \
    "${INCLUDE_PATHS[@]}" \
    "${PREPROC_FLAGS[@]}" \
    -D PREFIX="\"$PREFIX\"" \
    -D EXEC_PREFIX="\"$PREFIX\"" \
    -o $out \
    -l m \
    "$@"

  popd
}

# Starting with longobject.c
# - It needs its typeobject.c -- do NOT want this.  6800 lines of the
# meta-object protocol.
# - It needs errors.c, which needs exceptions.c
#   - exceptions seems to need dicts
#   - dicts need garbage collection!

# Problem: I really want just a basic arbitrarily sized int, without
# reflection, subclassing, etc.  No garbage collection either?

# Other stuff we might need: 
# - ref counting
# - garbage collection
# - slices?  Or could we reimplement that without the generic objects?
# - Stuff for the C API, e.g. args.c
#   - TODO: Test native/libc.c, which mostly uses PyArg_ParseTuple() etc.

# Excluded:
# - classobject.c (old style and new style)
# - fileobject.c
# - for now: floats (brings in float to string conversion, etc.)
# - descriptors

# What about: bool?  This is just int?

    #Python/marshal.c \
    #Objects/codeobject.c \
    #Objects/typeobject.c
    #Objects/typeobject.c

# NOTE: boolobject.c isn't technically necessary, but it's an easy way to
# reduce the number of link errors.

readonly FILES=(
    Objects/longobject.c 
    Objects/boolobject.c
    Objects/stringobject.c 
    Objects/dictobject.c 
    #Objects/setobject.c
    Objects/listobject.c
    Objects/tupleobject.c
    Objects/object.c
    Objects/abstract.c
    Objects/exceptions.c
    Objects/obmalloc.c
    Python/errors.c
    Python/mysnprintf.c
    Python/sigcheck.c
    Python/modsupport.c
    Python/getargs.c
    Modules/gcmodule.c
    ../ovm.c
)

build() {
  local out=_tmp/build-$$.pid

  set +o errexit
  _build "${FILES[@]}" 2>&1 | tee $out

  echo
  wc -l $out

  count-undefined $out
}

# link errors: undefined reference
count-undefined() {
  egrep -o 'undefined reference to `.*' "$@" > _tmp/undefined.txt
  cat _tmp/undefined.txt | sort | uniq -c | sort -n
  echo
  wc -l _tmp/undefined.txt
}

count() {
  pushd $PY27 >/dev/null
  wc -l "${FILES[@]}" | sort -n
  popd >/dev/null
}

tag() {
  pushd $PY27
  ctags */*.[ch]
  popd
}

grep-all() {
  local pat=$1
  grep "$pat" $PY27/{Python,Modules,Objects}/*.[ch]
}

grep-subset() {
  local pat=$1
  pushd $PY27 >/dev/null
  grep "$pat" "${FILES[@]}"
  popd >/dev/null
}

"$@"
