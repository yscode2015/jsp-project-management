#!/bin/bash
readonly ROOT=$(cd $(dirname ${BASH_SOURCE:-${0}}); pwd)
readonly MODE=${1:-build}

build() {
  source ${ROOT}/config.sh

#  bash ${ROOT}/01-vpc/manage.sh build
#
#  if [ ${?} -ne 0 ]; then
#    exit 1
#  fi

  DOMAIN_PREFIX_=${DOMAIN_PREFIX} \
    bash ${ROOT}/02-alb/manage.sh build

  if [ ${?} -ne 0 ]; then
    exit 1
  fi

  EC2_INSTANCE_ID_=${EC2_INSTANCE_ID} \
    bash ${ROOT}/03-cognito/manage.sh build

  if [ ${?} -ne 0 ]; then
    exit 1
  fi
}

delete() {
  bash ${ROOT}/03-cognito/manage.sh delete

  if [ ${?} -ne 0 ]; then
    exit 1
  fi
  bash ${ROOT}/02-alb/manage.sh delete

  if [ ${?} -ne 0 ]; then
    exit 1
  fi

#  bash ${ROOT}/01-vpc/manage.sh delete
#
#  if [ ${?} -ne 0 ]; then
#    exit 1
#  fi
}

if [ ${MODE} = build ]; then
  build
elif [ ${MODE} = delete ]; then
  delete
fi
