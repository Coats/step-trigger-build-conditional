#!/bin/bash

WBTC_MESSAGE=$(git log -1 --pretty=%s)

WBTC_TRIGGER=false

if [ -n "$WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_PATH" ] && [ "$(git show "$WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_PATH" | wc -c)" -ne 0 ]; then
  info "Changed detected on path $WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_PATH."
  WBTC_TRIGGER=true
fi

if [ -n "$WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_PATH" ] && [ "$(git show -m  | grep -c "$WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_PATH")" -ne 0 ]; then
  info "Changed detected on path with grep $WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_PATH."
  WBTC_TRIGGER=true
fi

if [ -n "$WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_MESSAGE" ] && [[ "$WBTC_MESSAGE" = *$WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_MESSAGE* ]]; then
  info "Keywords detected $WERCKER_TRIGGER_BUILD_CONDITIONAL_GIT_MESSAGE in commit message."
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
  info "Calling $WBTC_ENDPOINT"

  if ! curl --fail -k --write-out "\n\nStatus code: %{http_code}\n" -H "Content-type: application/json" -H "Authorization: Bearer $WERCKER_TRIGGER_BUILD_CONDITIONAL_TOKEN" "$WBTC_ENDPOINT" -d "$WBTC_JSON"; then
    fail "$WBTC_TRIGGER_RESPONSE"
  fi

  success "\nBuild triggered successfully."
fi