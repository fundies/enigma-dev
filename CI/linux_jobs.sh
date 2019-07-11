#!/bin/bash

set -e

JOBS[0]='PLATFORM=None GRAPHICS=None AUDIO=None COLLISION=None NETWORK=None WIDGETS=None EXTENSIONS="None"'
JOBS[1]='PLATFORM=SDL GRAPHICS=OpenGL1'
JOBS[2]='PLATFORM=SDL GRAPHICS=OpenGL3'
JOBS[3]='GRAPHICS=OpenGL1 EXTENSIONS="ParticleSystems"'
JOBS[4]='GRAPHICS=OpenGL3 EXTENSIONS="ParticleSystems"'
JOBS[5]='GRAPHICS=OpenGLES2 PLATFORM=SDL EXTENSIONS="ParticleSystems"'
JOBS[6]='AUDIO=OpenAL EXTENSIONS="GME"'
JOBS[7]='AUDIO=SFML EXTENSIONS="GME"'
JOBS[8]='COLLISION=BBox NETWORK=None EXTENSIONS="Paths,MotionPlanning"'
JOBS[9]='COLLISION=Precise NETWORK=None EXTENSIONS="Paths,MotionPlanning"'
JOBS[10]='NETWORK=Asynchronous'
JOBS[11]='NETWORK=BerkeleySockets'
JOBS[12]='WIDGETS=GTK+'
JOBS[13]='WIDGETS=Zenity'
JOBS[14]='WIDGETS=KDialog'
JOBS[15]='COLLISION=BBox EXTENSIONS="Alarms,Timelines,DataStructures,Asynchronous,BasicGUI,DateTime,GM5Compat,IniFilesystem,Json,XRandR,Paths,MotionPlanning,ttf,Box2DPhysics,StudioPhysics,BulletDynamics"'
JOBS[16]='COMPILER=MinGW32 PLATFORM=Win32 Widgets=Win32 AUDIO=DirectSound EXTENSIONS="DirectShow,WindowsTouch,XInput,MediaControlInterface,FileDropper" OUTPUT="/tmp/test.exe"'
JOBS[17]='COMPILER=MinGW64 PLATFORM=Win32 Widgets=Win32 AUDIO=DirectSound EXTENSIONS="DirectShow,WindowsTouch,XInput,MediaControlInterface,FileDropper" OUTPUT="/tmp/test.exe"'
JOBS[18]='COMPILER=gcc32'
JOBS[19]='COMPILER=clang'
JOBS[20]='COMPILER=clang32'

if [ "$WORKER" != "" ]; then 

  JOB_COUNT=21
  TRAVIS_WORKERS=4

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
  MINGW_DEPS="FALSE"
  for job in $(seq $START 1 $END);
  do
    LINUX_DEPS=$(bash -c "${JOBS[$job]} LINUX_DEPS=\"$LINUX_DEPS\" ./CI/solve_engine_deps.sh")
    if [[ "${JOBS[$job]}" =~ "MinGW" ]]; then
      MINGW_DEPS="TRUE"
    fi
  done

  ###### Install Deps #######
  if [ "$TRAVIS_OS_NAME" == "linux" ]; then
    sudo apt-get -y install $LINUX_DEPS
    
    if [ "MINGW_DEPS" == "TRUE" ]; then
      curl -L https://github.com/enigma-dev/enigma-dev/files/2431000/enigma-libs.zip > enigma-libs.zip;
      unzip enigma-libs.zip -d ENIGMAsystem/;
      mv ENIGMAsystem/Install ENIGMAsystem/Additional;
    fi
    
  elif [ "$TRAVIS_OS_NAME" == "osx" ]; then
    brew install glew
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