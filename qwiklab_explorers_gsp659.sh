#!/bin/bash
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

echo
clear


gcloud auth list


export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")


git clone https://github.com/googlecodelabs/monolith-to-microservices.git


cd ~/monolith-to-microservices


./setup.sh


cd ~/monolith-to-microservices/monolith


echo "${YELLOW_TEXT}${BOLD_TEXT}   This will be located in region: ${WHITE_TEXT}${REGION}${RESET_FORMAT}"
gcloud artifacts repositories create monolith-demo --location=$REGION --repository-format=docker --description="Subscribe to techcps" 


gcloud auth configure-docker $REGION-docker.pkg.dev


gcloud services enable artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    run.googleapis.com

echo "${MAGENTA_TEXT}${BOLD_TEXT}   Image will be tagged as: ${WHITE_TEXT}$REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0${RESET_FORMAT}"
gcloud builds submit --tag $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0

echo
echo "${CYAN_TEXT}${BOLD_TEXT} Deploying the monolith application (version 1.0.0) to Cloud Run...${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}   Service name: monolith, Region: ${WHITE_TEXT}${REGION}${CYAN_TEXT}, Allow unauthenticated access.${RESET_FORMAT}"
gcloud run deploy monolith --image $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0 --allow-unauthenticated --region $REGION

echo
echo "${YELLOW_TEXT}${BOLD_TEXT} Updating the Cloud Run service 'monolith' to set concurrency to 1...${RESET_FORMAT}"
gcloud run deploy monolith --image $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0 --allow-unauthenticated --region $REGION --concurrency 1


gcloud run deploy monolith --image $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:1.0.0 --allow-unauthenticated --region $REGION --concurrency 80


cd ~/monolith-to-microservices/react-app/src/pages/Home


mv index.js.new index.js


cat ~/monolith-to-microservices/react-app/src/pages/Home/index.js


cd ~/monolith-to-microservices/react-app


npm run build:monolith


cd ~/monolith-to-microservices/monolith


echo "${MAGENTA_TEXT}${BOLD_TEXT}   Image will be tagged as: ${WHITE_TEXT}$REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:2.0.0${RESET_FORMAT}"
gcloud builds submit --tag $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:2.0.0


echo "${CYAN_TEXT}${BOLD_TEXT}   Service name: monolith, Region: ${WHITE_TEXT}${REGION}${CYAN_TEXT}, Allow unauthenticated access.${RESET_FORMAT}"
gcloud run deploy monolith --image $REGION-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/monolith-demo/monolith:2.0.0 --allow-unauthenticated --region $REGION

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT} Subscribe to QwikLab Explorers ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@qwiklabexplorers${RESET_FORMAT}"
echo
