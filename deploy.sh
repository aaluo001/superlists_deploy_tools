#!/bin/bash
# deploy_tools.sh
# deploy tools for superlists by parameter 'staging' or 'living'
# usage: deploy_tools.sh staging|living
# update: 2019-03-03 by tang-jianwei

REPO_URL="https://github.com/aaluo001/superlists.git"

STAGING_PARAM="staging"
STAGING_SITENAME="tjw-superlists-staging.site"

LIVING_PARAM="living"
LIVING_SITENAME="superlists.site"


declare -r deploy_param=$1

if [ "${deploy_param}" == "${STAGING_PARAM}" ]
then
    declare -r deploy_sitename=${STAGING_SITENAME}
fi
if [ "${deploy_param}" == "${LIVING_PARAM}" ]
then
    declare -r deploy_sitename=${LIVING_SITENAME}
fi

echo "deploy_sitename: ${deploy_sitename}"

exit 0

