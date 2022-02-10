#!/bin/bash

# deploys an API config and API GW on GCP

# print all the command line arguments, helps with debugging
echo $@

# helper function to describe what command we are running, then running it
run_cmd() {
  echo going to run the following command \"$@\"
  ${@}
}

# all arguments are positional, 1: project id, 2: api id, 3: openapi spec filename
# 4: region, 5: service account email address, 6: delete if present

# if number of arguments is not sufficient then exit
if [ "$#" -ne 6 ]; then
  echo "number of argument is $#, not sufficient"
  exit 1
fi

PROJECT_ID=$1
API_ID=$2
CONFIG_ID=${PROJECT_ID}-${API_ID}-config
GATEWAY_ID=${CONFIG_ID}-gw
OPENAPI_SPEC=$3
REGION=$4
SERVICE_ACCOUNT_EMAIL=$5
DELETE_IF_PRESENT=$6

# first check if the api config is already there, if yes then if the delete param is specified
# delete the api gw and the api config, if it is there and the delete param is not specified then exit
cmd="gcloud api-gateway api-configs describe $CONFIG_ID --api=$API_ID --project=$PROJECT_ID"
run_cmd ${cmd}
if [ $? -eq 0 ] # $? means the result of the last executed command (0 - success/value OR 1 - failure/null)
then
  if [ $DELETE_IF_PRESENT -eq 1 ]; then
    echo "$API_ID with $CONFIG_ID already exists in $PROJECT_ID"
    # need to first delete the api gw then the api config
    cmd="gcloud api-gateway gateways delete $GATEWAY_ID --location=$REGION --project=$PROJECT_ID --quiet" # --quiet means disable all interactive prompts
    run_cmd ${cmd}
  
    # delete the api config
    cmd="gcloud api-gateway api-configs delete $CONFIG_ID --api=$API_ID --project=$PROJECT_ID --quiet"
    run_cmd ${cmd}
  else
    echo "$API_ID with $CONFIG_ID already exists in $PROJECT_ID but DELETE_IF_PRESENT=$DELETE_IF_PRESENT, exiting"
    exit 1
  fi
fi  

# at this point, API GW either does not exist or has been deleted

# create config for API
cmd="gcloud api-gateway api-configs create $CONFIG_ID --api=$API_ID --project=$PROJECT_ID --openapi-spec=$OPENAPI_SPEC --backend-auth-service-account=$SERVICE_ACCOUNT_EMAIL"
run_cmd ${cmd}

# create gateway from config above for API
cmd="gcloud api-gateway gateways create $GATEWAY_ID --api=$API_ID --api-config=$CONFIG_ID --location=$REGION --project=$PROJECT_ID"
run_cmd ${cmd}

# get the service name
service_name=`gcloud api-gateway apis list --project=$PROJECT_ID --format yaml  | grep $API_ID | grep managedService | cut -d":" -f2`

# remove the " from the service name that are included in the yaml output
service_name=`echo "$service_name" | tr -d '"'`

# enable the service
cmd="gcloud services enable --project=$PROJECT_ID ${service_name}"
run_cmd ${cmd}

echo "DONE"
