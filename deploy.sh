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


# Set sitename
declare -r deploy_param=$1
if [ "${deploy_param}" == "${STAGING_PARAM}" ]; then
    declare -r sitename=${STAGING_SITENAME}
fi
if [ "${deploy_param}" == "${LIVING_PARAM}" ]; then
    declare -r sitename=${LIVING_SITENAME}
fi

if [ ! -n "${sitename}" ]; then
    echo "usage:"
    echo "  deploy.sh staging|living"
    exit 1
fi
echo "sitename: ${sitename}"


# Create directory structure
declare -r site_dir="/root/sites/${sitename}"

declare -r database_dir="${site_dir}/database"
declare -r source_dir="${site_dir}/source"
declare -r static_dir="${site_dir}/static"
declare -r virtualenv_dir="${site_dir}/virtualenv"

mkdir -p "${database_dir}"
mkdir -p "${source_dir}"
mkdir -p "${static_dir}"
mkdir -p "${virtualenv_dir}"


# Get latest source
if [ -e "${source_dir}/.git" ]; then
    cd ${source_dir} && git fetch
    cd ${source_dir} && git reset --hard
else
    git clone ${REPO_URL} ${source_dir}
fi


# Update settings
declare -r temp_dir="/root/deploy_tools/template"
declare -r dest_settings="${source_dir}/superlists/settings.py"

cp -pf "${temp_dir}/settings.py" "${dest_settings}"
sed -i "s/{SITENAME}/${sitename}/g" "${dest_settings}"
# Update secret_key



exit 0

