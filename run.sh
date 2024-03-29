#!/bin/bash

# ------------------------
# Help
# ------------------------
help()
{
  echo "
Options: [-p package] [-b build] [-m mode]
-p package    Package to build/run: all, <package name> (default: all)
-b build      Build setting: last, debug, release (default: last)
-m mode       Run mode: build, sim, real (default: build)
-h            Help
  "
  exit 1
}

# ------------------------
# Arguments
# ------------------------
pkg="all"
pkg_make_cmd=""
build="last"
mode="build"
control="false"

while getopts "p:b:m:h" opt
do
  case "$opt" in
    p ) pkg="$OPTARG" ;;
    b ) build="$OPTARG" ;;
    m ) mode="$OPTARG" ;;
    h ) help ;;
  esac
done

# ------------------------
# Build Configuration
# ------------------------
# Package name
if [ $pkg == "all" ]
then
  pkg_make_cmd=""
else
  pkg_make_cmd="--pkg $pkg"
fi

# CMake flags
if [ $build == "last" ]
then
  cmake_flags=()
elif [ $build == "debug" ]
then
  cmake_flags=(-DCMAKE_CXX_FLAGS="-Wall -O0 -g")
elif [ $build == "release" ]
then
  cmake_flags=(-DCMAKE_CXX_FLAGS="-Wall -fno-associative-math -march=native -O3")
else
  echo ""
  echo "$0: Illegal build setting (-b) '$build'"
  echo ""
  exit
fi

# Build
source /opt/ros/noetic/setup.bash
source ~/sw/ros/master/devel/setup.bash
roscd && cd ..
catkin_make $pkg_make_cmd -j4 "${cmake_flags[@]}"

# ------------------------
# Run
# ------------------------
if [ $mode == "real" ]
then
  roslaunch $pkg $pkg.launch mode_real:=true
elif [ $mode == "sim" ]
then
  roslaunch $pkg $pkg.launch mode_real:=false
elif [ $mode != "build" ]
then
  echo ""
  echo "$0: Illegal mode option (-m) '$mode'"
  help
  exit
fi
