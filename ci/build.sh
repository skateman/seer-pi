#!/bin/bash

set -x

TMP_OUTPUT="tmp"

mkdir -p $TMP_OUTPUT/DEBIAN
mkdir -p $TMP_OUTPUT/etc
mkdir -p $TMP_OUTPUT/usr/local/bin
mkdir -p $TMP_OUTPUT/usr/lib/systemd/system

cp seer-pi $TMP_OUTPUT/usr/local/bin/
cp seer-pi.service $TMP_OUTPUT/usr/lib/systemd/system/
cp seer-pi.conf $TMP_OUTPUT/etc/

cat <<- EOF > $TMP_OUTPUT/DEBIAN/control
Package: seer-pi
Version: ${TRAVIS_TAG}
Maintainer: David Halasz
Architecture: armhf
Depends: python-picamera (>= 1.13), python-requests (>= 2.12), ffmpeg
Description: Simple RTSP forwarder the Raspberry Pi Camera
License: MIT
EOF

cat <<- EOF > $TMP_OUTPUT/DEBIAN/conffiles
/etc/seer-pi.conf
EOF

dpkg-deb --build $TMP_OUTPUT "seer-pi-${TRAVIS_TAG}_armhf.deb"

rm -rf $TMP_OUTPUT

set +x
