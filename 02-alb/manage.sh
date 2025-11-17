#!/bin/bash
readonly ROOT=$(cd $(dirname ${BASH_SOURCE:-${0}}); pwd)
readonly MODE=${1:-build}
readonly STACK_NAME=jsp-project-management-alb

build() {
  if [ -z "${EC2_INSTANCE_ID_}" ]; then
    echo "❌ 環境変数 EC2_INSTANCE_ID_ を定義してください"
    exit 1
  fi

  echo "⏳ ${EC2_INSTANCE_ID_} の VPC IDを取得します"

  local readonly vpc_id=`aws ec2 describe-instances --instance-ids ${EC2_INSTANCE_ID_} --query 'Reservations[0].Instances[0].VpcId' --output text`

  if [ ${?} -ne 0 ]; then
    echo "❌ VPC IDの取得に失敗しました"
    exit 1
  fi

  echo "✅ VPC IDは ${vpc_id} です"

  echo "⏳ Subnet ID1を取得します"

  local readonly subnet_id1=`aws ec2 describe-subnets --filters "Name=vpc-id,Values=${vpc_id}" --query "Subnets[0].SubnetId" --output text`

  if [ ${?} -ne 0 ]; then
    echo "❌ Subnet ID1の取得に失敗しました"
    exit 1
  fi

  echo "✅ Subnet ID1は ${subnet_id1} です"

  echo "⏳ Subnet ID2を取得します"

  local readonly subnet_id2=`aws ec2 describe-subnets --filters "Name=vpc-id,Values=${vpc_id}" --query "Subnets[1].SubnetId" --output text`

  if [ ${?} -ne 0 ]; then
    echo "❌ Subnet ID2の取得に失敗しました"
    exit 1
  fi

  echo "✅ Subnet ID2は ${subnet_id2} です"

  echo "⏳ ${STACK_NAME} を作成します"

  aws cloudformation deploy \
    --template-file ${ROOT}/template.yaml \
    --stack-name ${STACK_NAME} \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides EC2InstanceId=${EC2_INSTANCE_ID_} \
      VpcId=${vpc_id} \
      PublicSubnet1=${subnet_id1} \
      PublicSubnet2=${subnet_id2} \

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

if [ ${MODE} = build ]; then
  build
elif [ ${MODE} = delete ]; then
  delete
fi
