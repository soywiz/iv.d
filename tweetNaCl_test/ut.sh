#!/bin/sh


USE_DMD="tan"
USE_DMD_VANILLA="ona"
SHORT_TEST="ona"
USE_OPT="ona"

while [ $# != 0 ]; do
  if [ "z$1" = "z--help" ]; then
    echo "usage: $0 [options]"
    echo "options:"
    echo "  --dmd   use DMD"
    echo "  --lite  lite tests"
    echo "  --dmdv  use vanilla DMD"
    echo "  --gdc   use GDC"
    echo "  --opt   optimize"
    exit 1
  fi
  if [ "z$1" = "z--dmd" ]; then
    USE_DMD="tan"
  elif [ "z$1" = "z--lite" ]; then
    SHORT_TEST="tan"
  elif [ "z$1" = "z--dmdv" ]; then
    USE_DMD="tan"
    USE_DMD_VANILLA="tan"
  elif [ "z$1" = "z--dmd" ]; then
    USE_DMD="tan"
  elif [ "z$1" = "z--gdc" ]; then
    USE_DMD="ona"
  elif [ "z$1" = "z--opt" ]; then
    USE_OPT="tan"
  elif [ "z$1" = "z--lite" ]; then
    SHORT_TEST="tan"
  elif [ "z$1" = "z--dmdv" ]; then
    USE_DMD="tan"
    USE_DMD_VANILLA="tan"
  else
    echo "invalid arg: $1"
    exit 1
  fi
  shift
done


rm tweetNaCl *.o 2>/dev/null

if [ $USE_DMD = "tan" ]; then
  if [ $SHORT_TEST = "tan" ]; then
    tt=""
  else
    tt="-version=unittest_full"
  fi
  if [ $USE_DMD_VANILLA = "tan" ]; then
    dmdbin="dmd67"
  else
    dmdbin="dmd"
  fi
  echo -n "DMD... [$dmdbin]"
  if [ $USE_OPT = "tan" ]; then
    echo -n "[opt]"
    opts="-O -inline"
  else
    opts=""
  fi
  time "$dmdbin" $tt $opts -g -w -oftweetNaCl ../tweetNaCl.d tweetNaCl_test.d
else
  if [ $SHORT_TEST = "tan" ]; then
    tt=""
  else
    tt="-fversion=unittest_full"
  fi
  echo -n "GDC..."
  time gdc $tt -O3 -fwrapv -march=native -mtune=native -Wall -o tweetNaCl ../tweetNaCl.d tweetNaCl_test.d
fi
if [ $? != 0 ]; then
  echo "FUCK!"
  rm *.o 2>/dev/null
  exit 1
fi
rm *.o 2>/dev/null

time ./tweetNaCl
