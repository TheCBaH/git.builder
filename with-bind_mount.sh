#!/bin/sh
set -eu
set -x
src=$1;shift
dst=$1;shift
sudo mount --bind $src $dst
if "$@"; then
    rc=$?
else
    rc=$?
fi
sudo umount $dst
exit $rc
