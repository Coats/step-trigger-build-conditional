# Trigger Build Conditional

A wercker step to trigger another build if git message contains specific keywords or git path has changes.

You will need to create a personal API access token for wercker.

Environment variable WERCKER_APPLICATION_ID is provided by default by wercker.

Example:

    build:
      steps:
        - petrica/trigger-build:
            git-message: "build-keyword" # only build if commit contains message
            git-path: "src/" # only build on src path changes on the last commit
            application-id: $WERCKER_APPLICATION_ID
            pipeline-id: $WERCKER_PIPELINE_ID
            token: $WERCKER_API_TOKEN
