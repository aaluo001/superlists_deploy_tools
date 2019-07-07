配置新网站
====================

## 需要安装的包
* Nginx
* Python3.6
* Virtualenv + pip
* Git

Ubuntu 16.04("Xenial/LTS")
    add-apt-repository ppa:fkrull/deadsnakes
    apt-get install nginx git python3.6 python3.6-venv


## 配置Nginx
* 参考template_nginx.conf
* 把{SITENAME}替换成所需的域名，如staging.my-domain.com
    cp -p ./template_nginx.conf > /etc/nginx/sites-available/staging.my-domain.com
    # sed -i 是直接在文件中替换，不在终端输出
    sed -i "s/{SITENAME}/staging.my-domain.com/g" /etc/nginx/sites-available/staging.my-domain.com
    ln -s /etc/nginx/sites-available/staging.my-domain.com /etc/nginx/sites-enabled/staging.my-domain.com
    rm /etc/nginx/sites-enabled/default


## Systemd服务
* 参考template_gunicorn-systemd.service
* 把{SITENAME}替换成所需的域名，如staging.my-domain.com
    cp -p ./template_gunicorn-systemd.service > /etc/systemd/system/staging.my-domain.com.service
    sed -i "s/{SITENAME}/staging.my-domain.com/g" /etc/systemd/system/staging.my-domain.com.service


## 为新发布打上Git标签
git tag -f LIVE
export TAG=`date +DEPLOY-%F/%H%M`
git tag $TAG
git push -f origin LIVE $TAG


## 目录结构
/root
    /deploy_tools
        deploy.sh
    /keys
        www.tjw-superlists-staging.site   # secret_key
        www.superlists.site    # secret_key
    /shells
        init_common.sh
        init_staging.sh
        init_living.sh
    /sites
        /{SITENAME}
            /database
            /source
            /static
            /virtualenv
            /log

