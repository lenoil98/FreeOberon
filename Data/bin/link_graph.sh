#!/bin/bash
#   This script is run by Free Oberon on Linux
#   to link a graphics program.
#   When it is being run, the current directory
#   must be the root directory of Free Oberon.

THENAME="${1%.*}"
ONAME="${THENAME##*/}"
OFRDIR="../Data/bin/OfrontPlus/Target/Linux_amd64"
PATH="$OFRDIR:$PATH"
CC="gcc"

cd bin





shift











$CC -O0 -fno-exceptions \
  -I ../src \
  -I $OFRDIR/../../Mod/Lib \
  -I $OFRDIR/Lib/Obj \
  $ONAME.c -o $ONAME \
  $@ \
  ../Data/bin/libFreeOberon.a \
  $OFRDIR/Lib/libOfront.a \
  $(pkg-config \
    allegro_primitives-5 allegro_image-5 allegro_audio-5 \
    allegro_acodec-5 allegro_font-5 allegro_dialog-5 \
    allegro-5 --libs --cflags)
retcode=$?
cd ..
exit $retcode
