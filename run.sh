#!/bin/bash

set -e

WBTC_MESSAGE=$(git log -1 --pretty=%s)

WBTC_TRIGGER=false

if [ -n "$WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_PATH" ] && [ $(git show $WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_PATH | wc -c) -ne 0 ]; then
  echo "Changed detected on path $WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_PATH."
  WBTC_TRIGGER=true
fi

if [ -n "$WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_MESSAGE" ] && [[ "$WBTC_MESSAGE" = *$WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_MESSAGE* ]]; then
  echo "Keywords detected $WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_MESSAGE in commit message."
  WBTC_TRIGGER=true
fi

if [ "$WBTC_TRIGGER" = "true" ]; then
  WBTC_ENDPOINT="https://app.wercker.com/api/v3/runs/"


  WBTC_JSON="{\"applicationId\": \"$WERCKER_TRIGGER_BUILD_CONDITIONAL_APPLICATION_ID\", \
  \"pipelineId\": \"$WERCKER_TRIGGER_BUILD_CONDITIONAL_PIPELINE_ID\", \
  \"branch\": \"$WERCKER_GIT_BRANCH\", \
  \"sourceRunId\": \"$WERCKER_RUN_ID\", \
  \"message\": \"$WBTC_MESSAGE\"}"
  echo "$WBTC_JSON"
  echo "Calling $WBTC_ENDPOINT"

  export WBTC_TRIGGER_RESPONSE=$(curl -s -k -H "Content-type: application/json" -H "Authorization: Bearer $WERCKER_TRIGGER_BUILD_CONDITIONAL_TOKEN" "$WTBC_ENDPOINT" -d "$WTBC_JSON" | grep \"error\")

  if [ ! -z "$WBTC_TRIGGER_RESPONSE" ]; then
    faild "$WBTC_TRIGGER_RESPONSE"
  fi
fi
