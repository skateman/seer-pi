#!/bin/bash

set -x

TMP_OUTPUT="tmp"

mkdir -p $TMP_OUTPUT/DEBIAN
mkdir -p $TMP_OUTPUT/usr/local/bin
mkdir -p $TMP_OUTPUT/usr/lib/systemd/system/

cp seer-pi-streamer $TMP_OUTPUT/usr/local/bin/
cp seer-pi-streamer.service $TMP_OUTPUT/usr/lib/systemd/system/

cat <<- EOF > $TMP_OUTPUT/DEBIAN/control
Package: seer-pi
Version: ${TRAVIS_TAG}
Maintainer: David Halasz
Architecture: all
Depends: python3-picamera (>= 1.13)
Description: Simple security camera system based on Raspberry Pi
License: MIT
EOF

dpkg-deb --build $TMP_OUTPUT "seer-pi-${TRAVIS_TAG}.deb"

rm -rf $TMP_OUTPUT

set +x
