#!/usr/bin/env bash
# Copyright (c) 2018-2020 NVIDIA Corporation

###################################
# Thrust build-only script for CI #
###################################

set -e

# Logger function for build status output
function logger() {
  echo -e "\n>>>> ${@}\n"
}

# Set path and build parallel level
export PATH=/usr/local/cuda/bin:${PATH}

# Set home to the job's workspace.
export HOME=${WORKSPACE}

# Switch to project root; also root of repo checkout.
cd ${WORKSPACE}

# If it's a nightly build, append current YYMMDD to version.
if [[ "${BUILD_MODE}" = "branch" ]] ; then
  export VERSION_SUFFIX=`date +%y%m%d`
fi

# If `CXX` isn't set, assume it's `c++`.
if [[ -z "${CXX}" ]] ; then
  CXX="c++"
fi

# If `CUDACXX` isn't set, assume it's `nvcc`.
if [[ -z "${CUDACXX}" ]] ; then
  CUDACXX="nvcc"
fi

CMAKE_FLAGS="-DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_CUDA_COMPILER=${CUDACXX}"

# If it's a nightly build, build all configurations.
if [[ "${BUILD_MODE}" = "branch" ]] ; then
  CMAKE_FLAGS="${CMAKE_FLAGS} -DTHRUST_MULTICONFIG_WORKLOAD=FULL"
fi

################################################################################
# SETUP - Check environment.
################################################################################

logger "Get env..."
env

logger "Check versions..."
echo "$${CXX}=${CXX}"
echo "$${CUDACXX}=${CUDACXX}"
${CXX} --version
${CUDACXX} --version

################################################################################
# BUILD - Build Thrust examples and tests.
################################################################################

mkdir build
cd build

logger "Configure Thrust..."
cmake ${CMAKE_OPTIONS} ..

logger "Build Thrust..."
cmake --build . -j

