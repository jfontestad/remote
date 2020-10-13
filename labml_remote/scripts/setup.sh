#!/bin/bash

# Configurations
readonly NAME="%%NAME%%"
readonly PYTHON_VERSION='%%PYTHON_VERSION%%'
readonly HOME='%%HOME%%'

readonly CONDA_DOWNLOAD="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
readonly PROJECT_PATH="${HOME}/${NAME}"
readonly CONDA_PATH="${HOME}/miniconda"
readonly CONDA_ENV="${NAME}_env"

# Text colors
# 31 red 32 green 33 yellow 34 blue

check_conda() {
  printf "Checking conda..."
  if test -d "${CONDA_PATH}"; then
    printf " \x1B[0;32m[FOUND]\x1B[0m\n"
    return 0
  else
    printf " \x1B[0;33m[NOT FOUND]\x1B[0m\n"
    return 1
  fi
}

install_conda() {
  check_conda
  if [ "$?" == 0 ]; then
    return 0
  fi

  printf "Downloading conda..."
  wget --progress=bar:force "${CONDA_DOWNLOAD}" -O "${HOME}/miniconda.sh"
  if [ "$?" != 0 ]; then
    printf " \x1B[0;31m[DOWNLOAD FAILED]\x1B[0m\n"
    return 1
  else
    printf " \x1B[0;32m[DOWNLOADED]\x1B[0m\n"
  fi
  printf "Installing conda..."
  bash "${HOME}/miniconda.sh" -b -p "${CONDA_PATH}"
  if [ "$?" != 0 ]; then
    printf " \x1B[0;31m[INSTALL FAILED]\x1B[0m\n"
    rm "${HOME}/miniconda.sh"
    rm -rf "${CONDA_PATH}"
    return 1
  else
    printf " \x1B[0;32m[INSTALLED]\x1B[0m\n"
  fi

  rm "${HOME}/miniconda.sh"
}

check_environment() {
  printf "Checking environment..."
  conda activate "${CONDA_ENV}"
  if [ $? == 0 ]; then
    printf " \x1B[0;32m[FOUND]\x1B[0m\n"
    return 0
  else
    printf " \x1B[0;33m[NOT FOUND]\x1B[0m\n"
    return 1
  fi
}

create_environment() {
  source "${CONDA_PATH}/etc/profile.d/conda.sh"

  check_environment
  if [ "$?" == 0 ]; then
    return 0
  fi

  printf "Setting up conda environment..."
  conda create -y -n "${CONDA_ENV}" "python=${PYTHON_VERSION}"
  if [ "$?" != 0 ]; then
    return 1
  fi

  conda activate "${CONDA_ENV}"
  if [ "$?" != 0 ]; then
    return 1
  fi
  pip install pipenv
  if [ "$?" != 0 ]; then
    return 1
  fi
  printf " \x1B[0;32m[DONE]\x1B[0m\n"

  return 0
}

install_conda
create_environment