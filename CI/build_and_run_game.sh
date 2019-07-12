#!/bin/bash

set -e

if [ "$TEST_HARNESS" == true ]; then
  export ASAN_OPTIONS=detect_leaks=0;
  xvfb-run ./ci-regression.sh "/tmp/enigma-master" 4
else
  for mode in "Debug" "Run"; 
  do
    MODE="$mode" ./ci-build.sh
    if [ "$COMPILER" == "MinGW64" ]; then
      WINEPREFIX=~/.wine64 xvfb-run wine64 $OUTPUT > >(tee -a tee logs/enigma_game.log) 2> >(tee -a tee logs/enigma_game.log >&2)
    elif [ "$COMPILER" == "MinGW32" ]; then
      WINEPREFIX=~/.wine32 xvfb-run wine $OUTPUT > >(tee -a tee logs/enigma_game.log) 2> >(tee -a tee logs/enigma_game.log >&2)
    elif [[ ! "$GRAPHICS" =~ "OpenGLES" ]] && [ "$PLATFORM" != "SDL" ] ; then
      xvfb-run $OUTPUT > >(tee -a tee logs/enigma_game.log) 2> >(tee -a tee logs/enigma_game.log >&2)
    fi
    ./share_logs.sh
  done
fi
