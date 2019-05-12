====================
## 部署服务器
====================
47.97.118.237
root: ******

# 服务器部署，以及生产环境数据库用户
  superlists: ******

# 数据库管理员用户
  postgres: ******



# 创建测试用户dev001
  CREATE ROLE dev001 LOGIN PASSWORD 'dev001#' CREATEDB;
  
# 创建和用户名同名的数据库
  CREATE DATABASE dev001 WITH OWNER = dev001;


# 修改settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'dev001',
        'USER': 'dev001',
        'PASSWORD': 'dev001#',
    }
}

# 创建测试用table
  python manage.py migrate



postgres=# select name, setting from pg_settings where category = 'File Locations';
       name        |                 setting
-------------------+------------------------------------------
 config_file       | /etc/postgresql/9.5/main/postgresql.conf
 data_directory    | /var/lib/postgresql/9.5/main
 external_pid_file | /var/run/postgresql/9.5-main.pid
 hba_file          | /etc/postgresql/9.5/main/pg_hba.conf
 ident_file        | /etc/postgresql/9.5/main/pg_ident.conf
(5 rows)



cd /etc/postgresql/9.5/main
more pg_hba.conf

#--------------------------------------------------------------------------------
# DO NOT DISABLE!
# If you change this first entry you will need to make sure that the
# database superuser can access the database using some other method.
# Noninteractive access to all databases is required during automatic
# maintenance (custom daily cronjobs, replication, and similar tasks).
#
# Database administrative login by Unix domain socket
local   all             postgres                                peer

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
# Allow replication connections from localhost, by a user with the
# replication privilege.
#local   replication     postgres                                peer
#host    replication     postgres        127.0.0.1/32            md5
#host    replication     postgres        ::1/128                 md5
#--------------------------------------------------------------------------------


cp -p pg_hba.conf ./pg_hba.conf.20190424bak

vi pg_hba.conf

修改前：
#--------------------------------------------------------------------------------
# "local" is for Unix domain socket connections only
local   all             all                                     peer
#--------------------------------------------------------------------------------

修改后：
#--------------------------------------------------------------------------------
# "local" is for Unix domain socket connections only
local   all             all                                     md5    
#--------------------------------------------------------------------------------


service postgresql restart

