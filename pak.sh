#!/usr/bin/env bash
set -euo pipefail

PKGS=(
  davs2
  flite1
  frei0r-plugins
  kvazaar
  ladspa
  lcevcdec
  libaribcaption
  libcaca
  libcdio-paranoia
  libdc1394
  libfdk-aac
  libgme
  libilbc
  libklvanc
  liblc3
  libmysofa
  librabbitmq-c
  librist
  lilv
  mpeghdec
  openal
  openapv
  opencolorio
  openh264
  qrencode
  quirc
  rtmpdump
  shine
  smbclient
  sndio
  svt-hevc
  svt-jpeg-xs-git
  svt-vp9
  twolame
  uavs3d-git
  vapoursynth
  vo-amrwbenc
  vvenc
  xavs
  xavs2
  xevd
  xeve
  zvbi
)

paru -S --needed --noconfirm "${PKGS[@]}"

makepkg -si --noconfirm
