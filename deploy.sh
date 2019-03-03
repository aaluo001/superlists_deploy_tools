#!/bin/bash
# deploy.sh
# deploy for superlists by parameter 'staging' or 'living'
# usage: deploy.sh staging|living
# update: 2019-03-03 by tang-jianwei

REPO_URL="https://github.com/aaluo001/superlists.git"

STAGING_PARAM="staging"
STAGING_SITENAME="tjw-superlists-staging.site"

LIVING_PARAM="living"
LIVING_SITENAME="superlists.site"


# Set deploy sitename
declare -r deploy_param=$1
if [ "${deploy_param}" == "${STAGING_PARAM}" ]; then
    declare -r deploy_sitename=${STAGING_SITENAME}
fi
if [ "${deploy_param}" == "${LIVING_PARAM}" ]; then
    declare -r deploy_sitename=${LIVING_SITENAME}
fi

if [ ! -n "${deploy_sitename}" ]; then
    echo "usage:"
    echo "  deploy.sh staging|living"
    exit 1
fi
echo "deploy_sitename: ${deploy_sitename}"


# Set site directory
declare -r site_dir="/root/sites/${deploy_sitename}"

# Make directory structure
mkdir -p "${site_dir}/database"
mkdir -p "${site_dir}/source"
mkdir -p "${site_dir}/static"
mkdir -p "${site_dir}/virtualenv"



exit 0

