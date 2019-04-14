��������վ
====================

## ��Ҫ��װ�İ�

* Nginx
* Python3.6
* Virtualenv + pip
* Git

Ubuntu 16.04("Xenial/LTS")
    add-apt-repository ppa:fkrull/deadsnakes
    apt-get install nginx git python3.6 python3.6-venv


## ����Nginx

* �ο�template_nginx.conf
* ��{SITENAME}�滻���������������staging.my-domain.com
    cp -p ./template_nginx.conf > /etc/nginx/sites-available/staging.my-domain.com
    # sed -i ��ֱ�����ļ����滻�������ն����
    sed -i "s/{SITENAME}/staging.my-domain.com/g" /etc/nginx/sites-available/staging.my-domain.com
    ln -s /etc/nginx/sites-available/staging.my-domain.com /etc/nginx/sites-enabled/staging.my-domain.com
    rm /etc/nginx/sites-enabled/default


## Systemd����
* �ο�template_gunicorn-systemd.service
* ��{SITENAME}�滻���������������staging.my-domain.com
    cp -p ./template_gunicorn-systemd.service > /etc/systemd/system/staging.my-domain.com.service
    sed -i "s/{SITENAME}/staging.my-domain.com/g" /etc/systemd/system/staging.my-domain.com.service


## Ŀ¼�ṹ
/root
    /keys
        staging.my-domain.com   # secret_key
        living.my-domain.com    # secret_key
        email_password          # send email's password
    /sites
        /{SITENAME}
            /database
            /source
            /static
            /virtualenv
            /log

