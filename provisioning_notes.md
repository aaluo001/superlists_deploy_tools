====================
## 搭建网站
## 2019-12-14 新建文档
====================

## 安装Ubuntu桌面版
    ubuntu-18.04.3-desktop-amd64.iso
    选择China和汉语，这样系统升级会更快些。
## 系统安装完成后，先进行系统升级
    sudo apt update
    sudo apt upgrade
    sudo apt autoclean
    sudo apt autoremove
## 启动root用户
    sudo passwd root


## 安装Nginx
    sudo apt install nginx
    sudo systemctl start nginx
    sudo systemctl status nginx
* 打开浏览器，输入地址localhost，可以看到：
    Welcome to nginx!
## 安装Python3.6
    sudo apt install python3.6
    sudo apt-get install python3.6-venv
    which python3
    python3 --version
## 安装Git
    sudo apt install git
    git --version
## 安装Postgresql
    sudo apt install postgresql
    psql --version


## 配置Postgresql
* 先切换到root用户，再切换到postgres用户
    su root
    su postgres
* 进入数据库
    psql
* 创建测试用户dev001
    CREATE ROLE dev001 LOGIN PASSWORD 'dev001#' CREATEDB;
    <!-- CREATE ROLE root LOGIN PASSWORD 'root1755#' CREATEDB; -->
* 创建和用户名同名的数据库
    CREATE DATABASE dev001 WITH OWNER = dev001;
* 查看配置文件路径
    select name, setting from pg_settings where category = 'File Locations';

        name        |                 setting
    -------------------+------------------------------------------
    config_file       | /etc/postgresql/10/main/postgresql.conf
    data_directory    | /var/lib/postgresql/10/main
    external_pid_file | /var/run/postgresql/10-main.pid
    hba_file          | /etc/postgresql/10/main/pg_hba.conf
    ident_file        | /etc/postgresql/10/main/pg_ident.conf
    (5 rows)

* 修改pg_hba.conf
    cd /etc/postgresql/10/main
    cp -p pg_hba.conf pg_hba.conf.bak
    vim pg_hba.conf

    修改前：
    #--------------------------------------------------------------------------------
    # "local" is for Unix domain socket connections only
    local   all             all                                     peer
    #--------------------------------------------------------------------------------

    修改后：
    #--------------------------------------------------------------------------------
    # "local" is for Unix domain socket connections only
    <!-- local   dev001          root                                    peer -->
    local   all             all                                     md5    
    #--------------------------------------------------------------------------------

* 重启postgresql
    service postgresql restart

<!-- * 注意：
    为了让root用户可以访问数据库dev001而不需要密码，将其设置为peer。
    由于数据库dev001属于用dev001所有，那么需要dev001的用户赋予root用户操作表的权限。
    那么，首先在Linux系统中必须添加dev001用户。(如果有该用户，就不需要了)
    useradd -m dev001
    passwd dev001
    使用dev001用户登录，执行psql就能直接进入数据库。
    赋予root用户操作所有表的权限：
    dev001=> GRANT ALL ON ALL TABLES IN SCHEMA public TO root; -->



## 目录结构
${HOME}
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

## 配置shells
    ${HOME}/shells/init_common.sh
        # init_common.sh
        declare -r email_password="***"
    ${HOME}/shells/init_living.sh
    ${HOME}/shells/init_staging.sh
        # init_staging.sh
        declare -r db_name="dev001"
        declare -r db_user="dev001"
        declare -r db_password="dev001#"

## 克隆deploy_tools
    su - root
    cd ~
    git clone https://github.com/aaluo001/superlists_deploy_tools.git ./deploy_tools

## 配布staging
    su - root
    cd deploy_tools
    ./deploy.sh staging -g -c

## 为新发布打上Git标签
git tag -f LIVE
export TAG=`date +DEPLOY-%F/%H%M`
git tag $TAG
git push -f origin LIVE $TAG

<!-- 
## 配置Nginx
* 参考template_nginx.conf
* 把{SITENAME}替换成所需的域名，如staging.my-domain.com
    cp -p ./template_nginx.conf > /etc/nginx/sites-available/staging.my-domain.com
    # sed -i 是直接在文件中替换，不在终端输出
    sed -i "s/{SITENAME}/staging.my-domain.com/g" /etc/nginx/sites-available/staging.my-domain.com
    ln -s /etc/nginx/sites-available/staging.my-domain.com /etc/nginx/sites-enabled/staging.my-domain.com
    rm /etc/nginx/sites-enabled/default

## 配置Systemd服务
* 参考template_gunicorn-systemd.service
* 把{SITENAME}替换成所需的域名，如staging.my-domain.com
    cp -p ./template_gunicorn-systemd.service > /etc/systemd/system/staging.my-domain.com.service
    sed -i "s/{SITENAME}/staging.my-domain.com/g" /etc/systemd/system/staging.my-domain.com.service
-->
