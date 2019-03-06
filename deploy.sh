#!/bin/bash
# deploy.sh
# deploy for superlists by parameter 'staging' or 'living'
# usage: deploy.sh staging|living
# update: 2019-03-03 by tang-jianwei

REPO_URL="https://github.com/aaluo001/superlists.git"

declare -r date_str=`date +%Y%m%d`
declare -r log_file="/root/deploy_tools/logs/deploy_${date_str}.log"


# Set sitename
case $1 in
    staging)
        declare -r sitename="www.tjw-superlists-staging.site"
        declare -r icpno="19005354"
        ;;
    living)
        declare -r sitename="www.superlists.site"
        declare -r icpno="99999999"
        ;;
    *)
        echo "usage:"
        echo "  deploy.sh staging|living"
        exit 1
        ;;
esac


# Start deploy
echo "===================="     >> ${log_file}
echo "deploy: ${sitename}"      >> ${log_file}
date                            >> ${log_file}
echo "===================="     >> ${log_file}


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
    cd ${source_dir} && git reset --hard  >> ${log_file}
    cd ${source_dir} && git pull          >> ${log_file}
else
    git clone ${REPO_URL} ${source_dir}   >> ${log_file}
fi


# Get secret key
declare -r secret_key_file="${keys_dir}/${sitename}"
if [ ! -e "${secret_key_file}" ]; then
    date +%s | sha256sum | cut -c -64 > ${secret_key_file}
    declare -r config_site="yes"
fi
declare -r secret_key=`cat ${secret_key_file}`


# Update settings
declare -r temp_dir="/root/deploy_tools/templates"
declare -r dest_settings="${source_dir}/superlists/settings.py"

cp -pf "${temp_dir}/settings.py" "${dest_settings}"
sed -i "s/{SITENAME}/${sitename}/g" "${dest_settings}"
sed -i "s/{SECRET_KEY}/${secret_key}/g" "${dest_settings}"


# Update base.html ICPNO
declare -r dest_base_html="${source_dir}/lists/templates/base.html"
sed -i "s/{ICPNO}/${icpno}/g" "${dest_base_html}"


# Update virtualenv
if [ ! -e "${virtualenv_dir}/bin/pip" ]; then
    python3.6 -m venv "${virtualenv_dir}"  >> ${log_file}
fi
"${virtualenv_dir}/bin/pip" \
    install -r "${source_dir}/requirements.txt"  \
    >> ${log_file}


# Update static files
cd ${source_dir} && \
    "${virtualenv_dir}/bin/python" manage.py collectstatic --noinput \
    >> ${log_file}


# Update database
cd ${source_dir} && \
    "${virtualenv_dir}/bin/python" manage.py migrate --noinput \
    >> ${log_file}


# Config nginx and gunicorn-systemd
if [ -n "${config_site}" ]; then

    # Config nginx
    declare -r dest_nginx_conf="/etc/nginx/sites-available/${sitename}"
    declare -r dest_nginx_ln="/etc/nginx/sites-enabled/${sitename}"

    cp -pf "${temp_dir}/nginx.conf" "${dest_nginx_conf}"
    sed -i "s/{SITENAME}/${sitename}/g" "${dest_nginx_conf}"
    if [ ! -L "${dest_nginx_ln}" ]; then
        ln -s "${dest_nginx_conf}" "${dest_nginx_ln}"
    fi


    # Config gunicorn-systemd
    declare -r dest_gunicorn_systemd="/etc/systemd/system/${sitename}.service"

    cp -pf "${temp_dir}/gunicorn_systemd.service" "${dest_gunicorn_systemd}"
    sed -i "s/{SITENAME}/${sitename}/g" "${dest_gunicorn_systemd}"


    # Reload nginx and start gunicorn service
    systemctl daemon-reload
    systemctl reload nginx
    systemctl enable ${sitename}
    systemctl start  ${sitename}

else

    # Restart gunicorn service
    systemctl restart ${sitename}

fi

# End deploy
echo "===================="  >> ${log_file}
echo ""                      >> ${log_file}
echo ""                      >> ${log_file}
echo ""                      >> ${log_file}
exit 0

