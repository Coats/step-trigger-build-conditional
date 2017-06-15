#!/bin/bash

set -e

WBTC_MESSAGE=$(git log -1 --pretty=%s)
echo "Commit message: $WBTC_MESSAGE"

WBTC_TRIGGER=false

if [ -n "$WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_FOLDER" ] && [ $(git show $WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_FOLDER | wc -c) -ne 0 ]; then
  echo "Changed detected on folder $WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_FOLDER."
  WBTC_TRIGGER=true
fi

if [ -n "$WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_MESSAGE" ] && [[ "$WBTC_MESSAGE" = *$WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_MESSAGE* ]]; then
  echo "Keywords detected $WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_MESSAGE in commit message."
  WBTC_TRIGGER=true
fi

if [ "WBTC_TRIGGER" = "true" ]; then
  WTB_ENDPOINT="https://app.wercker.com/api/v3/runs/"


  WTB_JSON="{\"applicationId\": \"$WERCKER_TRIGGER_BUILD_APPLICATION_ID\", \
  \"pipelineId\": \"$WERCKER_TRIGGER_BUILD_PIPELINE_ID\", \
  \"branch\": \"$WERCKER_GIT_BRANCH\", \
  \"sourceRunId\": \"$WERCKER_RUN_ID\", \
  \"message\": \"$(git log -1 --pretty=%s)\"}"
  echo "$WTB_JSON"
  echo "Calling $WTB_ENDPOINT"

  export WERCKER_TRIGGER_RESPONSE=$(curl -s -k -H "Content-type: application/json" -H "Authorization: Bearer $WERCKER_TRIGGER_BUILD_TOKEN" "$WTB_ENDPOINT" -d "$WTB_JSON" | grep \"error\")

  if [ ! -z "$WERCKER_TRIGGER_RESPONSE" ]; then
    echo "$WERCKER_TRIGGER_RESPONSE"
    exit 1
  fi
fi
