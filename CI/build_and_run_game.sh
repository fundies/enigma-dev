#!/bin/bash

export DISPLAY=:1
Xvfb :1 -screen 0 1024x768x24 &
xfwm4 &
sleep 3

if [ "$TEST_HARNESS" == true ]; then
  echo "====================================================\n\
Running Test Harness\n\
===================================================="
  export ASAN_OPTIONS=detect_leaks=0;
  ./ci-regression.sh "/tmp/enigma-master" 4 || exit 1
else
  for mode in "Debug" "Run"; 
  do
    MODE="$mode" ./ci-build.sh
    if [ "$COMPILER" == "MinGW64" ] || [ "$COMPILER" == "MinGW32" ]; then
      wine $OUTPUT || exit 1
    elif [[ ! "$GRAPHICS" =~ "OpenGLES" ]]; then
      $OUTPUT || exit 1
    fi
  done
fi
