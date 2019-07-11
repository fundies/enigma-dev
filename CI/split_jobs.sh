#!/bin/bash

set -e

if [ "$TRAVIS_OS_NAME" == "linux" ]; then
  source ./CI/linux_jobs.sh
elif [ "$TRAVIS_OS_NAME" == "osx" ]; then
  source ./CI/osx_jobs.sh
else
  echo "Error: Unsupported OS"
  exit 1
fi

if [ "$WORKER" != "" ]; then 

  SPLIT=$(($JOB_COUNT / $TRAVIS_WORKERS))
  START=$(( $WORKER * $SPLIT ))
  if [[ $WORKER -lt $((TRAVIS_WORKERS-1)) ]]; then
    END=$(($WORKER * $SPLIT + $SPLIT))
  else
    END=$JOB_COUNT
  fi

fi

if [ "$1" == "install" ]; then

  ###### Figure out our deps ######
  LINUX_DEPS="xvfb"
  OSX_DEPS="glew"
  MINGW_DEPS="FALSE"
  for job in $(seq $START 1 $END);
  do
    if [ "$TRAVIS_OS_NAME" == "linux" ]; then
      LINUX_DEPS=$(bash -c "${JOBS[$job]} LINUX_DEPS=\"$LINUX_DEPS\" ./CI/solve_engine_deps.sh")
      if [[ "${JOBS[$job]}" =~ "MinGW" ]]; then
        MINGW_DEPS="TRUE"
      fi
    elif [ "$TRAVIS_OS_NAME" == "osx" ]; then
      OSX_DEPS=$(bash -c "${JOBS[$job]} OSX_DEPS=\"$OSX_DEPS\" ./CI/solve_engine_deps.sh")
    fi
  done

  ###### Install Deps #######
  if [ "$TRAVIS_OS_NAME" == "linux" ]; then
    sudo apt-get -y install $LINUX_DEPS
    
    if [ "MINGW_DEPS" == "TRUE" ]; then
      sudo update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix
      curl -L https://github.com/enigma-dev/enigma-dev/files/2431000/enigma-libs.zip > enigma-libs.zip;
      unzip enigma-libs.zip -d ENIGMAsystem/;
      mv ENIGMAsystem/Install ENIGMAsystem/Additional;
    fi
    
  elif [ "$TRAVIS_OS_NAME" == "osx" ]; then
    brew install $OSX_DEPS
  fi
  
elif [ "$1" == "run" ]; then

  ###### Run Jobs #######
  for job in $(seq $START 1 $END);
  do
    echo -e "\n\n\e[32m====================================================\n\
\e[32mRunning ${JOBS[$job]}\n\
\e[32m====================================================\n\n"
    bash -c "${JOBS[$job]} ./CI/build_and_run_game.sh"
  done;

else
  echo "Error: \"run\" or \"install\" argument required"
  exit 1
fi
