#!/bin/bash

set -e

JOBS[0]='COMPILER=gcc PLATFORM=None'
JOBS[1]='COMPILER=clang PLATFORM=None'

JOB_COUNT=2
TRAVIS_WORKERS=1
