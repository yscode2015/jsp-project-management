#!/bin/bash
readonly ROOT=$(cd $(dirname ${BASH_SOURCE:-${0}}); pwd)
readonly MODE=${1:-build}

build() {
  bash ${ROOT}/01-vpc/manage.sh build
}

delete() {
  bash ${ROOT}/01-vpc/manage.sh delete
}

if [ ${MODE} = build ]; then
  build
elif [ ${MODE} = delete ]; then
  delete
fi
