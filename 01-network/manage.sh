#!/bin/bash
readonly ROOT=$(cd $(dirname ${BASH_SOURCE:-${0}}); pwd)
readonly MODE=${1:-build}
readonly STACK_NAME=jsp-project-management-network

build() {
  echo "⏳ ${STACK_NAME} を作成します"

  aws cloudformation deploy \
    --template-file ${ROOT}/template.yaml \
    --stack-name ${STACK_NAME} \
    --capabilities CAPABILITY_NAMED_IAM

  if [ $? -ne 0 ]; then
    echo "❌ ${STACK_NAME} を作成できませんでした"
    exit 1
  fi

  echo "✅ ${STACK_NAME} を作成しました"
}

delete() {
  echo "⏳ ${STACK_NAME} を削除します"

  source ${ROOT}/../tools.sh

  delete_stack ${STACK_NAME}

  if [ $? -ne 0 ]; then
    echo "❌ ${STACK_NAME} を削除できませんでした"
    exit 1
  fi

  echo "✅ ${STACK_NAME} を削除しました"
}
