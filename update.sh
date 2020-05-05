#!/usr/bin/env bash

apt-ftparchive --arch amd64 packages pool > dists/bionic/main/binary-amd64/Packages
gzip -kf dists/bionic/main/binary-amd64/Packages

apt-ftparchive --arch i386 packages pool > dists/bionic/main/binary-i386/Packages
gzip -kf dists/bionic/main/binary-i386/Packages

cd dists/bionic
cat Distributions > Release
apt-ftparchive release . >> Release
gpg --clearsign -o InRelease Release
gpg -abs -o Release.gpg Release