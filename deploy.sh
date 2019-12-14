#!/bin/bash
# deploy.sh
# deploy for superlists by parameter 'staging' or 'living'
# usage: deploy.sh staging|living [-c] [-g]
# update:
#   2019-03-03 new file. by tang-jianwei
#   2019-03-15 can set parameter [-c] to config nginx.
#   2019-03-19 can set parameter [-g] to config gunicorn.
#   2019-04-13 config email_password.
#   2019-04-29 config db_name, db_user, db_password
#   2019-08-18 change python3.6 to python3


function display_usage_and_exit() {
    echo "usage:"
    echo "  deploy.sh staging|living [-c] [-g]"
    echo "    * staging: deploy staging server"
    echo "    *  living: deploy living server"
    echo "    *      -c: need to config nginx"
    echo "    *      -g: neet to config gunicorn-systemd"
    exit 1     
}

# Include email_password
. ${shells_dir}/init_common.sh

# Set sitename
# Include db_name, db_user and db_password
case $1 in
    staging)
        declare -r sitename="www.tjw-superlists-staging.site"
        . ${shells_dir}/init_staging.sh
        ;;
    living)
        declare -r sitename="www.superlists.site"
        . ${shells_dir}/init_living.sh
        ;;
    *)
        display_usage_and_exit
        ;;
esac

# Set config_nginx and config_gunicorn
shift
while [ -n "$1" ]
do
    case $1 in
        -c)
            declare -r config_nginx="yes"
            ;;
        -g)
            declare -r config_gunicorn="yes"
            ;;
        *)
            display_usage_and_exit
            ;;
    esac
    shift
done


# Declare columns
declare -r repo_url="https://github.com/aaluo001/superlists.git"
declare -r date_str=`date +%Y%m%d`
declare -r log_file="${HOME}/deploy_tools/logs/deploy_${date_str}.log"
declare -r shells_dir="${HOME}/shells"

declare -r keys_dir="${HOME}/keys"
declare -r site_dir="${HOME}/sites/${sitename}"

declare -r database_dir="${site_dir}/database"
declare -r source_dir="${site_dir}/source"
declare -r static_dir="${site_dir}/static"
declare -r virtualenv_dir="${site_dir}/virtualenv"
declare -r log_dir="${site_dir}/log"

# Create directory structure
mkdir -p "${keys_dir}"
mkdir -p "${database_dir}"
mkdir -p "${source_dir}"
mkdir -p "${static_dir}"
mkdir -p "${virtualenv_dir}"
mkdir -p "${log_dir}"


# Start deploy
echo "===================="     >> ${log_file}
echo "deploy: ${sitename}"      >> ${log_file}
date                            >> ${log_file}
echo "===================="     >> ${log_file}

# Get latest source
if [ -e "${source_dir}/.git" ]; then
    cd ${source_dir} && git reset --hard  >> ${log_file}
    cd ${source_dir} && git pull          >> ${log_file}
else
    git clone ${repo_url} ${source_dir}   >> ${log_file}
fi


# Get secret key
declare -r secret_key_file="${keys_dir}/${sitename}"
if [ ! -e "${secret_key_file}" ]; then
    date +%s | sha256sum | cut -c -64 > ${secret_key_file}
    declare -r config_site="yes"
fi
declare -r secret_key=`cat ${secret_key_file}`


# Update settings
declare -r temp_dir="${HOME}/deploy_tools/templates"
declare -r dest_settings="${source_dir}/superlists/settings.py"

cp -pf "${temp_dir}/settings.py" "${dest_settings}"

sed -i "s/{SITENAME}/${sitename}/g" "${dest_settings}"
sed -i "s/{SECRET_KEY}/${secret_key}/g" "${dest_settings}"
sed -i "s/{DB_NAME}/${db_name}/g" "${dest_settings}"
sed -i "s/{DB_USER}/${db_user}/g" "${dest_settings}"
sed -i "s/{DB_PASSWORD}/${db_password}/g" "${dest_settings}"
sed -i "s/{EMAIL_PASSWORD}/${email_password}/g" "${dest_settings}"


# Update virtualenv
if [ ! -e "${virtualenv_dir}/bin/pip" ]; then
    python3 -m venv "${virtualenv_dir}"  >> ${log_file}
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


# Config nginx
if [ -n "${config_site}" ] || [ -n "${config_nginx}" ]; then

    echo "configing nginx..."  >> ${log_file}
    declare -r dest_nginx_conf="/etc/nginx/sites-available/${sitename}"
    declare -r dest_nginx_ln="/etc/nginx/sites-enabled/${sitename}"

    cp -pf "${temp_dir}/nginx.conf" "${dest_nginx_conf}"
    sed -i "s/{SITENAME}/${sitename}/g" "${dest_nginx_conf}"
    if [ ! -L "${dest_nginx_ln}" ]; then
        ln -s "${dest_nginx_conf}" "${dest_nginx_ln}"
        rm -f /etc/nginx/sites-enabled/default
    fi

    # Reload nginx
    systemctl reload nginx

fi


# Config gunicorn-systemd
if [ -n "${config_site}" ] || [ -n "${config_gunicorn}" ]; then

    echo "configing gunicorn-systemd..."  >> ${log_file}
    declare -r dest_gunicorn_systemd="/etc/systemd/system/${sitename}.service"

    cp -pf "${temp_dir}/gunicorn_systemd.service" "${dest_gunicorn_systemd}"
    sed -i "s/{SITENAME}/${sitename}/g" "${dest_gunicorn_systemd}"

    # Reload new gunicorn-systemd file
    systemctl daemon-reload

fi

if [ -n "${config_site}" ]; then

    # Start gunicorn service
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

