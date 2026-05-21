#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

depends=(
  alsa-lib
  aom
  binutils
  bzip2
  cairo
  cpio
  dav1d
  fontconfig
  freetype2
  fribidi
  gettext
  glib2
  glibc
  glslang
  gmp
  gnutls
  gsm
  harfbuzz
  jack
  lame
  lcms2
  libass
  libavc1394
  libbluray
  libbs2b
  libdrm
  libdvdnav
  libdvdread
  libelf
  libgcc
  libiec61883
  libjxl
  libmodplug
  libopenmpt
  libplacebo
  libpulse
  libraw1394
  librsvg
  libsoxr
  libssh
  libtheora
  libva
  libvdpau
  libvorbis
  libvpl
  libvpx
  libwebp
  libx11
  libxcb
  libxext
  libxml2
  libxv
  ocl-icd
  opencore-amr
  openjpeg2
  openssl
  opus
  pahole
  perl
  python
  rav1e
  rubberband
  rust
  rust-bindgen
  rust-src
  sdl2
  snappy
  speex
  srt
  svt-av1
  tar
  v4l-utils
  vid.stab
  vmaf
  vulkan-icd-loader
  x264
  x265
  xvidcore
  xz
  bc
  xxhash
  zeromq
  zimg
  zlib
  zstd
)

makedepends=(
  amf-headers
  avisynthplus
  clang
  ffnvcodec-headers
  frei0r-plugins
  git
  ladspa
  libgl
  nasm
  opencl-headers
  spirv-headers
  vapoursynth
  vulkan-headers
)

check_list() {
  local label="$1"
  shift
  local pkgs=("$@")
  local missing=()

  echo -e "\n==== Checking $label ===="
  for pkg in "${pkgs[@]}"; do
    if pacman -Qq "$pkg" &>/dev/null; then
      echo -e "[   ${GREEN}OK${NC}   ] $pkg"
    else
      echo -e "[ ${RED}MISSING${NC} ] $pkg"
      missing+=("$pkg")
    fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    echo -e "\n${RED}➔ Missing items found:${NC} ${missing[*]}"
    echo -e "${GREEN}Calling paru to install missing dependencies...${NC}\n"
    paru -S --needed "${missing[@]}"
  else
    echo -e "\n${GREEN}✓ All $label satisfied.${NC}"
  fi
}

check_list "Runtime Dependencies (depends)" "${depends[@]}"
check_list "Build Dependencies (makedepends)" "${makedepends[@]}"
