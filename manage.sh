#!/bin/bash
readonly ROOT=$(cd $(dirname ${BASH_SOURCE:-${0}}); pwd)
readonly MODE=${1:-build}

build() {
  source ${ROOT}/config.sh

  bash ${ROOT}/01-vpc/manage.sh build

  if [ ${?} -ne 0 ]; then
    exit 1
  fi

  AMI_ID_=${AMI_ID} \
    bash ${ROOT}/ec2/manage.sh build

  if [ ${?} -ne 0 ]; then
    exit 1
  fi
}

delete() {
  bash ${ROOT}/02-ec2/manage.sh delete

  if [ ${?} -ne 0 ]; then
    exit 1
  fi

  bash ${ROOT}/01-vpc/manage.sh delete

  if [ ${?} -ne 0 ]; then
    exit 1
  fi
}

if [ ${MODE} = build ]; then
  build
elif [ ${MODE} = delete ]; then
  delete
fi
