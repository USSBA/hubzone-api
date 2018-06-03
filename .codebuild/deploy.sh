#!/bin/bash

ECS_SERVICE_SUFFIX=hubzone-api
ECR_REPO=hubzone/hubzone-api
ECR_ENDPOINT_UPPER=222484291001.dkr.ecr.us-east-1.amazonaws.com
ECR_ENDPOINT_LOWER=997577316207.dkr.ecr.us-east-1.amazonaws.com

usage () { echo "How to use: deploy.sh -e <environment> -t <image-tag>
   -e <env>: The environment of the parameter; ie: dev, demo, qa, trn, stg, prod
   -t <tag>: The image tag to be deployed to the given environment
   -h: Show this message
"; }

options=':e:ht:'
while getopts $options option
do
    case $option in
        e  ) ENV=$OPTARG;;
        t  ) TAG=$OPTARG;;
        h  ) usage; exit;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;; 
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;; 
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;; 
    esac
done

case "${ENV}" in
  dev|demo|qa)
    ECR_ENDPOINT=${ECR_ENDPOINT_LOWER}
    ;;
  trn|stg|prod)
    ECR_ENDPOINT=${ECR_ENDPOINT_UPPER}
    ;;
  *)
    echo "FATAL: Must set environment to one of: dev|demo|qa|trn|stg|prod"; usage; exit 1
    ;;
esac

if [ -z "${TAG}" ]; then
    echo "FATAL: Must set tag"; usage; exit 1
fi

ecs-deploy -r us-east-1 \
           -c "${ENV}-ecs" \
	         -n "${ENV}-${ECS_SERVICE_SUFFIX}" \
	         --timeout 1200 \
	         --enable-rollback \
	         -i "${ECR_ENDPOINT}/${ECR_REPO}:${TAG}" \
           --max-definitions 5
