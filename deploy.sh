#!/bin/bash
# deploy.sh
# deploy for superlists by parameter 'staging' or 'living'
# usage: deploy.sh staging|living
# update: 2019-03-03 by tang-jianwei

REPO_URL="https://github.com/aaluo001/superlists.git"


# Set sitename
case $1 in
    staging)
        declare -r sitename="tjw-superlists-staging.site"
        ;;
    living)
        declare -r sitename="superlists.site"
        ;;
    *)
        echo "usage:"
        echo "  deploy.sh staging|living"
        exit 1
        ;;
esac
echo "sitename: ${sitename}"


# Create directory structure
declare -r keys_dir="/root/keys"
declare -r site_dir="/root/sites/${sitename}"

declare -r database_dir="${site_dir}/database"
declare -r source_dir="${site_dir}/source"
declare -r static_dir="${site_dir}/static"
declare -r virtualenv_dir="${site_dir}/virtualenv"

mkdir -p "${keys_dir}"
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


# Create secret key file
declare -r secret_key_file="${keys_dir}/${sitename}"
if [ ! -e "${secret_key_file}" ]; then
    date +%s | sha256sum | cut -c -64 > ${secret_key_file}
fi
declare -r secret_key=`cat ${secret_key_file}`


# Update settings
declare -r temp_dir="/root/deploy_tools/templates"
declare -r dest_settings="${source_dir}/superlists/settings.py"

cp -pf "${temp_dir}/settings.py" "${dest_settings}"
sed -i "s/{SITENAME}/${sitename}/g" "${dest_settings}"
sed -i "s/{SECRET_KEY}/${secret_key}/g" "${dest_settings}"



exit 0

