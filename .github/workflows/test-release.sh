#!/bin/sh
set -eu
set -x
root=$1;shift
host=$1;shift

curl --version
xz --version
dst='/usr/local'
for d in $root/*; do
    case $(basename $d) in
    git-*-$host)
        echo "::group::$d"
        mkdir -p $dst
        rm -rf $dst/*
        for f in $d/*.tar.xz; do
            xz -d <$f >/tmp/tar
            tar -xf /tmp/tar -C $dst
            rm /tmp/tar
        done
        $dst/bin/git --version
        $dst/bin/git status
        $dst/bin/git ls-remote
        ;;
    *)
        echo "Ignoring $d"
        ;;
    esac
done
