#!/bin/bash

# deploys an API config and API GW on GCP

'
# if number of arguments is not sufficient then exit
if [ "$#" -ne 7 ]; then
  echo "number of argument is $#, not sufficient"
  exit 1
fi


DEPLOYMENT=$1
CONFIG_ID=${DEPLOYMENT}
API_ID=$2-$CONFIG_ID
PROJECT_ID=$3
OPENAPI_SPEC=$4
GATEWAY_ID=$PROJECT_ID-${API_ID}
REGION=$5
SERVICE_ACCOUNT_EMAIL=$6
DELETE_IF_PRESENT=$7
'
CONFIG_ID=$1
API_ID=$2
PROJECT_ID=$3
OPENAPI_SPEC=$4
SERVICE_ACCOUNT_EMAIL=$5

# add config to existing gateway
cmd="gcloud api-gateway api-configs create $CONFIG_ID --api=$API_ID --project=$PROJECT_ID --openapi-spec=$OPENAPI_SPEC --backend-auth-service-account=$SERVICE_ACCOUNT_EMAIL"
$cmd
