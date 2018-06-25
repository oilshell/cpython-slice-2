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

# Stub out a few variables
readonly PREPROC_FLAGS=(
  -D OVM_MAIN \
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

build() {
  _build \
    Python/marshal.c \
    Objects/longobject.c \
    Objects/codeobject.c \
    "$@"
}

tag() {
  pushd $PY27
  ctags */*.[ch]
  popd
}

pygrep() {
  local pat=$1
  grep "$pat" $PY27/{Modules,Objects}/*.[ch]
}

"$@"
