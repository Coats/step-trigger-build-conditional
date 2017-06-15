# Trigger Build Conditional

A wercker step to trigger another build if git message contains specific keywords or git path has changes.

On error the response JSON is returned in WBTC_TRIGGER_RESPONSE env variable.

You will need to create a personal API access token for wercker

Environment variable WERCKER_APPLICATION_ID is provided by default.

Example:

    build:
      steps:
        - petrica/trigger-build:
            git-message: "build-keyword" # only build if commit contains message
            git-path: "src/" # only build on src path changes
            application-id: $WERCKER_APPLICATION_ID
            pipeline-id: $WERCKER_PIPELINE_ID
            token: $WERCKER_API_TOKEN
