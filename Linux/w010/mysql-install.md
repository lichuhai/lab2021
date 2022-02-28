# MySQL系类数据库的安装和基本的使用方法笔记（MySQL，MariaDB）

# MySQL介绍

创始人Michael Widenius

## 历史

```sh
1996/xx MySQL 1.0
1996/10 MySQL 3.11.1
1999/xx MySQL AB公司，瑞典
2001/xx InnoDB开发
2003/xx MySQL 5.0，提供识图 存储过程等
2005/xx Oracle收购InnoDB
2008/01 Sun收购MySQL AB公司，10以美元
2008/11 MySQL 5.1
2009/04 Oracle收购Sun，74亿美元
2009/xx Monty成立MariaDB
2010/12 MySQL 5.5，InnoDB成MySQL默认存储引擎

```



## MySQL系列数据库



- MySQL
  - https://www.mysql.com/
  - 商业版
  - 社区版GPL（5.0，5.1，5.5，5.6，5.7）
- mariaDB
  - Foundation版本（10.2-10.8）
    - https://mariadb.org/
  - Corporation版
    - https://mariadb.com/
    - 社区版：MariaDB Community
    - 企业版：MariaDB Enterprise
    - 云版：SkySQL（DBaaS：DB as a Services）
- percona Server（这不是一个专门做MySQL的，还有其他的比如MariaDB，PostgreSQL等）
  - https://www.percona.com/
  - 只提供版本8的Linux下载
  - https://www.percona.com/downloads/Percona-Server-LATEST/



数据库对比

https://db-engines.com/en/system/MariaDB%3BMySQL%3BPercona+Server+for+MySQL



## MySQL特性



- 开源

- 插件式存储引擎，也称“表类型”，存储管理器有多个实现版本，功能和特性略有差别，5.5开始InnoDB是默认引擎

  ```
  MySQL  -- Other
  MyISAM -- Aria
  InnoDB -- XtraDB(MariaDB)
  ```

- 单进程，多线程

- 扩展，特性

- 多测试组件



# MySQL系列数据库的安装

## 安装方法和版本

安装方法

- 包管理器（yum，rpm等）
- 源码编译
- 二进制文件（免安装版）



各种版本

- OS版本
  - Win
  - MacOS
  - Linux
    - RHEL
      - 6
      - 7
      - 8
- 软件版本
  - MariaDB
    - 10.x
  - MySQL
    - 5.6
    - 8.x



## 包管理器（yum，rpm等）



相关URL

- MySQL
  - https://downloads.mysql.com/archives/community/
  - 其他镜像
- MariaDB
  - https://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb//mariadb-10.6.5/bintar-linux-systemd-x86_64/mariadb-10.6.5-linux-systemd-x86_64.tar.gz



```sh
# 默认yum源上的安装包
[root@C84MySQL8 ~]# yum info mysql-server
Name         : mysql-server
Version      : 8.0.26

[root@C84MySQL8 ~]# yum info mariadb-server
Name         : mariadb-server
Version      : 10.3.28

[root@C84MySQL8 ~]# yum info mariadb.x86_64
Name         : mariadb
Version      : 10.3.28

# CentOS7 不提供MySQL？
[root@c79maria10 ~]# yum info mysql-community-server
Error: No matching Packages to list

[root@c79maria10 ~]# yum info mysql
Error: No matching Packages to list

[root@c79maria10 ~]# yum info mariadb
Name        : mariadb
Version     : 5.5.68
Summary     : A community developed branch of MySQL

[root@c79maria10 ~]# yum info mariadb-server
Name        : mariadb-server
Version     : 5.5.68
Summary     : The MariaDB server and related files

```



```sh
# DVD安装光盘上的rpm包（需要完整版的DVD才有，迷你的没有数据库）
[root@C84MySQL8 ~]# ls /mnt/AppStream/Packages/ | grep mysql-server
mysql-server-8.0.21-1.module_el8.2.0+493+63b41e36.x86_64.rpm

[root@C84MySQL8 ~]# ls /mnt/AppStream/Packages/ | grep mariadb-server
mariadb-server-10.3.27-3.module_el8.3.0+599+c587b2e7.x86_64.rpm
mariadb-server-10.5.9-1.module_el8.4.0+801+647c4915.x86_64.rpm

```



### CentOS7安装MySQL 5.7（rpm）官方下载

URL

```
# https://downloads.mysql.com/archives/community/
# 选择RPM Bundle的打包所有相关包
# Red Hat Enterprise Linux 7 / Oracle Linux 7 (x86, 64-bit), RPM Bundle
# (mysql-5.7.35-1.el7.x86_64.rpm-bundle.tar)
# MD5: 99c03ce2fe9c57d3f76f59f7211be900
# 下载连接
# https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.35-1.el7.x86_64.rpm-bundle.tar
```

下载

```sh
[root@c79maria10 ~]# mkdir mysql57
[root@c79maria10 ~]# cd mysql57/
[root@c79maria10 ~]# wget https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.35-1.el7.x86_64.rpm-bundle.tar
--2021-12-23 21:02:40--  https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.35-1.el7.x86_64.rpm-bundle.tar
Resolving downloads.mysql.com (downloads.mysql.com)... 137.254.60.14
Connecting to downloads.mysql.com (downloads.mysql.com)|137.254.60.14|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.35-1.el7.x86_64.rpm-bundle.tar [following]
--2021-12-23 21:02:41--  https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.35-1.el7.x86_64.rpm-bundle.tar
Resolving cdn.mysql.com (cdn.mysql.com)... 104.93.8.235
Connecting to cdn.mysql.com (cdn.mysql.com)|104.93.8.235|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 545617920 (520M) [application/x-tar]
Saving to: ‘mysql-5.7.35-1.el7.x86_64.rpm-bundle.tar’

[root@c79maria10 mysql57]# tar -xf mysql-5.7.35-1.el7.x86_64.rpm-bundle.tar
[root@c79maria10 mysql57]# ls
mysql-5.7.35-1.el7.x86_64.rpm-bundle.tar
mysql-community-client-5.7.35-1.el7.x86_64.rpm
mysql-community-common-5.7.35-1.el7.x86_64.rpm
mysql-community-devel-5.7.35-1.el7.x86_64.rpm
mysql-community-embedded-5.7.35-1.el7.x86_64.rpm
mysql-community-embedded-compat-5.7.35-1.el7.x86_64.rpm
mysql-community-embedded-devel-5.7.35-1.el7.x86_64.rpm
mysql-community-libs-5.7.35-1.el7.x86_64.rpm
mysql-community-libs-compat-5.7.35-1.el7.x86_64.rpm
mysql-community-server-5.7.35-1.el7.x86_64.rpm
mysql-community-test-5.7.35-1.el7.x86_64.rpm

```



卸载冲突包，安装前提包

```sh
error: Failed dependencies:
        mariadb-libs is obsoleted by mysql-community-libs-5.7.35-1.el7.x86_64
        mariadb-libs is obsoleted by mysql-community-libs-compat-5.7.35-1.el7.x86_64

[root@c79maria10 mysql57]# rpm -evh mariadb-libs
error: Failed dependencies:
        libmysqlclient.so.18()(64bit) is needed by (installed) postfix-2:2.10.1-9.el7.x86_64
        libmysqlclient.so.18(libmysqlclient_18)(64bit) is needed by (installed) postfix-2:2.10.1-9.el7.x86_64

[root@c79maria10 mysql57]# rpm -evh postfix
Preparing...                          ################################# [100%]
Cleaning up / removing...
   1:postfix-2:2.10.1-9.el7           ################################# [100%]
[root@c79maria10 mysql57]# rpm -evh mariadb-libs
Preparing...                          ################################# [100%]
Cleaning up / removing...
   1:mariadb-libs-1:5.5.68-1.el7      ################################# [100%]

[root@c79maria10 mysql57]# yum -y install libaio perl-Data-Dumper perl-JSON net-tools

# 全部安装的话
[root@c79maria10 mysql57]# rpm -ivh ./*.rpm
warning: ./mysql-community-client-5.7.35-1.el7.x86_64.rpm: Header V3 DSA/SHA256 Signature, key ID 5072e1f5: NOKEY
Preparing...                          ################################# [100%]
Updating / installing...
   1:mysql-community-common-5.7.35-1.e################################# [ 10%]
   2:mysql-community-libs-5.7.35-1.el7################################# [ 20%]
   3:mysql-community-client-5.7.35-1.e################################# [ 30%]
   4:mysql-community-server-5.7.35-1.e################################# [ 40%]
   5:mysql-community-devel-5.7.35-1.el################################# [ 50%]
   6:mysql-community-embedded-5.7.35-1################################# [ 60%]
   7:mysql-community-embedded-devel-5.################################# [ 70%]
   8:mysql-community-test-5.7.35-1.el7################################# [ 80%]
   9:mysql-community-libs-compat-5.7.3################################# [ 90%]
  10:mysql-community-embedded-compat-5################################# [100%]

# 卸载
[root@c79maria10 mysql57]# rpm -evh $(rpm -qa | grep mysql)
Preparing...                          ################################# [100%]
Cleaning up / removing...
   1:mysql-community-embedded-devel-5.################################# [ 10%]
   2:mysql-community-devel-5.7.35-1.el################################# [ 20%]
   3:mysql-community-embedded-5.7.35-1################################# [ 30%]
   4:mysql-community-embedded-compat-5################################# [ 40%]
   5:mysql-community-test-5.7.35-1.el7################################# [ 50%]
   6:mysql-community-server-5.7.35-1.e################################# [ 60%]
   7:mysql-community-client-5.7.35-1.e################################# [ 70%]
   8:mysql-community-libs-compat-5.7.3################################# [ 80%]
   9:mysql-community-libs-5.7.35-1.el7################################# [ 90%]
  10:mysql-community-common-5.7.35-1.e################################# [100%]

# 只安装客户端和服务器以及依赖包
# server依赖，common和client，client依赖common和common-libs（其他的系统的许多基础性包）

[root@c79maria10 mysql57]# rpm -q --requires mysql-community-server-5.7.35-1.el7 | grep mysql
config(mysql-community-server) = 5.7.35-1.el7
mysql-community-client(x86-64) >= 5.7.9
mysql-community-common(x86-64) = 5.7.35-1.el7

[root@c79maria10 mysql57]# rpm -q --requires mysql-community-client | grep mysql
mysql-community-libs(x86-64) >= 5.7.9

[root@c79maria10 mysql57]# rpm -ivh mysql-community-common-5.7.35-1.el7.x86_64.rpm
[root@c79maria10 mysql57]# rpm -ivh mysql-community-libs-5.7.35-1.el7.x86_64.rpm
[root@c79maria10 mysql57]# rpm -ivh mysql-community-client-5.7.35-1.el7.x86_64.rpm
[root@c79maria10 mysql57]# rpm -ivh mysql-community-server-5.7.35-1.el7.x86_64.rpm

```



安装路径，相关文件

```sh

[root@c79maria10 mysql57]# rpm -ql $(rpm -qa | grep mysql) | grep -v -e /usr/share/ -e /usr/lib64/
/usr/bin/mysql
/usr/bin/mysql_config_editor
/usr/bin/mysqladmin
/usr/bin/mysqlbinlog
/usr/bin/mysqlcheck
/usr/bin/mysqldump
/usr/bin/mysqlimport
/usr/bin/mysqlpump
/usr/bin/mysqlshow
/usr/bin/mysqlslap
/etc/ld.so.conf.d/mysql-x86_64.conf
/etc/logrotate.d/mysql
/etc/my.cnf
/etc/my.cnf.d
/usr/bin/innochecksum
/usr/bin/lz4_decompress
/usr/bin/my_print_defaults
/usr/bin/myisam_ftdump
/usr/bin/myisamchk
/usr/bin/myisamlog
/usr/bin/myisampack
/usr/bin/mysql_install_db
/usr/bin/mysql_plugin
/usr/bin/mysql_secure_installation
/usr/bin/mysql_ssl_rsa_setup
/usr/bin/mysql_tzinfo_to_sql
/usr/bin/mysql_upgrade
/usr/bin/mysqld_pre_systemd
/usr/bin/mysqldumpslow
/usr/bin/perror
/usr/bin/replace
/usr/bin/resolve_stack_dump
/usr/bin/resolveip
/usr/bin/zlib_decompress
/usr/lib/systemd/system/mysqld.service
/usr/lib/systemd/system/mysqld@.service
/usr/lib/tmpfiles.d/mysql.conf
/usr/sbin/mysqld
/usr/sbin/mysqld-debug
/var/lib/mysql
/var/lib/mysql-files
/var/lib/mysql-keyring
/var/run/mysqld

```

启动MySQL服务器

```sh
[root@c79maria10 ~]# systemctl start mysqld

[root@c79maria10 ~]# ss -ntlp | grep mysql
LISTEN     0      80        [::]:3306                  [::]:*                   users:(("mysqld",pid=2015,fd=21))

```

登录

```sh
[root@c79maria10 ~]# mysql
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)
[root@c79maria10 ~]# grep password /var/log/mysqld.log
2021-12-23T12:28:26.345720Z 1 [Note] A temporary password is generated for root@localhost: HyWPf,Sgz2*a
2021-12-23T12:29:52.814038Z 2 [Note] Access denied for user 'root'@'localhost' (using password: NO)

# 修改初始密码，用初始密码登录后修改（破解密码，或者忘记密码怎么办▲▲）
[root@c79maria10 ~]# mysql -uroot -p'HyWPf,Sgz2*a'
mysql> status
ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.

mysql> alter user 'root'@'localhost' identified by 'MySQL123!';
Query OK, 0 rows affected (0.00 sec)

mysql> status
--------------
mysql  Ver 14.14 Distrib 5.7.35, for Linux (x86_64) using  EditLine wrapper

Connection id:          3
Current database:
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         5.7.35
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    latin1
Db     characterset:    latin1
Client characterset:    utf8
Conn.  characterset:    utf8
UNIX socket:            /var/lib/mysql/mysql.sock
Uptime:                 3 min 37 sec

Threads: 1  Questions: 7  Slow queries: 0  Opens: 106  Flush tables: 1  Open tables: 99  Queries per second avg: 0.032
--------------


[root@c79maria10 ~]# mysql -uroot -p'MySQL123!'

# 修改密码2（怎么使用ssl，怎么设置命令不记录password之类的命令？▲▲）
[root@c79maria10 ~]# mysqladmin -uroot -p'MySQL123!' password 'MySQL124!'
mysqladmin: [Warning] Using a password on the command line interface can be insecure.
Warning: Since password will be sent to server in plain text, use ssl connection to ensure password safety.

```



### CentOS7安装MySQL 5.7（yum）清华镜像

卸载上面安装的MySQL（还需要卸载数据，日志文件等）

```sh
[root@c79maria10 ~]# rpm -qa | grep mysql
mysql-community-common-5.7.35-1.el7.x86_64
mysql-community-client-5.7.35-1.el7.x86_64
mysql-community-libs-5.7.35-1.el7.x86_64
mysql-community-server-5.7.35-1.el7.x86_64
[root@c79maria10 ~]# rpm -evh $(rpm -qa | grep mysql)
Preparing...                          ################################# [100%]
Cleaning up / removing...
   1:mysql-community-server-5.7.35-1.e################################# [ 25%]
   2:mysql-community-client-5.7.35-1.e################################# [ 50%]
   3:mysql-community-libs-5.7.35-1.el7################################# [ 75%]
   4:mysql-community-common-5.7.35-1.e################################# [100%]

```

配置 yum源

```sh
# URL
# https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-5.7-community-el7-x86_64/

[root@c79maria10 ~]# tee /etc/yum.repos.d/mysql.tsinghua.repo << EOL
> [mysql]
> name=mysql5.7
> baseurl=https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-5.7-community-el7-x86_64/
> gpgcheck=0
> enabled=1
> EOL
[mysql]
name=mysql5.7
baseurl=https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-5.7-community-el7-x86_64/
gpgcheck=0
enabled=1
[root@c79maria10 ~]# yum repolist
mysql                                                  | 2.9 kB  00:00:00
mysql/primary_db                                       | 302 kB  00:00:03
repo id                    repo name                               status
base/7/x86_64              CentOS-7 - Base                         10,072
extras/7/x86_64            CentOS-7 - Extras                          500
mysql                      mysql5.7                                   544
updates/7/x86_64           CentOS-7 - Updates                       3,242
repolist: 14,358

```

安装

```sh
[root@c79maria10 ~]# yum -y install mysql-community-server
Warning: RPMDB altered outside of yum.

  Installing : mysql-community-common-5.7.36-1.el7.x86_64        1/4
  Installing : mysql-community-libs-5.7.36-1.el7.x86_64          2/4
  Installing : mysql-community-client-5.7.36-1.el7.x86_64        3/4
  Installing : mysql-community-server-5.7.36-1.el7.x86_64 [### ] 4/4

[root@c79maria10 ~]# rpm -qa | grep mysql
mysql-community-common-5.7.36-1.el7.x86_64
mysql-community-client-5.7.36-1.el7.x86_64
mysql-community-libs-5.7.36-1.el7.x86_64
mysql-community-server-5.7.36-1.el7.x86_64

[root@c79maria10 ~]# systemctl start mysqld

[root@c79maria10 ~]# ss -ntlp | grep mysql
LISTEN     0      80        [::]:3306                  [::]:*                   users:(("mysqld",pid=2274,fd=22))

```

修改初期密码

```sh
# 没有产生初始密码怎办？▲▲安装后有个初始化，话生成数据文件，日志等。如果直接用其他数据文件的话，root密码如何设置？？
[root@c79maria10 ~]# grep password /var/log/mysqld.log

[root@c79maria10 ~]# grep password /var/log/mysqld.log
2021-12-23T12:28:26.345720Z 1 [Note] A temporary password is generated for root@localhost: HyWPf,Sgz2*a
2021-12-23T12:29:52.814038Z 2 [Note] Access denied for user 'root'@'localhost' (using password: NO)
2021-12-23T12:35:59.095055Z 0 [Note] Shutting down plugin 'validate_password'
2021-12-23T12:36:00.819807Z 0 [Note] Shutting down plugin 'sha256_password'
2021-12-23T12:36:00.819810Z 0 [Note] Shutting down plugin 'mysql_native_password'
2021-12-23T12:44:34.068069Z 2 [Note] Access denied for user 'root'@'localhost' (using password: NO)
2021-12-23T12:45:21.540152Z 3 [Note] Access denied for user 'root'@'localhost' (using password: YES)
2021-12-23T12:45:45.788246Z 4 [Note] Access denied for user 'root'@'localhost' (using password: YES)
2021-12-23T12:47:00.441677Z 5 [Note] Access denied for user 'root'@'localhost' (using password: NO)

# 旧的数据库文件，日志没有删除，所以安装后没有生成新的密码

[root@c79maria10 ~]# mysql -uroot -p'MySQL124!'
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 7
Server version: 5.7.36 MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>

```

### CentOS7安装MariaDB 10.6（yum）官方镜像 

卸载掉MySQL

```sh
[root@c79maria10 ~]# systemctl stop mysqld
[root@c79maria10 ~]# rpm -evh $(rpm -qa | grep mysql)
Preparing...                          ################################# [100%]
Cleaning up / removing...
   1:mysql-community-server-5.7.36-1.e################################# [ 25%]
   2:mysql-community-client-5.7.36-1.e################################# [ 50%]
   3:mysql-community-libs-5.7.36-1.el7################################# [ 75%]
   4:mysql-community-common-5.7.36-1.e################################# [100%]

# yum源无效化

[root@c79maria10 ~]# mv /etc/yum.repos.d/mysql.tsinghua.repo /etc/yum.repos.d/mysql.tsinghua.repo.bak

```

配置yum源，MariaDB URL

```sh
# https://mariadb.org/download/?t=repo-config&d=CentOS+7+%28x86_64%29&v=10.6&r_m=yamagata-university

[root@c79maria10 ~]# cat > /etc/yum.repos.d/mariadb10.6.repo << EOL
> # MariaDB 10.6 CentOS repository list - created 2021-12-23 12:53 UTC
> # https://mariadb.org/download/
> [mariadb]
> name = MariaDB
> baseurl = https://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/yum/10.6/centos7-amd64
> gpgkey=https://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/yum/RPM-GPG-KEY-MariaDB
> gpgcheck=1
> EOL

[root@c79maria10 ~]# yum repolist              
mariadb                                                | 3.4 kB  00:00:00
(1/2): mariadb/updateinfo                              | 5.4 kB  00:00:00
(2/2): mariadb/primary_db                              |  67 kB  00:00:00
repo id                     repo name                              status
base/7/x86_64               CentOS-7 - Base                        10,072
extras/7/x86_64             CentOS-7 - Extras                         500
mariadb                     MariaDB                                    93
updates/7/x86_64            CentOS-7 - Updates                      3,242
repolist: 13,907                                  


```

安装

```sh
[root@c79maria10 ~]# yum -y install MariaDB-server MariaDB-client

Install  2 Packages (+15 Dependent packages)
Total download size: 54 M
Installed size: 225 M
Downloading packages:
warning: /var/cache/yum/x86_64/7/mariadb/packages/MariaDB-common-10.6.5-1.el7.centos.x86_64.rpm: Header V4 DSA/SHA1 Signature, key ID 1bb943db: NOKEY

Warning: RPMDB altered outside of yum.


[root@c79maria10 ~]# rpm -ql $(rpm -qa | grep MariaDB) | grep -v -e /usr/share -e /usr/lib64 -e /usr/lib
/etc/my.cnf
/etc/my.cnf.d
/etc/my.cnf.d/mysql-clients.cnf
/usr/bin/mariadb
/usr/bin/mariadb-access
/usr/bin/mariadb-admin
/usr/bin/mariadb-binlog
/usr/bin/mariadb-check
/usr/bin/mariadb-conv
/usr/bin/mariadb-convert-table-format
/usr/bin/mariadb-dump
/usr/bin/mariadb-dumpslow
/usr/bin/mariadb-embedded
/usr/bin/mariadb-find-rows
/usr/bin/mariadb-hotcopy
/usr/bin/mariadb-import
/usr/bin/mariadb-plugin
/usr/bin/mariadb-secure-installation
/usr/bin/mariadb-setpermission
/usr/bin/mariadb-show
/usr/bin/mariadb-slap
/usr/bin/mariadb-tzinfo-to-sql
/usr/bin/mariadb-waitpid
/usr/bin/msql2mysql
/usr/bin/my_print_defaults
/usr/bin/mysql
/usr/bin/mysql_embedded
/usr/bin/mysql_find_rows
/usr/bin/mysql_plugin
/usr/bin/mysql_tzinfo_to_sql
/usr/bin/mysql_waitpid
/usr/bin/mysqlaccess
/usr/bin/mysqladmin
/usr/bin/mysqlbinlog
/usr/bin/mysqlcheck
/usr/bin/mysqldump
/usr/bin/mysqlimport
/usr/bin/mysqlshow
/usr/bin/mysqlslap
/usr/bin/mytop
/usr/bin/replace
/etc/logrotate.d/mysql
/etc/my.cnf.d
/etc/my.cnf.d/enable_encryption.preset
/etc/my.cnf.d/server.cnf
/etc/my.cnf.d/spider.cnf
/etc/security/user_map.conf
/lib64/security/pam_user_map.so
/usr/bin/aria_chk
/usr/bin/aria_dump_log
/usr/bin/aria_ftdump
/usr/bin/aria_pack
/usr/bin/aria_read_log
/usr/bin/galera_new_cluster
/usr/bin/galera_recovery
/usr/bin/innochecksum
/usr/bin/mariadb-fix-extensions
/usr/bin/mariadb-install-db
/usr/bin/mariadb-service-convert
/usr/bin/mariadb-upgrade
/usr/bin/mariadbd-multi
/usr/bin/mariadbd-safe
/usr/bin/mariadbd-safe-helper
/usr/bin/myisam_ftdump
/usr/bin/myisamchk
/usr/bin/myisamlog
/usr/bin/myisampack
/usr/bin/mysql_fix_extensions
/usr/bin/mysql_install_db
/usr/bin/mysql_upgrade
/usr/bin/mysqld_multi
/usr/bin/mysqld_safe
/usr/bin/mysqld_safe_helper
/usr/bin/perror
/usr/bin/resolve_stack_dump
/usr/bin/resolveip
/usr/bin/wsrep_sst_common
/usr/bin/wsrep_sst_mariabackup
/usr/bin/wsrep_sst_mysqldump
/usr/bin/wsrep_sst_rsync
/usr/bin/wsrep_sst_rsync_wan
/usr/sbin/mariadbd
/usr/sbin/mysqld
/usr/sbin/rcmysql

[root@c79maria10 ~]# rpm -qf /usr/bin/mysql
MariaDB-client-10.6.5-1.el7.centos.x86_64

```

启动（一启动就有2个监听，一个IPV6？）

```sh
[root@c79maria10 ~]# systemctl start mariadb
[root@c79maria10 ~]# ss -ntlp | grep mariadb
LISTEN     0      80           *:3306                     *:*                   users:(("mariadbd",pid=2671,fd=20))
LISTEN     0      80        [::]:3306                  [::]:*                   users:(("mariadbd",pid=2671,fd=22))

```

登录

```sh
# 和MySQL兼容，连数据文件 都是用一样的默认的，所以，旧的配置留了下来的。密码什么的
[root@c79maria10 ~]# mysql -uroot -p'MySQL124!'
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 4
Server version: 10.6.5-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>

```



清除旧MySQL配置，重新安装

```sh
[root@c79maria10 ~]# systemctl stop mariadb
[root@c79maria10 ~]# mv /var/lib/mysql /var/lib/mysql.bak


[root@c79maria10 ~]# rpm -evh $(rpm -qa | grep MariaDB)
Preparing...                          ################################# [100%]
Cleaning up / removing...
   1:MariaDB-server-10.6.5-1.el7.cento################################# [ 25%]
   2:MariaDB-client-10.6.5-1.el7.cento################################# [ 50%]
   3:MariaDB-compat-10.6.5-1.el7.cento################################# [ 75%]
   4:MariaDB-common-10.6.5-1.el7.cento################################# [100%]

[root@c79maria10 ~]# yum -y install MariaDB-server MariaDB-client

[root@c79maria10 ~]# systemctl start mariadb
[root@c79maria10 ~]# mysql	# 全新安装的话，没有密码直接进入。yum安装的没有过程的日志
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 3
Server version: 10.6.5-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> status
--------------
mysql  Ver 15.1 Distrib 10.6.5-MariaDB, for Linux (x86_64) using readline 5.1

Connection id:          4
Current database:
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server:                 MariaDB
Server version:         10.6.5-MariaDB MariaDB Server
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    latin1
Db     characterset:    latin1
Client characterset:    utf8mb3
Conn.  characterset:    utf8mb3
UNIX socket:            /var/lib/mysql/mysql.sock
Uptime:                 1 min 23 sec

Threads: 1  Questions: 6  Slow queries: 0  Opens: 17  Open tables: 10  Queries per second avg: 0.072
--------------


[root@c79maria10 ~]# ls /var/lib | grep mysql
mysql
mysql.bak
[root@c79maria10 ~]# ls /var/lib | grep maria
[root@c79maria10 ~]#

[root@c79maria10 ~]# ls /var/lib/mysql
aria_log.00000001  c79maria10.pid    ib_buffer_pool  ib_logfile0  multi-master.info  mysql.sock          sys
aria_log_control   ddl_recovery.log  ibdata1         ibtmp1       mysql              performance_schema  test

```







### CentOS8安装MySQL 8.0（rpm）官方下载

连接

```sh
# https://downloads.mysql.com/archives/community/
# 下载RPM Bundle
# Red Hat Enterprise Linux 8 / Oracle Linux 8 (x86, 64-bit), RPM Bundle
# (mysql-8.0.24-1.el8.x86_64.rpm-bundle.tar)
# MD5: dc2783e841dc81660e05de70f8f29bfd

```

下载

```sh
[root@C84MySQL8 ~]# mkdir mysql8
[root@C84MySQL8 ~]# cd mysql8/

[root@C84MySQL8 mysql8]# wget https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.24-1.el8.x86_64.rpm-bundle.tar
--2021-12-23 22:30:10--  https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.24-1.el8.x86_64.rpm-bundle.tar
Resolving downloads.mysql.com (downloads.mysql.com)... 137.254.60.14
Connecting to downloads.mysql.com (downloads.mysql.com)|137.254.60.14|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://cdn.mysql.com/archives/mysql-8.0/mysql-8.0.24-1.el8.x86_64.rpm-bundle.tar [following]
--2021-12-23 22:30:11--  https://cdn.mysql.com/archives/mysql-8.0/mysql-8.0.24-1.el8.x86_64.rpm-bundle.tar
Resolving cdn.mysql.com (cdn.mysql.com)... 104.93.8.235
Connecting to cdn.mysql.com (cdn.mysql.com)|104.93.8.235|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 765358080 (730M) [application/x-tar]
Saving to: ‘mysql-8.0.24-1.el8.x86_64.rpm-bundle.tar’

4-1.el8.x86_64.rpm-bundle.tar    3%[>                                                  ]  25.87M  2.59MB/s    eta 4m 44s

[root@C84MySQL8 mysql8]# tar -xf mysql-8.0.24-1.el8.x86_64.rpm-bundle.tar

```

卸载冲突，安装依赖包

```sh
# 这里暂时没有冲突
[root@C84MySQL8 mysql8]# rpm -ivh mysql-community-server-8.0.24-1.el8.x86_64.rpm
warning: mysql-community-server-8.0.24-1.el8.x86_64.rpm: Header V3 DSA/SHA1 Signature, key ID 5072e1f5: NOKEY
error: Failed dependencies:
        /usr/bin/perl is needed by mysql-community-server-8.0.24-1.el8.x86_64
        libaio.so.1()(64bit) is needed by mysql-community-server-8.0.24-1.el8.x86_64
        libaio.so.1(LIBAIO_0.1)(64bit) is needed by mysql-community-server-8.0.24-1.el8.x86_64
        libaio.so.1(LIBAIO_0.4)(64bit) is needed by mysql-community-server-8.0.24-1.el8.x86_64
        mysql-community-client(x86-64) >= 8.0.11 is needed by mysql-community-server-8.0.24-1.el8.x86_64
        mysql-community-common(x86-64) = 8.0.24-1.el8 is needed by mysql-community-server-8.0.24-1.el8.x86_64
        net-tools is needed by mysql-community-server-8.0.24-1.el8.x86_64

[root@C84MySQL8 mysql8]# yum -y install net-tools libaio perl

[root@C84MySQL8 mysql8]# rpm -ivh mysql-community-common-8.0.24-1.el8.x86_64.rpm
warning: mysql-community-common-8.0.24-1.el8.x86_64.rpm: Header V3 DSA/SHA1 Signature, key ID 5072e1f5: NOKEY
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:mysql-community-common-8.0.24-1.e################################# [100%]


[root@C84MySQL8 mysql8]# rpm -ivh mysql-community-client-8.0.24-1.el8.x86_64.rpm
warning: mysql-community-client-8.0.24-1.el8.x86_64.rpm: Header V3 DSA/SHA1 Signature, key ID 5072e1f5: NOKEY
error: Failed dependencies:
        mysql-community-client-plugins = 8.0.24-1.el8 is needed by mysql-community-client-8.0.24-1.el8.x86_64
        mysql-community-libs(x86-64) >= 8.0.11 is needed by mysql-community-client-8.0.24-1.el8.x86_64

[root@C84MySQL8 mysql8]# rpm -ivh mysql-community-libs-8.0.24-1.el8.x86_64.rpm
warning: mysql-community-libs-8.0.24-1.el8.x86_64.rpm: Header V3 DSA/SHA1 Signature, key ID 5072e1f5: NOKEY
error: Failed dependencies:
        mysql-community-client-plugins = 8.0.24-1.el8 is needed by mysql-community-libs-8.0.24-1.el8.x86_64


[root@C84MySQL8 mysql8]# rpm -ivh mysql-community-client-plugins-8.0.24-1.el8.x86_64.rpm
[root@C84MySQL8 mysql8]# rpm -ivh mysql-community-libs-8.0.24-1.el8.x86_64.rpm
[root@C84MySQL8 mysql8]# rpm -ivh mysql-community-client-8.0.24-1.el8.x86_64.rpm
[root@C84MySQL8 mysql8]# rpm -ivh mysql-community-server-8.0.24-1.el8.x86_64.rpm
warning: mysql-community-server-8.0.24-1.el8.x86_64.rpm: Header V3 DSA/SHA1 Signature, key ID 5072e1f5: NOKEY
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:mysql-community-server-8.0.24-1.e################################# [100%]
[/usr/lib/tmpfiles.d/mysql.conf:23] Line references path below legacy directory /var/run/, updating /var/run/mysqld → /run/mysqld; please update the tmpfiles.d/ drop-in file accordingly.

```

文件 

```sh

[root@C84MySQL8 mysql8]# rpm -ql  $(rpm -qa | grep mysql) | grep -e bin -e etc
/usr/bin/mysql
/usr/bin/mysql_config_editor
/usr/bin/mysql_migrate_keyring
/usr/bin/mysqladmin
/usr/bin/mysqlbinlog
/usr/bin/mysqlcheck
/usr/bin/mysqldump
/usr/bin/mysqlimport
/usr/bin/mysqlpump
/usr/bin/mysqlshow
/usr/bin/mysqlslap
/usr/share/man/man1/mysqlbinlog.1.gz
/etc/ld.so.conf.d/mysql-x86_64.conf
/etc/logrotate.d/mysql
/etc/my.cnf
/etc/my.cnf.d
/usr/bin/ibd2sdi
/usr/bin/innochecksum
/usr/bin/lz4_decompress
/usr/bin/my_print_defaults
/usr/bin/myisam_ftdump
/usr/bin/myisamchk
/usr/bin/myisamlog
/usr/bin/myisampack
/usr/bin/mysql_secure_installation
/usr/bin/mysql_ssl_rsa_setup
/usr/bin/mysql_tzinfo_to_sql
/usr/bin/mysql_upgrade
/usr/bin/mysqld_pre_systemd
/usr/bin/mysqldumpslow
/usr/bin/perror
/usr/bin/zlib_decompress
/usr/lib64/mysql/mecab/dic/ipadic_euc-jp/char.bin
/usr/lib64/mysql/mecab/dic/ipadic_euc-jp/matrix.bin
/usr/lib64/mysql/mecab/dic/ipadic_sjis/char.bin
/usr/lib64/mysql/mecab/dic/ipadic_sjis/matrix.bin
/usr/lib64/mysql/mecab/dic/ipadic_utf-8/char.bin
/usr/lib64/mysql/mecab/dic/ipadic_utf-8/matrix.bin
/usr/lib64/mysql/mecab/etc
/usr/lib64/mysql/mecab/etc/mecabrc
/usr/sbin/mysqld

```

启动，初期设置 

```sh
# MySQL8，追加了一个扩展的端口33060
[root@C84MySQL8 mysql8]# systemctl start mysqld
[root@C84MySQL8 mysql8]# ss -ntlp | grep mysqld
LISTEN 0      70                 *:33060            *:*    users:(("mysqld",pid=14684,fd=22))
LISTEN 0      128                *:3306             *:*    users:(("mysqld",pid=14684,fd=25))


[root@C84MySQL8 mysql8]# grep password /var/log/mysqld.log
2021-12-23T13:43:38.889596Z 6 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: a:bgo1LNlYuj


[root@C84MySQL8 mysql8]# mysql
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)
[root@C84MySQL8 mysql8]# mysql -uroot -p'a:bgo1LNlYuj'
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 8.0.24

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> status
ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.# 修改密码后才能执行

mysql> alter user 'root'@'localhost' identified by 'MySQL123!';
Query OK, 0 rows affected (0.03 sec)

mysql> status
--------------
mysql  Ver 8.0.24 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          9
Current database:
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.24
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    utf8mb4
Conn.  characterset:    utf8mb4
UNIX socket:            /var/lib/mysql/mysql.sock
Binary data as:         Hexadecimal
Uptime:                 1 min 10 sec

Threads: 2  Questions: 7  Slow queries: 0  Opens: 130  Flush tables: 3  Open tables: 46  Queries per second avg: 0.100
--------------

```

### mysql_secure_installation

```sh
# MySQL是下划线
[root@C84MySQL8 mysql8]# rpm -ql $(rpm -qa | grep mysql) | grep secure_ins
/usr/bin/mysql_secure_installation

[root@C84MySQL8 mysql8]# file /usr/bin/mysql_secure_installation
/usr/bin/mysql_secure_installation: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=f152cebc71ab7344b3a7f1572de74d32e74048f4, stripped
# 不是脚本

```

运行安全安装之前（MySQL8比较严，不给登录）

```sh
[root@C84MySQL8 mysql8]# mysql -urrsx
ERROR 1045 (28000): Access denied for user 'rrsx'@'localhost' (using password: NO)
[root@C84MySQL8 mysql8]# mysql -uuser
ERROR 1045 (28000): Access denied for user 'user'@'localhost' (using password: NO)

[root@C84MySQL8 ~]# mysql -uajflka -p'sfa'
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1045 (28000): Access denied for user 'ajflka'@'localhost' (using password: YES)

[root@C84MySQL8 ~]# mysql -uanonymous
ERROR 1045 (28000): Access denied for user 'anonymous'@'localhost' (using password: NO)
[root@C84MySQL8 ~]# mysql -uanonymous -panonymous
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1045 (28000): Access denied for user 'anonymous'@'localhost' (using password: YES)

```

运行安全安装（好像没什么用了，MySQL8里，匿名用户本就不能登录，还是说有其他方式？▲▲）

```sh
[root@C84MySQL8 ~]# /usr/bin/mysql_secure_installation

Securing the MySQL server deployment.

Enter password for user root:
The 'validate_password' component is installed on the server.
The subsequent steps will run with the existing configuration
of the component.
Using existing password for root.

Estimated strength of the password: 100
Change the password for root ? ((Press y|Y for Yes, any other key for No) : B

 ... skipping.
By default, a MySQL installation has an anonymous user,
allowing anyone to log into MySQL without having to have
a user account created for them. This is intended only for
testing, and to make the installation go a bit smoother.
You should remove them before moving into a production
environment.

Remove anonymous users? (Press y|Y for Yes, any other key for No) : Y
Success.


Normally, root should only be allowed to connect from
'localhost'. This ensures that someone cannot guess at
the root password from the network.

Disallow root login remotely? (Press y|Y for Yes, any other key for No) : N

 ... skipping.
By default, MySQL comes with a database named 'test' that
anyone can access. This is also intended only for testing,
and should be removed before moving into a production
environment.


Remove test database and access to it? (Press y|Y for Yes, any other key for No) : Y
 - Dropping test database...
Success.

 - Removing privileges on test database...
Success.

Reloading the privilege tables will ensure that all changes
made so far will take effect immediately.

Reload privilege tables now? (Press y|Y for Yes, any other key for No) : Y
Success.

All done!

```



### mariadb-secure-installation

程序

```sh
[root@c79maria10 ~]# rpm -ql $(rpm -qa | grep MariaDB) | grep bin
/usr/bin/mariadb
/usr/bin/mariadb-access
/usr/bin/mariadb-admin
/usr/bin/mariadb-binlog
/usr/bin/mariadb-check
/usr/bin/mariadb-conv
/usr/bin/mariadb-convert-table-format
/usr/bin/mariadb-dump
/usr/bin/mariadb-dumpslow
/usr/bin/mariadb-embedded
/usr/bin/mariadb-find-rows
/usr/bin/mariadb-hotcopy
/usr/bin/mariadb-import
/usr/bin/mariadb-plugin
/usr/bin/mariadb-secure-installation
/usr/bin/mariadb-setpermission
/usr/bin/mariadb-show
/usr/bin/mariadb-slap
/usr/bin/mariadb-tzinfo-to-sql
/usr/bin/mariadb-waitpid
/usr/bin/msql2mysql
/usr/bin/my_print_defaults
/usr/bin/mysql
/usr/bin/mysql_embedded
/usr/bin/mysql_find_rows
/usr/bin/mysql_plugin
/usr/bin/mysql_tzinfo_to_sql
/usr/bin/mysql_waitpid
/usr/bin/mysqlaccess
/usr/bin/mysqladmin
/usr/bin/mysqlbinlog
/usr/bin/mysqlcheck
/usr/bin/mysqldump
/usr/bin/mysqlimport
/usr/bin/mysqlshow
/usr/bin/mysqlslap
/usr/bin/mytop
/usr/bin/replace
/usr/share/man/man1/mariadb-binlog.1.gz
/usr/share/man/man1/mysqlbinlog.1.gz
/usr/bin/aria_chk
/usr/bin/aria_dump_log
/usr/bin/aria_ftdump
/usr/bin/aria_pack
/usr/bin/aria_read_log
/usr/bin/galera_new_cluster
/usr/bin/galera_recovery
/usr/bin/innochecksum
/usr/bin/mariadb-fix-extensions
/usr/bin/mariadb-install-db
/usr/bin/mariadb-service-convert
/usr/bin/mariadb-upgrade
/usr/bin/mariadbd-multi
/usr/bin/mariadbd-safe
/usr/bin/mariadbd-safe-helper
/usr/bin/myisam_ftdump
/usr/bin/myisamchk
/usr/bin/myisamlog
/usr/bin/myisampack
/usr/bin/mysql_fix_extensions
/usr/bin/mysql_install_db
/usr/bin/mysql_upgrade
/usr/bin/mysqld_multi
/usr/bin/mysqld_safe
/usr/bin/mysqld_safe_helper
/usr/bin/perror
/usr/bin/resolve_stack_dump
/usr/bin/resolveip
/usr/bin/wsrep_sst_common
/usr/bin/wsrep_sst_mariabackup
/usr/bin/wsrep_sst_mysqldump
/usr/bin/wsrep_sst_rsync
/usr/bin/wsrep_sst_rsync_wan
/usr/sbin/mariadbd
/usr/sbin/mysqld
/usr/sbin/rcmysql
/usr/share/mysql/binary-configure
/usr/share/mysql/policy/apparmor/usr.sbin.mysqld
/usr/share/mysql/policy/apparmor/usr.sbin.mysqld.local
```

运行安全程序，设置root密码，root的远程登录，删除anonymous账户和test数据库等

/usr/bin/mariadb-secure-installation

```sh
[root@c79maria10 ~]# file /usr/bin/mariadb-secure-installation
/usr/bin/mariadb-secure-installation: POSIX shell script, ASCII text executable

```

运行脚本之前

```sh
# 任意名的用户都可以免密码本地登录
[root@c79maria10 ~]# mysql -uyyy
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 5
Server version: 10.6.5-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> exit
Bye
[root@c79maria10 ~]# mysql -uaaaa
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 6
Server version: 10.6.5-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>


MariaDB [(none)]> show databases;	# 可以查询数据库
+--------------------+
| Database           |
+--------------------+
| information_schema |
| test               |
+--------------------+
2 rows in set (0.002 sec)

MariaDB [(none)]> select user,host from mysql.user;	# MariaDB 10需要明确的权限来查询用户
ERROR 1142 (42000): SELECT command denied to user ''@'localhost' for table 'user'

MariaDB [(none)]> use test;
Database changed
MariaDB [test]> show tables;
Empty set (0.000 sec)


MariaDB [test]> create database test1;
ERROR 1044 (42000): Access denied for user ''@'localhost' to database 'test1'

MariaDB [test]> status
--------------
mysql  Ver 15.1 Distrib 10.6.5-MariaDB, for Linux (x86_64) using readline 5.1

Connection id:          6
Current database:       test
Current user:           aaaa@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server:                 MariaDB
Server version:         10.6.5-MariaDB MariaDB Server
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    latin1
Db     characterset:    latin1
Client characterset:    utf8mb3
Conn.  characterset:    utf8mb3
UNIX socket:            /var/lib/mysql/mysql.sock
Uptime:                 9 min 27 sec

Threads: 1  Questions: 24  Slow queries: 0  Opens: 17  Open tables: 10  Queries per second avg: 0.042
--------------

```

运行安全脚本

```sh
# MariaDB123!


[root@c79maria10 ~]# /usr/bin/mariadb-secure-installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] n	# 切换socket认证？？
 ... skipping.

You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n]
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]	# 删除匿名
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] n	# root的远程登录
 ... skipping.

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] n
 ... skipping.

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] Y	# 重载权限设置
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!



[root@c79maria10 ~]# mysql -uroot -p''MariaDB123!
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 13
Server version: 10.6.5-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> select user,host from mysql.user;
+-------------+-----------+
| User        | Host      |
+-------------+-----------+
| mariadb.sys | localhost |
| mysql       | localhost |
| root        | localhost |
+-------------+-----------+
3 rows in set (0.002 sec)


```



## 二进制安装（免安装二进制）

### CentOS8安装MySQL8.0（二进制）

通用二进制安装教程

```http
# https://dev.mysql.com/doc/refman/8.0/en/binary-installation.html
# 大致流程
  $> groupadd mysql
  $> useradd -r -g mysql -s /bin/false mysql
  $> cd /usr/local
  $> tar xvf /path/to/mysql-VERSION-OS.tar.xz
  $> ln -s full-path-to-mysql-VERSION-OS mysql
  $> cd mysql
  $> mkdir mysql-files
  $> chown mysql:mysql mysql-files
  $> chmod 750 mysql-files
  $> bin/mysqld --initialize --user=mysql
  $> bin/mysql_ssl_rsa_setup
  $> bin/mysqld_safe --user=mysql &
  # Next command is optional
  $> cp support-files/mysql.server /etc/init.d/mysql.server


```

准备一个干净的系统（or完全卸载MySQL和MariaDB）

```sh

[root@C84MySQL8a ~]# rpm -qa  | grep -i -e mysql -e mariadb
[root@C84MySQL8a ~]# echo $?
1

[root@C84MySQL8a ~]# find / -name my.cnf
[root@C84MySQL8a ~]# echo $?
0

```

安装依赖包

```sh
[root@C84MySQL8a ~]# dnf -y install libaio ncurses-compat-libs

```

创建用户和组

```sh
[root@C84MySQL8a ~]# groupadd -r -g 360 mysql
[root@C84MySQL8a ~]# useradd -r -g 360 -u 360 -d /data/mysql mysql
[root@C84MySQL8a ~]# id mysql
uid=360(mysql) gid=360(mysql) groups=360(mysql)

```

创建数据目录

```sh
[root@C84MySQL8a ~]# mkdir /data/mysql
[root@C84MySQL8a ~]# chown mysql:mysql /data/mysql/
[root@C84MySQL8a ~]# ll -d /data/mysql/
drwxr-xr-x. 2 mysql mysql 6 Dec 25 10:23 /data/mysql/

```

下载免安装包

```sh
# URL
# https://dev.mysql.com/downloads/mysql/
# 需选择
# Linux - Generic
# 才能显示出xxxxx.tar.gz包（这个要1G多，真大！！！比rpm大了一倍）xz来的

Compressed TAR Archive
(mysql-8.0.27-linux-glibc2.12-x86_64.tar.xz)
MD5: 0bdd171cb8464ba32f65f7bf58bc9533

# 换一个
# https://downloads.mysql.com/archives/community/
# 

Linux - Generic (glibc 2.12) (x86, 64-bit), Compressed TAR Archive
(mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz)
MD5: c1b7e64241866ed68f7c637c99fe39a4



[root@C84MySQL8a ~]# mkdir mysql8.bin
[root@C84MySQL8a ~]# cd mysql8.bin/
[root@C84MySQL8a mysql8.bin]# wget https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz
--2021-12-25 10:36:28--  https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz
Resolving downloads.mysql.com (downloads.mysql.com)... 137.254.60.14
Connecting to downloads.mysql.com (downloads.mysql.com)|137.254.60.14|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://cdn.mysql.com/archives/mysql-8.0/mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz [following]
--2021-12-25 10:36:29--  https://cdn.mysql.com/archives/mysql-8.0/mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz
Resolving cdn.mysql.com (cdn.mysql.com)... 104.93.8.235
Connecting to cdn.mysql.com (cdn.mysql.com)|104.93.8.235|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 603019898 (575M) [application/x-tar-gz]
Saving to: ‘mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz’

0.11-linux-glibc2.12-x86_64   7%[==>                                         ]  43.07M  10.3MB/s    eta 57s


[root@C84MySQL8a mysql8.bin]# ll -h
total 576M
-rw-r--r--. 1 root root 576M Apr  8  2018 mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz


[root@C84MySQL8a mysql8.bin]# md5sum mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz
c1b7e64241866ed68f7c637c99fe39a4  mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz

```

开始部署MySQL8

```sh
# 解压
[root@C84MySQL8a mysql8.bin]# tar xf mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz -C /usr/local
[root@C84MySQL8a mysql8.bin]# cd /usr/local
[root@C84MySQL8a local]# ls
bin  etc  games  include  lib  lib64  libexec  mysql-8.0.11-linux-glibc2.12-x86_64  sbin  share  src

# 配置软连接
[root@C84MySQL8a local]# ln -sv mysql-8.0.11-linux-glibc2.12-x86_64 mysql
'mysql' -> 'mysql-8.0.11-linux-glibc2.12-x86_64'
[root@C84MySQL8a local]# ls
bin  etc  games  include  lib  lib64  libexec  mysql  mysql-8.0.11-linux-glibc2.12-x86_64  sbin  share  src

# 修改权限

[root@C84MySQL8a local]# ll mysql/
total 308
drwxr-xr-x.  2 root root    4096 Dec 25 10:39 bin
drwxr-xr-x.  2 root root      55 Dec 25 10:39 docs
drwxr-xr-x.  3 root root     266 Dec 25 10:39 include
drwxr-xr-x.  5 root root     272 Dec 25 10:39 lib
-rw-r--r--.  1 7161 31415 301518 Apr  8  2018 LICENSE
drwxr-xr-x.  4 root root      30 Dec 25 10:39 man
-rw-r--r--.  1 7161 31415    687 Apr  8  2018 README
drwxr-xr-x. 28 root root    4096 Dec 25 10:39 share
drwxr-xr-x.  2 root root      90 Dec 25 10:39 support-files

[root@C84MySQL8a local]# chown -R root:root /usr/local/mysql/


# 配置文件（没有提供模板cnf。。。）
[root@C84MySQL8a local]# cd /usr/local/mysql

[root@C84MySQL8a mysql]# cat /etc/my.cnf
[mysqld]
datadir = /data/mysql

# 初始化
[root@C84MySQL8a mysql]# bin/mysqld --initialize --user=mysql --datadir=/data/mysql
2021-12-25T01:49:41.304812Z 0 [System] [MY-013169] [Server] /usr/local/mysql-8.0.11-linux-glibc2.12-x86_64/bin/mysqld (mysqld 8.0.11) initializing of server in progress as process 9742
2021-12-25T01:49:43.918108Z 5 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: Y&Ai;Lfpy0Jd
2021-12-25T01:49:45.515989Z 0 [System] [MY-013170] [Server] /usr/local/mysql-8.0.11-linux-glibc2.12-x86_64/bin/mysqld (mysqld 8.0.11) initializing of server has completed
[root@C84MySQL8a mysql]#


[root@C84MySQL8a mysql]# bin/mysql_ssl_rsa_setup
[root@C84MySQL8a mysql]# echo $?
0
[root@C84MySQL8a mysql]#

# 启动（为何是启动mysql_safe▲▲第一次的原因？）
[root@C84MySQL8a mysql]# bin/mysqld_safe --user=mysql &
[1] 9791
[root@C84MySQL8a mysql]# Logging to '/data/mysql/C84MySQL8a.err'.
2021-12-25T01:50:55.183980Z mysqld_safe Starting mysqld daemon with databases from /data/mysql

# 修改密码

[root@C84MySQL8a mysql]# bin/mysql
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)
[root@C84MySQL8a mysql]# bin/mysql -uroot -p'Y&Ai;Lfpy0Jd'
Your MySQL connection id is 9
Server version: 8.0.11

mysql> status
ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.


mysql> alter user 'root'@'localhost' identified by 'MySQL123!';
Query OK, 0 rows affected (0.10 sec)

mysql> status
--------------
bin/mysql  Ver 8.0.11 for linux-glibc2.12 on x86_64 (MySQL Community Server - GPL)

Connection id:          9
Current database:
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.11
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    utf8mb4
Conn.  characterset:    utf8mb4
UNIX socket:            /tmp/mysql.sock
Uptime:                 4 min 42 sec

Threads: 2  Questions: 11  Slow queries: 0  Opens: 123  Flush tables: 2  Open tables: 99  Queries per second avg: 0.039
--------------

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.00 sec)

mysql> select user,host from mysql.user;
+------------------+-----------+
| user             | host      |
+------------------+-----------+
| mysql.infoschema | localhost |
| mysql.session    | localhost |
| mysql.sys        | localhost |
| root             | localhost |
+------------------+-----------+
4 rows in set (0.00 sec)


```

配置客户端自动登录

```sh

[root@C84MySQL8a mysql]# cat ~/.my.cnf
[mysql]
user=root
password=MySQL123!
[root@C84MySQL8a mysql]# bin/mysqladmin shutdown
mysqladmin: connect to server at 'localhost' failed
error: 'Access denied for user 'root'@'localhost' (using password: NO)'

```

设置启动脚本（init）

```sh
[root@C84MySQL8a mysql]# cp support-files/mysql.server /etc/init.d/mysql.server
[root@C84MySQL8a mysql]# ls /etc/init.d/
functions  mysql.server  README

[root@C84MySQL8a mysql]# service mysql.server status
 SUCCESS! MySQL running (9888)


[root@C84MySQL8a mysql]# kill -9 9888
[root@C84MySQL8a mysql]# bin/mysqld_safe: line 199:  9888 Killed                  env MYSQLD_PARENT_PID=9791 nohup /usr/local/mysql/bin/mysqld --basedir=/usr/local/mysql --datadir=/data/mysql --plugin-dir=/usr/local/mysql/lib/plugin --user=mysql --log-error=C84MySQL8a.err --pid-file=C84MySQL8a.pid < /dev/null > /dev/null 2>&1
2021-12-25T02:00:36.718453Z mysqld_safe Number of processes running now: 0
2021-12-25T02:00:36.723661Z mysqld_safe mysqld restarted


[root@C84MySQL8a mysql]# service mysql.server status
 SUCCESS! MySQL running (10007)

# 无法kill？？？▲▲自我保护机制？？

[root@C84MySQL8a mysql]# bin/mysqladmin shutdown -uroot -p'MySQL123!'
mysqladmin: [Warning] Using a password on the command line interface can be insecure.
[root@C84MySQL8a mysql]# 2021-12-25T02:05:52.209461Z mysqld_safe mysqld from pid file /data/mysql/C84MySQL8a.pid ended

[1]+  Done                    bin/mysqld_safe --user=mysql
[root@C84MySQL8a mysql]# ps -ef | grep mysql
root       10222     990  0 11:06 pts/0    00:00:00 grep --color=auto mysql


[root@C84MySQL8a mysql]# service mysql.server status
 ERROR! MySQL is not running


[root@C84MySQL8a mysql]# service mysql.server start
Starting MySQL. SUCCESS!
[root@C84MySQL8a mysql]# ps -ef | grep mysql
root       10265       1  0 11:07 pts/0    00:00:00 /bin/sh /usr/local/mysql/bin/mysqld_safe --datadir=/data/mysql --pid-file=/data/mysql/C84MySQL8a.pid
mysql      10377   10265  7 11:07 pts/0    00:00:00 /usr/local/mysql/bin/mysqld --basedir=/usr/local/mysql --datadir=/data/mysql --plugin-dir=/usr/local/mysql/lib/plugin --user=mysql --log-error=C84MySQL8a.err --pid-file=/data/mysql/C84MySQL8a.pid
root       10420     990  0 11:08 pts/0    00:00:00 grep --color=auto mysql
[root@C84MySQL8a mysql]# bin/mysql -uroot -p'MySQL123!'
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8


[root@C84MySQL8a mysql]# service mysql.server stop
Shutting down MySQL.. SUCCESS!
[root@C84MySQL8a mysql]# service mysql.server status
 ERROR! MySQL is not running

```

设置启动脚本（systemd）▲参考其他安装方法生成的mysql.service文件

```sh

[root@C84MySQL8a ~]# cat /etc/systemd/system/mysqld8.service
[Unit]
Description=MySQL Server 8 GPL
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql
Type=notify
TimeoutSec=0
PermissionsStartOnly=true
# ExecStartPre=/usr/bin/mysqld_pre_systemd
ExecStart=/usr/local/mysql/bin/mysqld $MYSQLD_OPTS
# EnvironmentFile=-/etc/sysconfig/mysql
LimitNOFILE = 10000
Restart=on-failure
RestartPreventExitStatus=1
Environment=MYSQLD_PARENT_PID=1
PrivateTmp=false


[root@C84MySQL8a ~]# systemctl daemon-reload
[root@C84MySQL8a ~]# systemctl status mysqld8
● mysqld8.service - MySQL Server 8 GPL
   Loaded: loaded (/etc/systemd/system/mysqld8.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
     Docs: man:mysqld(8)
           http://dev.mysql.com/doc/refman/en/using-systemd.html



[root@C84MySQL8a ~]# systemctl start mysqld8
[root@C84MySQL8a ~]# systemctl status mysqld8
● mysqld8.service - MySQL Server 8 GPL
   Loaded: loaded (/etc/systemd/system/mysqld8.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2021-12-25 11:19:33 JST; 5s ago
     Docs: man:mysqld(8)
           http://dev.mysql.com/doc/refman/en/using-systemd.html
 Main PID: 10605 (mysqld)
   Status: "SERVER_OPERATING"
    Tasks: 37 (limit: 5979)
   Memory: 363.1M
   CGroup: /system.slice/mysqld8.service
           └─10605 /usr/local/mysql/bin/mysqld

Dec 25 11:19:32 C84MySQL8a systemd[1]: Starting MySQL Server 8 GPL...
Dec 25 11:19:33 C84MySQL8a mysqld[10605]: 2021-12-25T02:19:33.117257Z 0 [System] [MY-010116] [Server] /usr/loca>
Dec 25 11:19:33 C84MySQL8a mysqld[10605]: 2021-12-25T02:19:33.486045Z 0 [Warning] [MY-010068] [Server] CA certi>
Dec 25 11:19:33 C84MySQL8a mysqld[10605]: 2021-12-25T02:19:33.506638Z 0 [System] [MY-010931] [Server] /usr/loca>
Dec 25 11:19:33 C84MySQL8a systemd[1]: Started MySQL Server 8 GPL.


[root@C84MySQL8a ~]# mysql -uroot -p'MySQL123!'
mysql> status
--------------
mysql  Ver 8.0.11 for linux-glibc2.12 on x86_64 (MySQL Community Server - GPL)

Connection id:          8
Current user:           root@localhost
Connection:             Localhost via UNIX socket


# init的也可以看到，是因为用来一样的配置文件？/etc/my.cnf▲
[root@C84MySQL8a ~]# service mysql.server status
 SUCCESS! MySQL running (10605)

# 命令的参数变少了
[root@C84MySQL8a ~]# ps -ef | grep mysqld
mysql      10605       1  0 11:19 ?        00:00:00 /usr/local/mysql/bin/mysqld
root       10666     990  0 11:21 pts/0    00:00:00 grep --color=auto mysqld

# 都是控制一个进程来的
[root@C84MySQL8a ~]# service mysql.server stop
Shutting down MySQL.. SUCCESS!
[root@C84MySQL8a ~]# systemctl status mysqld8
● mysqld8.service - MySQL Server 8 GPL
   Loaded: loaded (/etc/systemd/system/mysqld8.service; disabled; vendor preset: disabled)
   Active: inactive (dead)

```

配置环境变量

```sh
[root@C84MySQL8a ~]# tail -1 .bash_profile
export PATH=$PATH:/usr/local/mysql/bin

[root@C84MySQL8a ~]# source .bash_profile

# 或者配置全局

[root@C84MySQL8a ~]# echo 'PATH=$PATH:/usr/local/mysql/bin' > /etc/profile.d/mysqld.sh
[root@C84MySQL8a ~]# cat /etc/profile.d/mysqld.sh
PATH=$PATH:/usr/local/mysql/bin

[root@C84MySQL8a ~]# source /etc/profile.d/mysqld.sh


```

mysql_secure_installation进行初期安全设置

```sh
mysql_secure_installation
```





## 源码安装

### 源码编译MySQL8



安装依赖包

```sh

[root@C84MySQL8SRC ~]# yum -y install epel-release

[root@C84MySQL8SRC ~]# dnf -y install gcc gcc-c++ cmake bison bison-devel zlib-devel libcurl-devel wget libarchive-devel boost-devel ncurses-devel gnutls-devel libxml2-devel openssl-devel libevent-devel libaio-devel perl-Data-Dumper tar

Error: Unable to find a match: bison-devel libarchive-devel ncurses-del
# 没有？暂时忽略

[root@C84MySQL8SRC ~]# dnf -y install gcc gcc-c++ cmake bison zlib-devel libcurl-devel wget boost-devel ncurses-devel gnutls-devel libxml2-devel openssl-devel libevent-devel libaio-devel perl-Data-Dumper tar

```

创建用户和数据目录

```sh

[root@C84MySQL8SRC ~]# useradd -r -s /sbin/nologin -d /data/mysql mysql
[root@C84MySQL8SRC ~]# id mysql
uid=995(mysql) gid=992(mysql) groups=992(mysql)

[root@C84MySQL8SRC ~]# mkdir /data/mysql
[root@C84MySQL8SRC ~]# chown mysql:mysql /data/mysql/
[root@C84MySQL8SRC ~]# ll -d /data/mysql/
drwxr-xr-x. 2 mysql mysql 6 Dec 25 12:27 /data/mysql/

[root@C84MySQL8SRC ~]# mkdir /usr/local/mysql

[root@C84MySQL8SRC ~]# mkdir mysql8scr
[root@C84MySQL8SRC ~]# cd mysql8scr/

```

下载源码

```sh
# https://downloads.mysql.com/archives/community/

Generic Linux (Architecture Independent), Compressed TAR Archive
(mysql-8.0.11.tar.gz)
MD5: 38d5a5c1a1eeed1129fec3a999aa5efd

[root@C84MySQL8SRC mysql8scr]# wget https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.11.tar.gz
--2021-12-25 12:29:05--  https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.11.tar.gz
Resolving downloads.mysql.com (downloads.mysql.com)... 137.254.60.14
Connecting to downloads.mysql.com (downloads.mysql.com)|137.254.60.14|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://cdn.mysql.com/archives/mysql-8.0/mysql-8.0.11.tar.gz [following]
--2021-12-25 12:29:06--  https://cdn.mysql.com/archives/mysql-8.0/mysql-8.0.11.tar.gz
Resolving cdn.mysql.com (cdn.mysql.com)... 104.93.8.235
Connecting to cdn.mysql.com (cdn.mysql.com)|104.93.8.235|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 79361578 (76M) [application/x-tar-gz]
Saving to: ‘mysql-8.0.11.tar.gz’

mysql-8.0.11.tar.gz          57%[========================>                   ]  43.66M  10.2MB/s    eta 5s


[root@C84MySQL8SRC mysql8scr]# md5sum mysql-8.0.11.tar.gz
38d5a5c1a1eeed1129fec3a999aa5efd  mysql-8.0.11.tar.gz

[root@C84MySQL8SRC mysql8scr]# tar xzf mysql-8.0.11.tar.gz
[root@C84MySQL8SRC mysql8scr]# ls
mysql-8.0.11  mysql-8.0.11.tar.gz

```

cmake的好处

```
特性：独立于源码编译，保证源码目录不受编译过程的影响，可以进行多次编译
```

编译

```sh
# https://dev.mysql.com/doc/refman/5.7/en/source-configuration-options.html
# https://dev.mysql.com/doc/refman/8.0/en/source-configuration-options.html


[root@C84MySQL8SRC mysql8scr]# cd mysql-8.0.11
[root@C84MySQL8SRC mysql-8.0.11]# pwd
/root/mysql8scr/mysql-8.0.11



[root@C84MySQL8SRC mysql-8.0.11]# cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
> -DMYSQL_DATADIR=/data/mysql/ \
> -DSYSCONFDIR=/etc/ \	# 以下的在MySQL8里和5.7文档都可能没有。。。▲如何输出list？？
> -DMYSQL_USER=mysql \
> -DWITH_INNOBASE_STORAGE_ENGINE=1 \
> -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
> -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
> -DWITH_PARTITION_STORAGE_ENGINE=1 \
> -DWITHOUT_MROONGA_STORAGE_ENGINE=1 \
> -DWITH_DEBUG=0 \
> -DWITH_READLINE=1 \
> -DWITH_SSL=system \
> -DWITH_ZLIB=system \
> -DWITH_LIBWRAP=0 \
> -DEBABLED_LOCAL_INFILE=1 \
> -DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock \
> -DDEFAULT_CHARSET=utf8 \
> -DDEFAULT_COLLATION=utf8_general_ci


# error

CMake Error at plugin/group_replication/libmysqlgcs/rpcgen.cmake:100 (MESSAGE):
  Could not find rpcgen
Call Stack (most recent call first):
  plugin/group_replication/libmysqlgcs/CMakeLists.txt:38 (INCLUDE)


-- Configuring incomplete, errors occurred!
See also "/root/mysql8scr/mysql-8.0.11/CMakeFiles/CMakeOutput.log".
See also "/root/mysql8scr/mysql-8.0.11/CMakeFiles/CMakeError.log".

# 安装rpcsvc
[root@C84MySQL8SRC ~]# wget https://github.com/thkukuk/rpcsvc-proto/releases/download/v1.4.2/rpcsvc-proto-1.4.2.tar.xz

[root@C84MySQL8SRC ~]# tar xf rpcsvc-proto-1.4.2.tar.xz
[root@C84MySQL8SRC ~]# cd rpcsvc-proto-1.4.2
[root@C84MySQL8SRC rpcsvc-proto-1.4.2]# pwd
/root/rpcsvc-proto-1.4.2
[root@C84MySQL8SRC rpcsvc-proto-1.4.2]# ./configure
[root@C84MySQL8SRC rpcsvc-proto-1.4.2]# make
[root@C84MySQL8SRC rpcsvc-proto-1.4.2]# make install
[root@C84MySQL8SRC rpcsvc-proto-1.4.2]# locate rpcgen | grep bin
/usr/bin/event_rpcgen.py
/usr/bin/rpcgen


[root@C84MySQL8SRC mysql-8.0.11]# pwd
/root/mysql8scr/mysql-8.0.11

[root@C84MySQL8SRC mysql-8.0.11]# cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/data/mysql/ -DSYSCONFDIR=/etc/ -DMYSQL_USER=mysql -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITHOUT_MROONGA_STORAGE_ENGINE=1 -DWITH_DEBUG=0 -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_LIBWRAP=0 -DEBABLED_LOCAL_INFILE=1 -DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci

CMake Error at plugin/group_replication/libmysqlgcs/rpcgen.cmake:104 (MESSAGE):
  Could not find rpc/rpc.h in /usr/include or /usr/include/tirpc

[root@C84MySQL8SRC mysql-8.0.11]# rpm -ql glibc-headers | grep rpc/
/usr/include/rpc/netdb.h

# https://github.com/lattera/glibc
# read-only

# 怎么复制git上的某个具体的md文件？curl？
# https://github.com/lattera/glibc/blob/master/sunrpc/rpc/rpc.h

[root@C84MySQL8SRC mysql-8.0.11]# ls /usr/include/rpc/rpc.h
/usr/include/rpc/rpc.h

[root@C84MySQL8SRC mysql-8.0.11]# cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/data/mysql/ -DSYSCONFDIR=/etc/ -DMYSQL_USER=mysql -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITHOUT_MROONGA_STORAGE_ENGINE=1 -DWITH_DEBUG=0 -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_LIBWRAP=0 -DEBABLED_LOCAL_INFILE=1 -DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci

-- Configuring done
-- Generating done
-- Build files have been written to: /root/mysql8scr/mysql-8.0.11

# make（不是说用cmake吗？怎么不是？▲▲cmake是实现configure的功能）

[root@C84MySQL8SRC mysql-8.0.11]# make


[ 10%] Building CXX object extra/icu/source/i18n/CMakeFiles/icui18n.dir/casetrn.cpp.o
[ 10%] Building CXX object extra/icu/source/i18n/CMakeFiles/icui18n.dir/cecal.cpp.o
[ 10%] Building CXX object extra/icu/source/i18n/CMakeFiles/icui18n.dir/chnsecal.cpp.o


[ 80%] Building C object plugin/group_replication/libmysqlgcs/CMakeFiles/mysqlgcs.dir/src/bindings/xcom/xcom/pax_msg.c.o


/usr/include/rpc/rpc.h:38:10: fatal error: rpc/types.h: No such file or directory
 #include <rpc/types.h>/* some typedefs */
          ^~~~~~~~~~~~~
compilation terminated.


[root@C84MySQL8SRC ~]# git clone https://github.com/lattera/glibc.git

[root@C84MySQL8SRC ~]# cp glibc/sunrpc/rpc/* /usr/include/rpc/
cp: overwrite '/usr/include/rpc/netdb.h'?
cp: overwrite '/usr/include/rpc/rpc.h'?


[root@C84MySQL8SRC ~]# ls  /usr/include/rpc/
auth_des.h  auth_unix.h  des_crypt.h  netdb.h      pmap_prot.h  rpc_des.h  rpc_msg.h   svc.h    xdr.h
auth.h      clnt.h       key_prot.h   pmap_clnt.h  pmap_rmt.h   rpc.h      svc_auth.h  types.h

# make继续

[root@C84MySQL8SRC mysql-8.0.11]# make

[root@C84MySQL8SRC mysql-8.0.11]# make install


[root@C84MySQL8SRC ~]# ls /usr/local/mysql
bin  docs  include  lib  LICENSE  LICENSE-test  man  mysql-test  README  README-test  share  support-files
[root@C84MySQL8SRC ~]# ls /data/mysql/
[root@C84MySQL8SRC ~]#


```

配置环境变量

```sh

[root@C84MySQL8SRC ~]# echo 'PATH=/usr/local/mysql/bin:$PATH' > /etc/profile.d/mysqld.sh
[root@C84MySQL8SRC ~]# cat /etc/profile.d/mysqld.sh
PATH=/usr/local/mysql/bin:$PATH
[root@C84MySQL8SRC ~]# source /etc/profile.d/mysqld.sh

```

初始化，生成数据库文件和root密码

```sh

[root@C84MySQL8SRC ~]# mysqld --initialize --user=mysql --datadir=/data/mysql
2021-12-25T05:28:31.197657Z 0 [System] [MY-013169] [Server] /usr/local/mysql/bin/mysqld (mysqld 8.0.11) initializing of server in progress as process 42606

2021-12-25T05:28:33.698092Z 5 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: hOpciK9e-h6x
2021-12-25T05:28:35.716719Z 0 [System] [MY-013170] [Server] /usr/local/mysql/bin/mysqld (mysqld 8.0.11) initializing of server has completed
[root@C84MySQL8SRC ~]#

# 初始化后自动关闭了
[root@C84MySQL8SRC ~]# ls /data/mysql/
auto.cnf    client-cert.pem  ibdata1      mysql               private_key.pem  server-key.pem  undo_002
ca-key.pem  client-key.pem   ib_logfile0  mysql.ibd           public_key.pem   sys
ca.pem      ib_buffer_pool   ib_logfile1  performance_schema  server-cert.pem  undo_001
[root@C84MySQL8SRC ~]# ps -ef | grep mysql
root       42654    1032  0 14:29 pts/0    00:00:00 grep --color=auto mysql
[root@C84MySQL8SRC ~]# ss -ntlp | grep mysql

```

配置文件（MySQL8不提供模板文件。。）

```sh

[root@C84MySQL8SRC ~]# cat /etc/my.cnf
[mysqld]
datadir = /data/mysql/

```

启动脚本

```sh
# init

[root@C84MySQL8SRC ~]# cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld

[root@C84MySQL8SRC ~]# service mysqld status
 ERROR! MySQL is not running


[root@C84MySQL8SRC ~]# cat /etc/systemd/system/mysqld.service
[Unit]
Description=MySQL Server 8 GPL
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target
After=syslog.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql
Type=notify
TimeoutSec=0
PermissionsStartOnly=true
# ExecStartPre=/usr/bin/mysqld_pre_systemd
ExecStart=/usr/local/mysql/bin/mysqld $MYSQLD_OPTS
# EnvironmentFile=-/etc/sysconfig/mysql
LimitNOFILE = 10000
Restart=on-failure
RestartPreventExitStatus=1
Environment=MYSQLD_PARENT_PID=1
PrivateTmp=false

[root@C84MySQL8SRC ~]# systemctl daemon-reload
[root@C84MySQL8SRC ~]# systemctl status mysqld
● mysqld.service - MySQL Server 8 GPL
   Loaded: loaded (/etc/systemd/system/mysqld.service; disabled; vendor preset: disabled)
   Active: inactive (dead)


[root@C84MySQL8SRC ~]# service mysqld start
Starting MySQL.Logging to '/data/mysql/C84MySQL8SRC.err'.
 SUCCESS!
[root@C84MySQL8SRC ~]# systemctl status mysqld
● mysqld.service - MySQL Server 8 GPL
   Loaded: loaded (/etc/systemd/system/mysqld.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
     Docs: man:mysqld(8)
           http://dev.mysql.com/doc/refman/en/using-systemd.html
[root@C84MySQL8SRC ~]# service mysqld status
 SUCCESS! MySQL running (42849)

[root@C84MySQL8SRC ~]# cat /data/mysql/mysql.sock.lock
42849

# 这里的为何不同步了？？

[root@C84MySQL8SRC ~]# service mysqld stop
Shutting down MySQL.. SUCCESS!
[root@C84MySQL8SRC ~]# systemctl start mysqld
[root@C84MySQL8SRC ~]# service mysqld status
 SUCCESS! MySQL running (42943)	# 反过来却可以？
 
[root@C84MySQL8SRC ~]# systemctl status mysqld
● mysqld.service - MySQL Server 8 GPL
   Loaded: loaded (/etc/systemd/system/mysqld.service; disabled; vendor preset: disabled)
   Active: inactive (dead)

 
[root@C84MySQL8SRC ~]# service mysqld start
Starting MySQL. SUCCESS!
[root@C84MySQL8SRC ~]# systemctl status mysqld
● mysqld.service - MySQL Server 8 GPL
   Loaded: loaded (/etc/systemd/system/mysqld.service; disabled; vendor preset: disabled)
   Active: inactive (dead)




```

修改root密码

```sh

[root@C84MySQL8SRC ~]# mysqladmin -uroot -p'hOpciK9e-h6x' password 'MySQL123!'
mysqladmin: [Warning] Using a password on the command line interface can be insecure.
Warning: Since password will be sent to server in plain text, use ssl connection to ensure password safety.


[root@C84MySQL8SRC ~]# mysql -uroot -p'MySQL123!'
mysql> status
--------------
mysql  Ver 8.0.11 for Linux on x86_64 (Source distribution)

Connection id:          9
Current user:           root@localhost
UNIX socket:            /data/mysql/mysql.sock

```



安全初始化脚本

```sh

[root@C84MySQL8SRC ~]# mysql_secure_installation


```



## MySQL容器



```sh
[root@C84MySQLC ~]# cat /etc/redhat-release
CentOS Linux release 8.4.2105
[root@C84MySQLC ~]# uname -a
Linux C84MySQLC 4.18.0-305.3.1.el8.x86_64 #1 SMP Tue Jun 1 16:14:33 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux

# CentOS8无提供docker？？
[root@C84MySQLC ~]# yum -y install epel-release

[root@C84MySQLC ~]# yum search docker
Last metadata expiration check: 0:01:42 ago on Sat 25 Dec 2021 02:45:49 PM JST.
======================================== Name & Summary Matched: docker ========================================
pcp-pmda-docker.x86_64 : Performance Co-Pilot (PCP) metrics from the Docker daemon
podman-docker.noarch : Emulate Docker CLI using podman
python-docker-tests.noarch : Unit tests and integration tests for python-docker
python2-dockerpty.noarch : Python library to use the pseudo-tty of a docker container
python3-docker.noarch : A Python library for the Docker Engine API
python3-dockerpty.noarch : Python library to use the pseudo-tty of a docker container
standard-test-roles-inventory-docker.noarch : Inventory provisioner for using docker
=========================================== Summary Matched: docker ============================================
podman-compose.noarch : Run docker-compose.yml using podman
reg.x86_64 : Docker registry v2 command line client



[root@C84MySQLC ~]# yum -y install docker	# 仅仅是单纯地安装了docker命令

[root@C84MySQLC ~]# rpm -qa | grep docker
podman-docker-3.3.1-9.module_el8.5.0+988+b1f0b741.noarch


[root@C84MySQLC ~]# rpm -ql podman-docker
/usr/bin/docker
/usr/lib/tmpfiles.d/podman-docker.conf


[root@C84MySQLC ~]# rpm -qa | grep podman
podman-catatonit-3.3.1-9.module_el8.5.0+988+b1f0b741.x86_64
podman-docker-3.3.1-9.module_el8.5.0+988+b1f0b741.noarch
podman-3.3.1-9.module_el8.5.0+988+b1f0b741.x86_64

[root@C84MySQLC ~]# rpm -qi podman	# 代替docker的容器

Description :
podman (Pod Manager) is a fully featured container engine that is a simple
daemonless tool.  podman provides a Docker-CLI comparable command line that
eases the transition from other container engines and allows the management of
pods, containers and images.  Simply put: alias docker=podman.
Most podman commands can be run as a regular user, without requiring
additional privileges.


[root@C84MySQLC ~]# docker run --name mysql -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 mysql:5.7.30
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
? Please select an image:
  ▸ registry.fedoraproject.org/mysql:5.7.30
    registry.access.redhat.com/mysql:5.7.30
    registry.centos.org/mysql:5.7.30
    docker.io/library/mysql:5.7.30


✔ registry.fedoraproject.org/mysql:5.7.30
Trying to pull registry.fedoraproject.org/mysql:5.7.30...
Error: initializing source docker://registry.fedoraproject.org/mysql:5.7.30: reading manifest 5.7.30 in registry.fedoraproject.org/mysql: manifest unknown: manifest unknown

[root@C84MySQLC ~]# docker run --name mysql -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 mysql:5.7.30
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
✔ registry.access.redhat.com/mysql:5.7.30
Trying to pull registry.access.redhat.com/mysql:5.7.30...
Error: initializing source docker://registry.access.redhat.com/mysql:5.7.30: reading manifest 5.7.30 in registry.access.redhat.com/mysql: name unknown: Repo not found
[root@C84MySQLC ~]# docker run --name mysql -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 mysql:5.7.30
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
✔ registry.centos.org/mysql:5.7.30
Trying to pull registry.centos.org/mysql:5.7.30...
Error: initializing source docker://registry.centos.org/mysql:5.7.30: reading manifest 5.7.30 in registry.centos.org/mysql: manifest unknown: manifest unknown
[root@C84MySQLC ~]# docker run --name mysql -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 mysql:5.7.30
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
✔ docker.io/library/mysql:5.7.30	# 还是只有docker的仓库可以用？？？▲
Trying to pull docker.io/library/mysql:5.7.30...
Getting image source signatures
Copying blob b905d1797e97 done
Copying blob c2344adc4858 done

[root@C84MySQLC ~]# docker ps
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
CONTAINER ID  IMAGE                           COMMAND     CREATED         STATUS             PORTS                   NAMES
d9ea7b9682b2  docker.io/library/mysql:5.7.30  mysqld      29 seconds ago  Up 29 seconds ago  0.0.0.0:3306->3306/tcp  mysql


[root@C84MySQLC ~]# yum -y install mysql

[root@C84MySQLC ~]# mysql -uroot -p123456 -hlocalhost	# 用localhost的话会用socket通信
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock' (2)

[root@C84MySQLC ~]# mysql -uroot -p123456 -h127.0.0.1	# 用IP才能连接到容器
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.30 MySQL Community Server (GPL)

mysql> status
--------------
mysql  Ver 8.0.26 for Linux on x86_64 (Source distribution)

Connection id:          2
Current database:
Current user:           root@10.88.0.1
SSL:                    Cipher in use is ECDHE-RSA-AES128-GCM-SHA256
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         5.7.30 MySQL Community Server (GPL)
Protocol version:       10
Connection:             127.0.0.1 via TCP/IP
Server characterset:    latin1
Db     characterset:    latin1
Client characterset:    latin1
Conn.  characterset:    latin1
TCP port:               3306
Binary data as:         Hexadecimal
Uptime:                 1 min 43 sec

Threads: 1  Questions: 5  Slow queries: 0  Opens: 105  Flush tables: 1  Open tables: 98  Queries per second avg: 0.048
--------------


[root@C84MySQLC ~]# docker stop mysql
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
mysql
[root@C84MySQLC ~]# docker ps
Emulate Docker CLI using podman. Create /etc/containers/nodocker to quiet msg.
CONTAINER ID  IMAGE       COMMAND     CREATED     STATUS      PORTS       NAMES
[root@C84MySQLC ~]#

```







## MySQL多实例

### 方案

在一台服务器上同时开启多个不同的实例（用不同的配置文件，数据文件，和端口。也可以用不同的程序，不同的版本）

多实例好坏

- 坏处
  - 服务器跪则 全部的服务都贵
  - 高并发会相互抢占资源造成性能问题
  - 管理复杂
- 好处
  - 充分用服务器资源
  - 互为主从等架构

多实例实现方案

- 单一配置文件，单一启动程序
  - 高耦合
- 多个配置文件，多个启动程序，多脚本，不同版的还可有不同的程序（建议）



### CentOS8安装MariaDB多实例（init）

采用方法

- 程序x1
- 配置文件（启动脚本）xN
- 数据文件xN



实验环境

```sh
SELinux # on
firewalld	# on
ntp # 

```

安装MariaDB

```sh
[root@C84Maria10Multi ~]# dnf -y install mariadb-server

[root@C84Maria10Multi ~]# rpm -qa | grep maria
mariadb-connector-c-config-3.1.11-2.el8_3.noarch
mariadb-gssapi-server-10.3.28-1.module_el8.3.0+757+d382997d.x86_64
mariadb-common-10.3.28-1.module_el8.3.0+757+d382997d.x86_64
mariadb-errmsg-10.3.28-1.module_el8.3.0+757+d382997d.x86_64
mariadb-backup-10.3.28-1.module_el8.3.0+757+d382997d.x86_64
mariadb-server-utils-10.3.28-1.module_el8.3.0+757+d382997d.x86_64
mariadb-10.3.28-1.module_el8.3.0+757+d382997d.x86_64
mariadb-connector-c-3.1.11-2.el8_3.x86_64
mariadb-server-10.3.28-1.module_el8.3.0+757+d382997d.x86_64

```

创建数据目录

```sh


[root@C84Maria10Multi ~]# mkdir -pv /data/mysql3306{1..3}/{data,etc,socket,log,bin,pid}


[root@C84Maria10Multi ~]# chown -R mysql:mysql /data/mysql3306{1..3}/{data,etc,socket,log,bin,pid}

[root@C84Maria10Multi ~]# tree -d /data/
/data/
├── mysql33061
│   ├── bin
│   ├── data
│   ├── etc
│   ├── log
│   ├── pid
│   └── socket
├── mysql33062
│   ├── bin
│   ├── data
│   ├── etc
│   ├── log
│   ├── pid
│   └── socket
└── mysql33063
    ├── bin
    ├── data
    ├── etc
    ├── log
    ├── pid
    └── socket

21 directories


```

创建数据库文件

```sh

[root@C84Maria10Multi ~]# mysql_install_db --user=mysql --datadir=/data/mysql33061/data
Installing MariaDB/MySQL system tables in '/data/mysql33061/data' ...
OK

To start mysqld at boot time you have to copy
support-files/mysql.server to the right place for your system


PLEASE REMEMBER TO SET A PASSWORD FOR THE MariaDB root USER !
To do so, start the server, then issue the following commands:

'/usr/bin/mysqladmin' -u root password 'new-password'
'/usr/bin/mysqladmin' -u root -h C84Maria10Multi password 'new-password'

Alternatively you can run:
'/usr/bin/mysql_secure_installation'

which will also give you the option of removing the test
databases and anonymous user created by default.  This is
strongly recommended for production servers.

See the MariaDB Knowledgebase at http://mariadb.com/kb or the
MySQL manual for more instructions.

You can start the MariaDB daemon with:
cd '/usr' ; /usr/bin/mysqld_safe --datadir='/data/mysql33061/data'

You can test the MariaDB daemon with mysql-test-run.pl
cd '/usr/mysql-test' ; perl mysql-test-run.pl

Please report any problems at http://mariadb.org/jira

The latest information about MariaDB is available at http://mariadb.org/.
You can find additional information about the MySQL part at:
http://dev.mysql.com
Consider joining MariaDB's strong and vibrant community:
https://mariadb.org/get-involved/


[root@C84Maria10Multi ~]# mysqld_safe --defaults-file=/data/mysql33061/etc/my.cnf &
[1] 12727
[root@C84Maria10Multi ~]# 211225 15:50:08 mysqld_safe Logging to '/data/mysql33061/log/mariadb.log'.
211225 15:50:08 mysqld_safe Starting mysqld daemon with databases from /data/mysql33061/data

[root@C84Maria10Multi ~]# mysql -S /data/mysql33061/socket/mariadb.sock
MariaDB [(none)]> status
--------------
mysql  Ver 15.1 Distrib 10.3.28-MariaDB, for Linux (x86_64) using readline 5.1

Current user:           root@localhost
Server:                 MariaDB
Server version:         10.3.28-MariaDB MariaDB Server
Protocol version:       10
Connection:             Localhost via UNIX socket

# 修改所有实例的密码
MariaDB [(none)]> alter user root@'localhost' IDENTIFIED BY 'MariaDB123!';
Query OK, 0 rows affected (0.000 sec)


[root@C84Maria10Multi ~]# mysqladmin -uroot -p'MariaDB123!' -S /data/mysql33061/socket/mariadb.sock shutdown
[1]+  Done                    mysqld_safe --defaults-file=/data/mysql33061/etc/my.cnf
[root@C84Maria10Multi ~]#



[root@C84Maria10Multi ~]# mysql_install_db --user=mysql --datadir=/data/mysql33062/data

[root@C84Maria10Multi ~]# mysql_install_db --user=mysql --datadir=/data/mysql33063/data


[root@C84Maria10Multi ~]# mysqld_safe --defaults-file=/data/mysql33062/etc/my.cnf &

[root@C84Maria10Multi ~]# mysql -S /data/mysql33062/socket/mariadb.sock

MariaDB [(none)]> alter user root@'localhost' IDENTIFIED BY 'MariaDB123!';
Query OK, 0 rows affected (0.000 sec)


[root@C84Maria10Multi ~]# mysqladmin -uroot -p'MariaDB123!' -S /data/mysql33062/socket/mariadb.sock shutdown
[1]+  Done                    mysqld_safe --defaults-file=/data/mysql33062/etc/my.cnf

[root@C84Maria10Multi ~]# mysqld_safe --defaults-file=/data/mysql33063/etc/my.cnf &


[root@C84Maria10Multi ~]# mysqld_safe --defaults-file=/data/mysql33063/etc/my.cnf &

MariaDB [(none)]> alter user root@'localhost' IDENTIFIED BY 'MariaDB123!';
Query OK, 0 rows affected (0.000 sec)

[root@C84Maria10Multi ~]# mysqladmin -uroot -p'MariaDB123!' -S /data/mysql33063/socket/mariadb.sock shutdown


```

生成配置文件

```sh

[root@C84Maria10Multi ~]# cat /data/mysql33061/etc/my.cnf
[mysqld]
port=33061
datadir=/data/mysql33061/data
socket=/data/mysql33061/socket/mariadb.sock
log-error=/data/mysql33061/log/mariadb.log
pid-file=/data/mysql33061/pid/mariadb.pid

[root@C84Maria10Multi ~]#


[root@C84Maria10Multi ~]# sed 's/33061/33062/' /data/mysql33061/etc/my.cnf > /data/mysql33062/etc/my.cnf
[root@C84Maria10Multi ~]# sed 's/33061/33063/' /data/mysql33061/etc/my.cnf > /data/mysql33063/etc/my.cnf
[root@C84Maria10Multi ~]# cat /data/mysql33062/etc/my.cnf
[mysqld]
port=33062
datadir=/data/mysql33062/data
socket=/data/mysql33062/socket/mariadb.sock
log-error=/data/mysql33062/log/mariadb.log
pid-file=/data/mysql33062/pid/mariadb.pid

[root@C84Maria10Multi ~]# cat /data/mysql33063/etc/my.cnf
[mysqld]
port=33063
datadir=/data/mysql33063/data
socket=/data/mysql33063/socket/mariadb.sock
log-error=/data/mysql33063/log/mariadb.log
pid-file=/data/mysql33063/pid/mariadb.pid

```



创建启动脚本

```sh

[root@C84Maria10Multi ~]# cat /data/mysql33061/bin/mariadbd
#!/bin/bash
################
# Auther: Chuhai Li
# Description : MariaDB multi instances control script
# ver
#   v1: New
#   V2: Change restart function code
#   V3: Add status function
################

# define variables used in script (necessary even though set in my.cnf)
port=33061
mysql_user="root"
mysql_pw="MariaDB123!"
cmd_path="/usr/bin"
mysql_basedir="/data"
mysql_sock="${mysql_basedir}/mysql${port}/socket/mariadb.sock"
mysql_pid="${mysql_basedir}/mysql${port}/pid/mariadb.pid"

#echo $port
#echo $mysql_user
#echo $mysql_pw
#echo $cmd_path
#echo $mysql_basedir
#echo $mysql_sock
#echo ${mysql_basedir}/mysql${port}/etc/my.cnf

# function
mariadb_start() {
  if [ ! -e "${mysql_sock}" ] ; then
    printf "Starting MariaDB...\n"
    # start don't need pw
    ${cmd_path}/mysqld_safe --defaults-file=${mysql_basedir}/mysql${port}/etc/my.cnf &> /dev/null &
  else
    printf "Mariadb is running... do nothing.\n"
  fi
}

mariadb_stop() {
  if [ ! -e "${mysql_sock}" ] ; then
    printf "Mariadb stopped.\n"
    exit
  else
    printf "Stopping Mariadb...\n"
    ${cmd_path}/mysqladmin -u${mysql_user} -p${mysql_pw} -S ${mysql_sock} shutdown
  fi
}

mariadb_restart() {
  printf "Restarting MariaDB...\n"
  if [ -e "${mysql_sock}" ] ; then
    mariadb_stop
  else
    printf "Mariadb already stop, now starting...\n"
  fi
  sleep 2
  mariadb_start
}

mariadb_status() {
  if [ ! -e "${mysql_pid}" ] ; then
    printf "Mariadb(${port}) stopped.\n"
  else
    mysql_pid=$(cat ${mysql_pid})
    mysql_ppid=$(ps -p ${mysql_pid} -o ppid=)
    printf "Mariadb(${port}) is running.\n Dir: ${mysql_basedir}/mysql${port} \n Start Script pid: ${mysql_ppid}; \n DB instance pid: ${mysql_pid}]\n"
  fi
}

case $1 in
start)
  mariadb_start
  ;;
stop)
  mariadb_stop
  ;;
restart)
  mariadb_restart
  ;;
status)
  mariadb_status
  ;;
*)
  printf "Usage: ${mysql_basedir}/mysql${port}/bin/mariadbd {start|stop|restart}\n"
esac


[root@C84Maria10Multi ~]# chmod +x /data/mysql33061/bin/mariadbd

# 复制创建其他实例的控制脚本


[root@C84Maria10Multi ~]# sed 's/33061/33062/' /data/mysql33061/bin/mariadbd > /data/mysql33062/bin/mariadbd
[root@C84Maria10Multi ~]# sed 's/33061/33063/' /data/mysql33061/bin/mariadbd > /data/mysql33063/bin/mariadbd

[root@C84Maria10Multi ~]# chmod +x /data/mysql33062/bin/mariadbd
[root@C84Maria10Multi ~]# chmod +x /data/mysql33063/bin/mariadbd

# 启动服务，测试

[root@C84Maria10Multi ~]# /data/mysql33063/bin/mariadbd start
Starting MariaDB...
[root@C84Maria10Multi ~]# /data/mysql33062/bin/mariadbd start
Starting MariaDB...
[root@C84Maria10Multi ~]# /data/mysql33061/bin/mariadbd start
Mariadb is running... do nothing.
[root@C84Maria10Multi ~]# ss -ntlp
State           Recv-Q           Send-Q                     Local Address:Port                      Peer Address:Port          Process
LISTEN          0                128                              0.0.0.0:22                             0.0.0.0:*              users:(("sshd",pid=758,fd=5))
LISTEN          0                128                                 [::]:22                                [::]:*              users:(("sshd",pid=758,fd=7))
LISTEN          0                80                                     *:33061                                *:*              users:(("mysqld",pid=17049,fd=23))
LISTEN          0                80                                     *:33062                                *:*              users:(("mysqld",pid=17913,fd=23))
LISTEN          0                80                                     *:33063                                *:*              users:(("mysqld",pid=17782,fd=23))



[root@C84Maria10Multi ~]# cat ~/.my.cnf
[mysql]
user=root
password=MariaDB123!


[root@C84Maria10Multi ~]# mysql -S /data/mysql33062/socket/mariadb.sock -e "select user,host from mysql.user"
+------+-----------------+
| user | host            |
+------+-----------------+
| root | 127.0.0.1       |
| root | ::1             |
|      | c84maria10multi |
| root | c84maria10multi |
|      | localhost       |
| root | localhost       |
+------+-----------------+
[root@C84Maria10Multi ~]# mysql -S /data/mysql33063/socket/mariadb.sock -e "select user,host from mysql.user"
+------+-----------------+
| user | host            |
+------+-----------------+
| root | 127.0.0.1       |
| root | ::1             |
|      | c84maria10multi |
| root | c84maria10multi |
|      | localhost       |
| root | localhost       |
+------+-----------------+
[root@C84Maria10Multi ~]# mysql -S /data/mysql33061/socket/mariadb.sock -e "select user,host from mysql.user"
+------+-----------------+
| user | host            |
+------+-----------------+
| root | 127.0.0.1       |
| root | ::1             |
|      | c84maria10multi |
| root | c84maria10multi |
|      | localhost       |
| root | localhost       |
+------+-----------------+


```

创建网络登录用户

```sh

[root@C84Maria10Multi ~]# cat createroot.sql
CREATE USER root@'192.168.%.%' IDENTIFIED BY 'MariaDB123!';

[root@C84Maria10Multi ~]# mysql -S /data/mysql33063/socket/mariadb.sock < createroot.sql
[root@C84Maria10Multi ~]# mysql -S /data/mysql33062/socket/mariadb.sock < createroot.sql
[root@C84Maria10Multi ~]# mysql -S /data/mysql33061/socket/mariadb.sock < createroot.sql


[root@C84Maria10Multi ~]# mysql -uroot -p"MariaDB123!" -h 127.0.0.1 -P 33061 -e "select user,host from mysql.user where host='127.0.0.1';"
+------+-----------+
| user | host      |
+------+-----------+
| root | 127.0.0.1 |
+------+-----------+
[root@C84Maria10Multi ~]# mysql -uroot -p"MariaDB123!" -h 127.0.0.1 -P 33062 -e "select user,host from mysql.user where host='127.0.0.1';"
+------+-----------+
| user | host      |
+------+-----------+
| root | 127.0.0.1 |
+------+-----------+
[root@C84Maria10Multi ~]# mysql -uroot -p"MariaDB123!" -h 127.0.0.1 -P 33063 -e "select user,host from mysql.user where host='127.0.0.1';"
+------+-----------+
| user | host      |
+------+-----------+
| root | 127.0.0.1 |
+------+-----------+


# 为何拒绝登录？名字解析的问题？
[root@C84Maria10Multi ~]# mysql -uroot -p"MariaDB123!" -h 192.168.50.19 -P 33063 -e "select user,host from mysql.user where host='127.0.0.1';"
ERROR 1045 (28000): Access denied for user 'root'@'C84Maria10Multi' (using password: YES)



MariaDB [(none)]> CREATE USER root@'C84Maria10Multi' IDENTIFIED BY 'MariaDB123!';
ERROR 1396 (HY000): Operation CREATE USER failed for 'root'@'c84maria10multi'

MariaDB [(none)]> select user,host from mysql.user;
+------+-----------------+
| user | host            |
+------+-----------------+
| root | 127.0.0.1       |
| root | 192.168.%.%     |
| root | ::1             |
|      | c84maria10multi |
| root | c84maria10multi |	# 已经存在，难道是这个的密码不对？
|      | localhost       |
| root | localhost       |
+------+-----------------+
7 rows in set (0.001 sec)


MariaDB [(none)]> alter user root@'c84maria10multi' IDENTIFIED BY 'MariaDB123!';
Query OK, 0 rows affected (0.000 sec)

# 果然是密码不对的问题
[root@C84Maria10Multi ~]# mysql -uroot -p"MariaDB123!" -h 192.168.50.19 -P 33063 -e "select user,host from mysql.user where host='127.0.0.1';"
+------+-----------+
| user | host      |
+------+-----------+
| root | 127.0.0.1 |
+------+-----------+




```

开机启动（init），

```sh
[root@C84Maria10Multi ~]# tail -1 /etc/rc.d/rc.local
for i in {1..3};do /data/mysql3306${i}/bin/mariadbd start; done
[root@C84Maria10Multi ~]# chmod +x /etc/rc.d/rc.local

```

创建统一控制服务脚本

```sh

[root@C84Maria10Multi ~]# cat /etc/init.d/mariadb.multi
#!/bin/bash

case $1 in
start)
  for i in {1..3};do /data/mysql3306${i}/bin/mariadbd start; done
  ;;
stop)
  for i in {1..3};do /data/mysql3306${i}/bin/mariadbd stop; done
  ;;
status)
  for i in {1..3};do /data/mysql3306${i}/bin/mariadbd status; done
  ;;
restart)
  for i in {1..3};do /data/mysql3306${i}/bin/mariadbd restart; done
  ;;
*)
  printf "Usage: $0 {start|stop|restart|status}\n"
esac

[root@C84Maria10Multi ~]# chmod +x /etc/init.d/mariadb.multi


[root@C84Maria10Multi ~]# service mariadb.multi
Usage: /etc/init.d/mariadb.multi {start|stop|restart|status}

[root@C84Maria10Multi ~]# service mariadb.multi status
Mariadb(33061) is running.
 Dir: /data/mysql33061
 Start Script pid:   16951;
 DB instance pid: 17049]
Mariadb(33062) is running.
 Dir: /data/mysql33062
 Start Script pid:   17815;
 DB instance pid: 17913]
Mariadb(33063) is running.
 Dir: /data/mysql33063
 Start Script pid:   17684;
 DB instance pid: 17782]

[root@C84Maria10Multi ~]# service mariadb.multi restart
Restarting MariaDB...
Stopping Mariadb...
Starting MariaDB...
Restarting MariaDB...
Stopping Mariadb...
Starting MariaDB...
Restarting MariaDB...
Stopping Mariadb...
Starting MariaDB...


[root@C84Maria10Multi ~]# service mariadb.multi stop
Stopping Mariadb...
Stopping Mariadb...
Stopping Mariadb...
[root@C84Maria10Multi ~]# service mariadb.multi status
Mariadb(33061) stopped.
Mariadb(33062) stopped.
Mariadb(33063) stopped.
[root@C84Maria10Multi ~]# service mariadb.multi start
Starting MariaDB...
Starting MariaDB...
Starting MariaDB...
[root@C84Maria10Multi ~]# service mariadb.multi status
Mariadb(33061) is running.
 Dir: /data/mysql33061
 Start Script pid:   18635;
 DB instance pid: 18928]
Mariadb(33062) is running.
 Dir: /data/mysql33062
 Start Script pid:   18637;
 DB instance pid: 18935]
Mariadb(33063) is running.
 Dir: /data/mysql33063
 Start Script pid:   18643;
 DB instance pid: 18931]


```





# ▲MySQL自动安装脚本

在线or离线

在线需要联网，配置源仓库，离线需要事先上传安装包等做法



# MySQL组成和常用工具



## MySQL客户端服务器

所有，client和server

```sh

[root@C84MySQL8 ~]# rpm -ql $(rpm -qa | grep mysql) | grep bin | grep -v -e lib64 -e share
/usr/bin/mysql
/usr/bin/mysql_config_editor
/usr/bin/mysql_migrate_keyring
/usr/bin/mysqladmin
/usr/bin/mysqlbinlog
/usr/bin/mysqlcheck
/usr/bin/mysqldump
/usr/bin/mysqlimport
/usr/bin/mysqlpump
/usr/bin/mysqlshow
/usr/bin/mysqlslap
/usr/bin/ibd2sdi
/usr/bin/innochecksum
/usr/bin/lz4_decompress
/usr/bin/my_print_defaults
/usr/bin/myisam_ftdump
/usr/bin/myisamchk
/usr/bin/myisamlog
/usr/bin/myisampack
/usr/bin/mysql_secure_installation
/usr/bin/mysql_ssl_rsa_setup
/usr/bin/mysql_tzinfo_to_sql
/usr/bin/mysql_upgrade
/usr/bin/mysqld_pre_systemd
/usr/bin/mysqldumpslow
/usr/bin/perror
/usr/bin/zlib_decompress
/usr/sbin/mysqld

```

### 客户端

```sh

[root@C84MySQL8 ~]# rpm -ql mysql-community-client | grep bin
/usr/bin/mysql	# CLI工具，交互式，非交互式
/usr/bin/mysql_config_editor
/usr/bin/mysql_migrate_keyring
/usr/bin/mysqladmin	# 管理mysqld
/usr/bin/mysqlbinlog
/usr/bin/mysqlcheck
/usr/bin/mysqldump	# 备份，mysql协议，备份成SQL语句的文本文件
/usr/bin/mysqlimport	# 导入
/usr/bin/mysqlpump
/usr/bin/mysqlshow
/usr/bin/mysqlslap

# 一下为MyIASAM，MySQL8由server包提供
myisamchk	# 检查myisam表
myiasmpack	# 打包myisam表，只读

```

### 服务器

```sh

[root@C84MySQL8 ~]# rpm -ql mysql-community-server | grep bin | grep -v -e lib64
/usr/bin/ibd2sdi
/usr/bin/innochecksum
/usr/bin/lz4_decompress
/usr/bin/my_print_defaults
/usr/bin/myisam_ftdump
/usr/bin/myisamchk
/usr/bin/myisamlog
/usr/bin/myisampack
/usr/bin/mysql_secure_installation
/usr/bin/mysql_ssl_rsa_setup
/usr/bin/mysql_tzinfo_to_sql
/usr/bin/mysql_upgrade
/usr/bin/mysqld_pre_systemd
/usr/bin/mysqldumpslow
/usr/bin/perror
/usr/bin/zlib_decompress
/usr/sbin/mysqld	# 服务器程序

mysqld_safe		# 安全模式启动，rpm安装没有，哪个包提供？
mysqld_multi	# 内置多实例功能，rpm安装没有，哪个包提供？▲▲

```

## 用户账号

两部分组成

```
'username'@'host'
'username'@'ip'
'username'@'subnet'
```

host限制用户可以在哪些主机上登录，无指定时默认localhost？还是任意？

（这里的host，是许可从哪里登录？还是许可通过哪个网卡登录？） 

```
# 通配符
%	匹配任意长度的任意字符，相当于shell终端的*，例如：
	192.168.0.0/255.255.0.0  -  172.168.%.%
	0.0.0.0  -  %
	
_	匹配任意的单个字符，想当于shell终端?
```

当一个用户出现多个登录范围，且有冲突的时候，比如指定单个主机，再指定一个子网，主机包涵在子网内，那么是按顺序来还是按范围来，还是按书写格式来？

```sh
# 实验

CREATE USER user01 IDENTIFIED BY 'MySQL123!';
CREATE USER user01@'%' IDENTIFIED BY 'MySQL123!';
CREATE USER user01@'192.168.%.%' IDENTIFIED BY 'MySQL123!';

# 创建user
mysql> CREATE USER user01 IDENTIFIED BY 'MySQL123!';
Query OK, 0 rows affected (0.79 sec)

mysql> CREATE USER user01@'%' IDENTIFIED BY 'MySQL123!';
ERROR 1396 (HY000): Operation CREATE USER failed for 'user01'@'%'
mysql> CREATE USER user01@'192.168.%.%' IDENTIFIED BY 'MySQL123!';
Query OK, 0 rows affected (0.01 sec)

mysql> select user,host from mysql.user;
+------------------+-------------+
| user             | host        |
+------------------+-------------+
| user01           | %           |	# 默认是任意位置的意思？
| user01           | 192.168.%.% |
| mysql.infoschema | localhost   |
| mysql.session    | localhost   |
| mysql.sys        | localhost   |
| root             | localhost   |
+------------------+-------------+
6 rows in set (0.00 sec)


[root@C84MySQL8 ~]# mysql -uuser01 -p'MySQL123!'

mysql> status

Current user:           user01@localhost



[root@C84MySQL8 ~]# mysql -uuser01@'192.168.50.19' -p'MySQL123!'
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1045 (28000): Access denied for user 'user01@192.168.50.19'@'localhost' (using password: YES)
[root@C84MySQL8 ~]# mysql -u user01@'192.168.50.19' -p'MySQL123!'
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1045 (28000): Access denied for user 'user01@192.168.50.19'@'localhost' (using password: YES)


[root@C84MySQL8 ~]# mysql --user=user01@'192.168.50.19' --password='MySQL123!'
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1045 (28000): Access denied for user 'user01@192.168.50.19'@'localhost' (using password: YES)

[root@C84MySQL8 ~]# mysql --user=user01 --host='192.168.50.19' --password='MySQL123!'

mysql> status

Current user:           user01@C84MySQL8


[root@C84MySQL8 ~]# mysql --user=user01 --host='192.168.50.21' --password='MySQL123!'
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 2003 (HY000): Can't connect to MySQL server on '192.168.50.21:3306' (113)
# 这个host必须是可以连上的？这个MySQL的用户的host不是许可从哪里登录的意思？

mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 2003 (HY000): Can't connect to MySQL server on '192.168.50.1:3306' (110)

# 设置不同密码

mysql> ALTER USER user01@'192.168.%.%' IDENTIFIED BY 'MySQL124!';
Query OK, 0 rows affected (0.01 sec)

# localhost的
[root@C84MySQL8 ~]# mysql --user=user01 --host='localhost' --password='MySQL123!'

mysql> status

Current user:           user01@localhost

# 默认是localhost
[root@C84MySQL8 ~]# mysql --user=user01 --password='MySQL123!'

mysql> status

Current user:           user01@localhost

# 指定密码的，需要用相应地的网段的用户
[root@C84MySQL8 ~]# mysql --user=user01 --host='192.168.50.19' --password='MySQL123!'
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1045 (28000): Access denied for user 'user01'@'C84MySQL8' (using password: YES)

[root@C84MySQL8 ~]# mysql --user=user01 --host='192.168.50.19' --password='MySQL124!'

mysql> status

Current user:           user01@C84MySQL8

# 只有指定的网段的才可以登录
[root@C84MySQL8 ~]# mysql --user=user01 --host='10.0.2.15' --password='MySQL124!'
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1045 (28000): Access denied for user 'user01'@'C84MySQL8' (using password: YES)

ERROR 1045 (28000): Access denied for user 'user01'@'localhost' (using password: YES)
[root@C84MySQL8 ~]# mysql --user=user01 --host='127.0.0.2' --password='MySQL124!'
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1045 (28000): Access denied for user 'user01'@'localhost' (using password: YES)


```

## MySQL客户端的一些命令

### mysql

客户端命令：完整格式，简写格式

```sh
简写	完整格式
\h		help
\u		use
\s		status
\! ls	system ls

```

服务端命令：通过mysql协议发送到服务器执行并取回结果，命令末尾使用命令结束符号，默认分号

```sh

mysql> SELECT VERSION();
+-----------+
| VERSION() |
+-----------+
| 8.0.24    |
+-----------+
1 row in set (0.00 sec)

```

mysql模式

- 交互式

  ```sh
  [root@C84MySQL8 ~]# mysql -uroot -pMySQL123!
  mysql>
  
  ```

- 脚本模式

  ```sh
  [root@C84MySQL8 ~]# cat showusers.sql
  SELECT user,host from mysql.user;
  
  # 在shell命令行
  [root@C84MySQL8 ~]# mysql -uroot -pMySQL123! < showusers.sql
  mysql: [Warning] Using a password on the command line interface can be insecure.
  user    host
  user01  %
  user01  192.168.%.%
  mysql.infoschema        localhost
  mysql.session   localhost
  mysql.sys       localhost
  root    localhost
  
  # 在mysql命令行
  mysql> source showusers.sql
  +------------------+-------------+
  | user             | host        |
  +------------------+-------------+
  | user01           | %           |
  | user01           | 192.168.%.% |
  | mysql.infoschema | localhost   |
  | mysql.session    | localhost   |
  | mysql.sys        | localhost   |
  | root             | localhost   |
  +------------------+-------------+
  6 rows in set (0.00 sec)
  
  
  ```

  

mysql命令格式

```sh
[root@C84MySQL8 ~]# mysql --help 
Usage: mysql [OPTIONS] [database]

```

常用

```sh
-A, --no-auto-rehash	# 不自动补全
-C, --compress      Use compression in server/client protocol.
-D, --database=name Database to use.
--default-character-set=name
--delimiter=name    Delimiter to be used.	# 分隔符
-e, --execute=name  Execute command and quit. (Disables --force and history file.)
-G, --named-commands	# mysql客户端内部命令
-h, --host=name     Connect to host.
--sigint-ignore     Ignore SIGINT (CTRL-C).
--disable-pager	# 默认全部一次性输出，
--pager[=name]	# less，more，cat等
-p, --password[=name]
-P, --port=# 	# 服务器监听的端口号 
--prompt=name   Set the mysql prompt to this value.# 设置命令提示符
--protocol=name  The protocol to use for connection (tcp, socket, pipe, memory).
-S, --socket=name   The socket file to use for connection.
-u, --user=name 
--select-limit=#
--compression-algorithms=name
--load-data-local-dir=name

```

--help会显示选项以及当前的变量

```sh

[root@C84MySQL8 ~]# mysql --help
mysql  Ver 8.0.24 for Linux on x86_64 (MySQL Community Server - GPL)
Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Usage: mysql [OPTIONS] [database]
  -?, --help          Display this help and exit.
  -I, --help          Synonym for -?
  --auto-rehash       Enable automatic rehashing. One doesn't need to use
                      'rehash' to get table and field completion, but startup
                      and reconnecting may take a longer time. Disable with
                      --disable-auto-rehash.
                      (Defaults to on; use --skip-auto-rehash to disable.)
  -A, --no-auto-rehash
                      No automatic rehashing. One has to use 'rehash' to get
                      table and field completion. This gives a quicker start of
                      mysql and disables rehashing on reconnect.
  --auto-vertical-output
                      Automatically switch to vertical output mode if the
                      result is wider than the terminal width.
  -B, --batch         Don't use history file. Disable interactive behavior.
                      (Enables --silent.)
  --bind-address=name IP address to bind to.
  --binary-as-hex     Print binary data as hex. Enabled by default for
                      interactive terminals.
  --character-sets-dir=name
                      Directory for character set files.
  --column-type-info  Display column type information.
  -c, --comments      Preserve comments. Send comments to the server. The
                      default is --skip-comments (discard comments), enable
                      with --comments.
  -C, --compress      Use compression in server/client protocol.
  -#, --debug[=#]     This is a non-debug version. Catch this and exit.
  --debug-check       This is a non-debug version. Catch this and exit.
  -T, --debug-info    This is a non-debug version. Catch this and exit.
  -D, --database=name Database to use.
  --default-character-set=name
                      Set the default character set.
  --delimiter=name    Delimiter to be used.
  --enable-cleartext-plugin
                      Enable/disable the clear text authentication plugin.
  -e, --execute=name  Execute command and quit. (Disables --force and history
                      file.)
  -E, --vertical      Print the output of a query (rows) vertically.
  -f, --force         Continue even if we get an SQL error.
  --histignore=name   A colon-separated list of patterns to keep statements
                      from getting logged into syslog and mysql history.
  -G, --named-commands
                      Enable named commands. Named commands mean this program's
                      internal commands; see mysql> help . When enabled, the
                      named commands can be used from any line of the query,
                      otherwise only from the first line, before an enter.
                      Disable with --disable-named-commands. This option is
                      disabled by default.
  -i, --ignore-spaces Ignore space after function names.
  --init-command=name SQL Command to execute when connecting to MySQL server.
                      Will automatically be re-executed when reconnecting.
  --local-infile      Enable/disable LOAD DATA LOCAL INFILE.
  -b, --no-beep       Turn off beep on error.
  -h, --host=name     Connect to host.
  --dns-srv-name=name Connect to a DNS SRV resource
  -H, --html          Produce HTML output.
  -X, --xml           Produce XML output.
  --line-numbers      Write line numbers for errors.
                      (Defaults to on; use --skip-line-numbers to disable.)
  -L, --skip-line-numbers
                      Don't write line number for errors.
  -n, --unbuffered    Flush buffer after each query.
  --column-names      Write column names in results.
                      (Defaults to on; use --skip-column-names to disable.)
  -N, --skip-column-names
                      Don't write column names in results.
  --sigint-ignore     Ignore SIGINT (CTRL-C).
  -o, --one-database  Ignore statements except those that occur while the
                      default database is the one named at the command line.
  --pager[=name]      Pager to use to display results. If you don't supply an
                      option, the default pager is taken from your ENV variable
                      PAGER. Valid pagers are less, more, cat [> filename],
                      etc. See interactive help (\h) also. This option does not
                      work in batch mode. Disable with --disable-pager. This
                      option is disabled by default.
  -p, --password[=name]
                      Password to use when connecting to server. If password is
                      not given it's asked from the tty.
  -P, --port=#        Port number to use for connection or 0 for default to, in
                      order of preference, my.cnf, $MYSQL_TCP_PORT,
                      /etc/services, built-in default (3306).
  --prompt=name       Set the mysql prompt to this value.
  --protocol=name     The protocol to use for connection (tcp, socket, pipe,
                      memory).
  -q, --quick         Don't cache result, print it row by row. This may slow
                      down the server if the output is suspended. Doesn't use
                      history file.
  -r, --raw           Write fields without conversion. Used with --batch.
  --reconnect         Reconnect if the connection is lost. Disable with
                      --disable-reconnect. This option is enabled by default.
                      (Defaults to on; use --skip-reconnect to disable.)
  -s, --silent        Be more silent. Print results with a tab as separator,
                      each row on new line.
  -S, --socket=name   The socket file to use for connection.
  --server-public-key-path=name
                      File path to the server public RSA key in PEM format.
  --get-server-public-key
                      Get server public key
  --ssl-mode=name     SSL connection mode.
  --ssl-ca=name       CA file in PEM format.
  --ssl-capath=name   CA directory.
  --ssl-cert=name     X509 cert in PEM format.
  --ssl-cipher=name   SSL cipher to use.
  --ssl-key=name      X509 key in PEM format.
  --ssl-crl=name      Certificate revocation list.
  --ssl-crlpath=name  Certificate revocation list path.
  --tls-version=name  TLS version to use, permitted values are: TLSv1, TLSv1.1,
                      TLSv1.2, TLSv1.3
  --ssl-fips-mode=name
                      SSL FIPS mode (applies only for OpenSSL); permitted
                      values are: OFF, ON, STRICT
  --tls-ciphersuites=name
                      TLS v1.3 cipher to use.
  -t, --table         Output in table format.
  --tee=name          Append everything into outfile. See interactive help (\h)
                      also. Does not work in batch mode. Disable with
                      --disable-tee. This option is disabled by default.
  -u, --user=name     User for login if not current user.
  -U, --safe-updates  Only allow UPDATE and DELETE that uses keys.
  -U, --i-am-a-dummy  Synonym for option --safe-updates, -U.
  -v, --verbose       Write more. (-v -v -v gives the table output format).
  -V, --version       Output version information and exit.
  -w, --wait          Wait and retry if connection is down.
  --connect-timeout=# Number of seconds before connection timeout.
  --max-allowed-packet=#
                      The maximum packet length to send to or receive from
                      server.
  --net-buffer-length=#
                      The buffer size for TCP/IP and socket communication.
  --select-limit=#    Automatic limit for SELECT when using --safe-updates.
  --max-join-size=#   Automatic limit for rows in a join when using
                      --safe-updates.
  --show-warnings     Show warnings after every statement.
  -j, --syslog        Log filtered interactive commands to syslog. Filtering of
                      commands depends on the patterns supplied via histignore
                      option besides the default patterns.
  --plugin-dir=name   Directory for client-side plugins.
  --default-auth=name Default authentication client-side plugin to use.
  --binary-mode       By default, ASCII '\0' is disallowed and '\r\n' is
                      translated to '\n'. This switch turns off both features,
                      and also turns off parsing of all clientcommands except
                      \C and DELIMITER, in non-interactive mode (for input
                      piped to mysql or loaded using the 'source' command).
                      This is necessary when processing output from mysqlbinlog
                      that may contain blobs.
  --connect-expired-password
                      Notify the server that this client is prepared to handle
                      expired password sandbox mode.
  --network-namespace=name
                      Network namespace to use for connection via tcp with a
                      server.
  --compression-algorithms=name
                      Use compression algorithm in server/client protocol.
                      Valid values are any combination of
                      'zstd','zlib','uncompressed'.
  --zstd-compression-level=#
                      Use this compression level in the client/server protocol,
                      in case --compression-algorithms=zstd. Valid range is
                      between 1 and 22, inclusive. Default is 3.
  --load-data-local-dir=name
                      Directory path safe for LOAD DATA LOCAL INFILE to read
                      from.

Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf /usr/etc/my.cnf ~/.my.cnf
The following groups are read: mysql client
The following options may be given as the first argument:
--print-defaults        Print the program argument list and exit.
--no-defaults           Don't read default options from any option file,
                        except for login file.
--defaults-file=#       Only read default options from the given file #.
--defaults-extra-file=# Read this file after the global files are read.
--defaults-group-suffix=#
                        Also read groups with concat(group, suffix)
--login-path=#          Read this path from the login file.

Variables (--variable-name=value)
and boolean options {FALSE|TRUE}  Value (after reading options)
--------------------------------- ----------------------------------------
auto-rehash                       TRUE
auto-vertical-output              FALSE
bind-address                      (No default value)
binary-as-hex                     FALSE
character-sets-dir                (No default value)
column-type-info                  FALSE
comments                          FALSE
compress                          FALSE
database                          (No default value)
default-character-set             auto
delimiter                         ;
enable-cleartext-plugin           FALSE
vertical                          FALSE
force                             FALSE
histignore                        (No default value)
named-commands                    FALSE
ignore-spaces                     FALSE
init-command                      (No default value)
local-infile                      FALSE
no-beep                           FALSE
host                              (No default value)
dns-srv-name                      (No default value)
html                              FALSE
xml                               FALSE
line-numbers                      TRUE
unbuffered                        FALSE
column-names                      TRUE
sigint-ignore                     FALSE
port                              0
prompt                            mysql>
quick                             FALSE
raw                               FALSE
reconnect                         TRUE
socket                            (No default value)
server-public-key-path            (No default value)
get-server-public-key             FALSE
ssl-ca                            (No default value)
ssl-capath                        (No default value)
ssl-cert                          (No default value)
ssl-cipher                        (No default value)
ssl-key                           (No default value)
ssl-crl                           (No default value)
ssl-crlpath                       (No default value)
tls-version                       (No default value)
tls-ciphersuites                  (No default value)
table                             FALSE
user                              (No default value)
safe-updates                      FALSE
i-am-a-dummy                      FALSE
connect-timeout                   0
max-allowed-packet                16777216
net-buffer-length                 16384
select-limit                      1000
max-join-size                     1000000
show-warnings                     FALSE
plugin-dir                        (No default value)
default-auth                      (No default value)
binary-mode                       FALSE
connect-expired-password          FALSE
network-namespace                 (No default value)
compression-algorithms            (No default value)
zstd-compression-level            3
load-data-local-dir               (No default value)

```

登录

```sh
[root@C84MySQL8 ~]# mysql -uroot -p'MySQL123!'

mysql> use mysql	# 切换数据库

Database changed
mysql> select database();	# 当前数据库
+------------+
| database() |
+------------+
| mysql      |
+------------+

mysql> select user();	# 当前用户
+----------------+
| user()         |
+----------------+
| root@localhost |
+----------------+

mysql> select user,host,password_expired from user;
+------------------+-------------+------------------+
| user             | host        | password_expired |
+------------------+-------------+------------------+
| user01           | %           | N                |
| user01           | 192.168.%.% | N                |
| mysql.infoschema | localhost   | N                |
| mysql.session    | localhost   | N                |
| mysql.sys        | localhost   | N                |
| root             | localhost   | N                |
+------------------+-------------+------------------+


mysql> system clear	# 清屏

mysql> ^DBye	# 按Ctrl+D退出
[root@C84MySQL8 ~]#


```

修改命令提示符

```sh
[root@C84MySQL8 ~]# mysql -V
mysql  Ver 8.0.24 for Linux on x86_64 (MySQL Community Server - GPL)

# 命令行
[root@C84MySQL8 ~]# mysql -uroot -p'MySQL123!' --prompt='db> '
db>

[root@C84MySQL8 ~]# mysql -uroot -p'MySQL123!' --prompt='\\r:\\m:\\s(\\u@\\h) [\\d]>\\_'

\r:\m:\s(\u@\h) [\d]>\_exit
Bye

[root@C84MySQL8 ~]# mysql -uroot -p'MySQL123!' --prompt="\\r:\\m:\\s(\\u@\\h) [\\d]>\\_"	# 得用双引号

08:21:58(root@localhost) [(none)]> use mysql

08:22:05(root@localhost) [mysql]> exit
Bye


# 环境变量

[root@C84MySQL8 ~]# export MYSQL_PS1="\\r:\\m:\\s(\\u@\\h) [\\d]>\\_"
[root@C84MySQL8 ~]# mysql -uroot -p'MySQL123!'
08:20:42(root@localhost) [(none)]> exit
Bye



# 配置文件

[root@C84MySQL8 ~]# mysql --print-defaults
mysql would have been started with the following arguments:

[root@C84MySQL8 ~]# mysql --print-defaults -v
mysql would have been started with the following arguments:
-v



[root@C84MySQL8 ~]# cat -A /etc/my.cnf.d/mysql.clients.cnf
[mysql]$
prompt="\\r:\\m:\\s(\\u@\\h) [\\d]>\\> "$
[root@C84MySQL8 ~]# mysql --print-defaults -v
mysql would have been started with the following arguments:
-v

[root@C84MySQL8 ~]# mysql -uroot -p'MySQL123!'
mysql>	# 没有效果

[root@C84MySQL8 ~]# cat -A /etc/my.cnf.d/mysql-clients.cnf
[mysql]$
prompt="\\r:\\m:\\s(\\u@\\h) [\\d]>\\> "$

[root@C84MySQL8 ~]# mysql -uroot -p'MySQL123!'
mysql>	# 没有效果▲配置方法改了？▲默认不在路径！或许需要配置mysql去包涵那个目录

Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf /usr/etc/my.cnf ~/.my.cnf

[root@C84MySQL8 ~]# cat ~/.my.cnf
[client]
user=root
password=MySQL123!

[mysql]
prompt=[\\u@\\h] [\\d]>

[root@C84MySQL8 ~]# mysql

[root@localhost] [(none)]>exit
Bye

```

配置mysql客户端自动登录（密码明文，有风险）

```sh

[root@C84MySQL8 ~]# cat -A /etc/my.cnf.d/client.pw.cnf
[client]$
user=root$
password=MySQL123!$
$
[mysql]$
prompt=[\\u@\\h] [\\d]> $
[root@C84MySQL8 ~]# mysql
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)

[root@C84MySQL8 ~]# mv /etc/my.cnf.d/client.pw.cnf /etc/my.cnf.d/client.cnf
[root@C84MySQL8 ~]# mysql
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)

# 配置没有生效▲默认不在路径！或许需要配置mysql去包涵那个目录
Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf /usr/etc/my.cnf ~/.my.cnf


[root@C84MySQL8 ~]# cp /etc/my.cnf.d/client.cnf ~/.my.cnf
[root@C84MySQL8 ~]# cat ~/.my.cnf
[client]
user=root
password=MySQL123!

[mysql]
prompt=[\\u@\\h] [\\d]>

[root@C84MySQL8 ~]# mysql

[root@localhost] [(none)]>exit
Bye


```



### mysqladmin



```sh

[root@C84MySQL8 ~]# mysqladmin --help
mysqladmin  Ver 8.0.24 for Linux on x86_64 (MySQL Community Server - GPL)
Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Administration program for the mysqld daemon.
Usage: mysqladmin [OPTIONS] command command....
  --bind-address=name IP address to bind to.
  -c, --count=#       Number of iterations to make. This works with -i
                      (--sleep) only.
  -#, --debug[=#]     This is a non-debug version. Catch this and exit.
  --debug-check       This is a non-debug version. Catch this and exit.
  --debug-info        This is a non-debug version. Catch this and exit.
  -f, --force         Don't ask for confirmation on drop database; with
                      multiple commands, continue even if an error occurs.
  -C, --compress      Use compression in server/client protocol.
  --character-sets-dir=name
                      Directory for character set files.
  --default-character-set=name
                      Set the default character set.
  -?, --help          Display this help and exit.
  -h, --host=name     Connect to host.
  -b, --no-beep       Turn off beep on error.
  -p, --password[=name]
                      Password to use when connecting to server. If password is
                      not given it's asked from the tty.
  -P, --port=#        Port number to use for connection or 0 for default to, in
                      order of preference, my.cnf, $MYSQL_TCP_PORT,
                      /etc/services, built-in default (3306).
  --protocol=name     The protocol to use for connection (tcp, socket, pipe,
                      memory).
  -r, --relative      Show difference between current and previous values when
                      used with -i. Currently only works with extended-status.
  -s, --silent        Silently exit if one can't connect to server.
  -S, --socket=name   The socket file to use for connection.
  -i, --sleep=#       Execute commands repeatedly with a sleep between.
  --ssl-mode=name     SSL connection mode.
  --ssl-ca=name       CA file in PEM format.
  --ssl-capath=name   CA directory.
  --ssl-cert=name     X509 cert in PEM format.
  --ssl-cipher=name   SSL cipher to use.
  --ssl-key=name      X509 key in PEM format.
  --ssl-crl=name      Certificate revocation list.
  --ssl-crlpath=name  Certificate revocation list path.
  --tls-version=name  TLS version to use, permitted values are: TLSv1, TLSv1.1,
                      TLSv1.2, TLSv1.3
  --ssl-fips-mode=name
                      SSL FIPS mode (applies only for OpenSSL); permitted
                      values are: OFF, ON, STRICT
  --tls-ciphersuites=name
                      TLS v1.3 cipher to use.
  --server-public-key-path=name
                      File path to the server public RSA key in PEM format.
  --get-server-public-key
                      Get server public key
  -u, --user=name     User for login if not current user.
  -v, --verbose       Write more information.
  -V, --version       Output version information and exit.
  -E, --vertical      Print output vertically. Is similar to --relative, but
                      prints output vertically.
  -w, --wait[=#]      Wait and retry if connection is down.
  --connect-timeout=#
  --shutdown-timeout=#
  --plugin-dir=name   Directory for client-side plugins.
  --default-auth=name Default authentication client-side plugin to use.
  --enable-cleartext-plugin
                      Enable/disable the clear text authentication plugin.
  --show-warnings     Show warnings after execution
  --compression-algorithms=name
                      Use compression algorithm in server/client protocol.
                      Valid values are any combination of
                      'zstd','zlib','uncompressed'.
  --zstd-compression-level=#
                      Use this compression level in the client/server protocol,
                      in case --compression-algorithms=zstd. Valid range is
                      between 1 and 22, inclusive. Default is 3.

Variables (--variable-name=value)
and boolean options {FALSE|TRUE}  Value (after reading options)
--------------------------------- ----------------------------------------
bind-address                      (No default value)
count                             0
force                             FALSE
compress                          FALSE
character-sets-dir                (No default value)
default-character-set             auto
host                              (No default value)
no-beep                           FALSE
port                              0
relative                          FALSE
socket                            (No default value)
sleep                             0
ssl-ca                            (No default value)
ssl-capath                        (No default value)
ssl-cert                          (No default value)
ssl-cipher                        (No default value)
ssl-key                           (No default value)
ssl-crl                           (No default value)
ssl-crlpath                       (No default value)
tls-version                       (No default value)
tls-ciphersuites                  (No default value)
server-public-key-path            (No default value)
get-server-public-key             FALSE
user                              (No default value)
verbose                           FALSE
vertical                          FALSE
connect-timeout                   43200
shutdown-timeout                  3600
plugin-dir                        (No default value)
default-auth                      (No default value)
enable-cleartext-plugin           FALSE
show-warnings                     FALSE
compression-algorithms            (No default value)
zstd-compression-level            3

Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf /usr/etc/my.cnf ~/.my.cnf
The following groups are read: mysqladmin client
The following options may be given as the first argument:
--print-defaults        Print the program argument list and exit.
--no-defaults           Don't read default options from any option file,
                        except for login file.
--defaults-file=#       Only read default options from the given file #.
--defaults-extra-file=# Read this file after the global files are read.
--defaults-group-suffix=#
                        Also read groups with concat(group, suffix)
--login-path=#          Read this path from the login file.

Where command is a one or more of: (Commands may be shortened)
  create databasename   Create a new database
  debug                 Instruct server to write debug information to log
  drop databasename     Delete a database and all its tables
  extended-status       Gives an extended status message from the server
  flush-hosts           Flush all cached hosts
  flush-logs            Flush all logs
  flush-status          Clear status variables
  flush-tables          Flush all tables
  flush-threads         Flush the thread cache
  flush-privileges      Reload grant tables (same as reload)
  kill id,id,...        Kill mysql threads
  password [new-password] Change old password to new-password in current format
  ping                  Check if mysqld is alive
  processlist           Show list of active threads in server
  reload                Reload grant tables
  refresh               Flush all tables and close and open logfiles
  shutdown              Take server down
  status                Gives a short status message from the server
  start-slave           Start slave
  stop-slave            Stop slave
  variables             Prints variables available
  version               Get version info from server

```

栗子

```sh

[root@C84MySQL8 ~]# mysqladmin ping
mysqld is alive
[root@C84MySQL8 ~]# mysqladmin shutdown	# 没有启动子命令
[root@C84MySQL8 ~]# systemctl status mysqld
● mysqld.service - MySQL Server
   Loaded: loaded (/usr/lib/systemd/system/mysqld.service; enabled; vendor preset: disabled)
   Active: inactive (dead) since Fri 2021-12-24 21:12:10 JST; 8s ago

[root@C84MySQL8 ~]# systemctl start mysqld

[root@C84MySQL8 ~]# mysqladmin create db1
[root@C84MySQL8 ~]# mysqladmin drop db1
Dropping the database is potentially a very bad thing to do.
Any data stored in the database will be destroyed.

Do you really want to drop the 'db1' database [y/N] y
Database "db1" dropped


[root@C84MySQL8 ~]# mysqladmin password 'MySQL124!';
mysqladmin: [Warning] Using a password on the command line interface can be insecure.
Warning: Since password will be sent to server in plain text, use ssl connection to ensure password safety.
[root@C84MySQL8 ~]# mysql
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
[root@C84MySQL8 ~]# mysql -uroot -p'MySQL124!'

[root@localhost] [(none)]>exit
Bye
[root@C84MySQL8 ~]#

[root@C84MySQL8 ~]# mysqladmin password 'MySQL123!';
mysqladmin: connect to server at 'localhost' failed
error: 'Access denied for user 'root'@'localhost' (using password: YES)'
[root@C84MySQL8 ~]# mysqladmin -uroot -p'MySQL124!' password 'MySQL123!';
mysqladmin: [Warning] Using a password on the command line interface can be insecure.
Warning: Since password will be sent to server in plain text, use ssl connection to ensure password safety.


[root@C84MySQL8 ~]# ls /var/lib/mysql | grep binlog
binlog.000001
binlog.000002
binlog.000003
binlog.000004
binlog.index
[root@C84MySQL8 ~]# mysqladmin flush-logs
[root@C84MySQL8 ~]# ls /var/lib/mysql | grep binlog
binlog.000001
binlog.000002
binlog.000003
binlog.000004
binlog.000005	# 日志滚动，生成新的日志
binlog.index


[root@C84MySQL8 ~]# mysqladmin status
Uptime: 212  Threads: 2  Questions: 22  Slow queries: 0  Opens: 157  Flush tables: 3  Open tables: 76  Queries per second avg: 0.103
[root@C84MySQL8 ~]# mysqladmin flush-privileges	# 修改权限后重载权限表
[root@C84MySQL8 ~]# mysqladmin processlist
+----+-----------------+-----------+----+---------+------+------------------------+------------------+
| Id | User            | Host      | db | Command | Time | State                  | Info             |
+----+-----------------+-----------+----+---------+------+------------------------+------------------+
| 5  | event_scheduler | localhost |    | Daemon  | 239  | Waiting on empty queue |                  |
| 19 | root            | localhost |    | Query   | 0    | init                   | show processlist |
+----+-----------------+-----------+----+---------+------+------------------------+------------------+



```



### mycli

这个不是mysql命令行，而是一个叫做mycli的命令行，另一个CLI客户端软件，具有自动补全和语法突出显示功能

项目地址，官网URL

MyCLI is a command line interface for MySQL, MariaDB, and Percona with auto-completion and syntax highlighting.

```sh
https://github.com/dbcli/mycli
https://www.mycli.net/

```

安装（Linux下反倒是没有yum或者dnf的rpm包）

```sh
yum install python-pip && pip install mycli # CentOS，RHEL
brew update && brew install mycli  # Only on macOS
sudo apt-get install mycli # Only on debian or ubuntu


[root@C84MySQL8 ~]# yum install python-pip
Last metadata expiration check: 0:05:05 ago on Fri 24 Dec 2021 09:18:54 PM JST.
No match for argument: python-pip
Error: Unable to find a match: python-pip

[root@C84MySQL8 ~]# dnf -y install python3

[root@C84MySQL8 ~]# pip3 install mycli
    Traceback (most recent call last):
      File "<string>", line 1, in <module>
      File "/tmp/pip-build-4s5zmvqm/cryptography/setup.py", line 14, in <module>
        from setuptools_rust import RustExtension
    ModuleNotFoundError: No module named 'setuptools_rust'

[root@C84MySQL8 ~]# pip3 install --upgrade pip
[root@C84MySQL8 ~]# pip3 install setuptools-rust

[root@C84MySQL8 ~]# pip3 install mycli
[root@C84MySQL8 ~]# pip3 list 2>/dev/null | grep mycli
mycli               1.24.1

[root@C84MySQL8 ~]# which mycli
/usr/local/bin/mycli
[root@C84MySQL8 ~]# ll /usr/local/bin/mycli
-rwxr-xr-x. 1 root root 209 Dec 24 21:32 /usr/local/bin/mycli
[root@C84MySQL8 ~]# rpm -qf /usr/local/bin/mycli
file /usr/local/bin/mycli is not owned by any package

```



界面（使用my.cnf的配置）

```sh

[root@C84MySQL8 ~]# mycli
Error: Unable to read login path file.
Connecting to socket /var/lib/mysql/mysql.sock, owned by user mysql
MySQL
mycli 1.24.1
Home: http://mycli.net
Bug tracker: https://github.com/dbcli/mycli/issues
Thanks to the contributor - Thomas Roten
MySQL root@(none):(none)>	# 这里的localhost读取不出来



 [F3] Multiline: OFF    Right-arrow to complete suggestion


[root@C84MySQL8 ~]# mysql
[root@localhost] [(none)]>	# localhost


```



### 显示运行时变量



```sh
mysqld --verbose --help
mysqladmin variables
mysql --help
```





# mysql客户端和服务器配置文件

配置文件里配置，命令行传递参数，交互式修改参数

服务器运行参数，客户端连接时的参数

```sh
Default options are read from the following files in the given order:
/etc/my.cnf /etc/mysql/my.cnf /usr/etc/my.cnf ~/.my.cnf
The following groups are read: mysql client
The following options may be given as the first argument:
--print-defaults        Print the program argument list and exit.
--no-defaults           Don't read default options from any option file,
                        except for login file.
--defaults-file=#       Only read default options from the given file #.
--defaults-extra-file=# Read this file after the global files are read.
--defaults-group-suffix=#
                        Also read groups with concat(group, suffix)
--login-path=#          Read this path from the login file.

```



## 服务器配置文件

mysqld配置方式

- 命令行：启动时配置

- 配置文件

  ```sh
  
  [root@C84MySQL8 ~]# mysqld --verbose --help
  Starts the MySQL database server.
  Usage: mysqld [OPTIONS]
  
  Default options are read from the following files in the given order:
  /etc/my.cnf /etc/mysql/my.cnf /usr/etc/my.cnf
  ~/.my.cnf	# linux登录用户专用
  
  # https://dev.mysql.com/doc/refman/8.0/en/option-files.html
  
  # 全局的栗子
  [client]
  port=3306
  socket=/tmp/mysql.sock
  
  [mysqld]
  port=3306
  socket=/tmp/mysql.sock
  key_buffer_size=16M
  max_allowed_packet=128M
  
  [mysqldump]
  quick
  
  # 用户配置的栗子，可以在这里配置mysqld的？▲▲
  [mysqld]
  
  # 用户配置的栗子
  [client]
  # The following password is sent to all standard MySQL clients
  password="my password"
  
  [mysql]
  no-auto-rehash
  connect_timeout=2
  
  # 指定服务器版本
  [mysqld-8.0]
  sql_mode=TRADITIONAL
  
  # 包涵其他目录文件
  !include /home/mydir/myopt.cnf
  !includedir /home/mydir
  
  
  ```

  

配置文件格式（没有conf的man文档）

```sh
# 各种程序用的部分（多实例的时候注意默认的配置文件的冲突等）
[mysqld]
[mysql_safe]
[mysqld_multi]
[mysql]
[mysqldump]
[server]
[client]

# 格式（等号左右得空格？）
parameter = value

_和-相同，
1，ON，TRUE相同，0，OFF，FALSE相同，不区分大小写

```



## socket和网络连接



### socket

https://dev.mysql.com/doc/refman/8.0/en/connecting.html

连接的类型

- 没有指定host或者指定localhost
  - windows
    - 使用shared memory连接
  - Unix
    - 使用socket
      - --socket
      - 环境变量MYSQL_UNIX_PORT
- 在Windows，host如果是点，或者TCP/IP不可用，--socket没有指定
  - named pip
- 其他情况
  - TCP/IP

```sh
# Linux
[root@C84MySQL8 ~]# mysql -e status | grep socket
Connection:             Localhost via UNIX socket
UNIX socket:            /var/lib/mysql/mysql.sock

[root@C84MySQL8 ~]# mysql -e status -S /var/lib/mysql/mysql.sock | grep socket
Connection:             Localhost via UNIX socket
UNIX socket:            /var/lib/mysql/mysql.sock

# MySQL8增加了一个扩展端口33060
[root@C84MySQL8 ~]# ss -ntlp | grep mysql
LISTEN 0      70                 *:33060            *:*    users:(("mysqld",pid=1736,fd=22))
LISTEN 0      128                *:3306             *:*    users:(("mysqld",pid=1736,fd=24))

[root@C84MySQL8 ~]# mysql --host=192.168.50.19 -e status | grep Connection:
Connection:             192.168.50.19 via TCP/IP


[root@C84MySQL8 ~]# mysql --help | grep socket=
  -S, --socket=name   The socket file to use for connection.


# 通过TCP/IP连接的时候socket指定无效
[root@C84MySQL8 ~]# mysql --host=192.168.50.19 -S /var/lib/mysql/mysql.sock -e status | grep Connection:
Connection:             192.168.50.19 via TCP/IP

# 扩展端口
[root@C84MySQL8 ~]# mysql -e "SHOW VARIABLES LIKE 'port'"
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| port          | 3306  |
+---------------+-------+
[root@C84MySQL8 ~]# mysql -e "SHOW VARIABLES LIKE 'mysqlx_port'"
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| mysqlx_port   | 33060 |
+---------------+-------+

[root@C84MySQL8 ~]# mysql -e "SHOW VARIABLES LIKE '%port'"
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| admin_port               | 33062 |
| large_files_support      | ON    |
| mysqlx_port              | 33060 |
| port                     | 3306  |
| report_port              | 3306  |
| require_secure_transport | OFF   |
+--------------------------+-------+

```



### 关闭mysqld的网络连接

只通过本地连接（用途：临时性断网的断绝攻击的那种？）

```sh
# 追加
[root@C84MySQL8 ~]# egrep '^[^#]' /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
skip-networking=1	# 追加
bind_address=127.0.0.1	# 追加

[root@C84MySQL8 ~]# systemctl restart mysqld
[root@C84MySQL8 ~]# ss -ntlp
State     Recv-Q    Send-Q       Local Address:Port       Peer Address:Port   Process
LISTEN    0         128                0.0.0.0:22              0.0.0.0:*       users:(("sshd",pid=725,fd=5))
LISTEN    0         128                   [::]:22                 [::]:*       users:(("sshd",pid=725,fd=7))

# 网络监听没了
[root@C84MySQL8 ~]# mysql --host=192.168.50.19 -e status | grep Connection:
ERROR 2003 (HY000): Can't connect to MySQL server on '192.168.50.19:3306' (111)

[root@C84MySQL8 ~]# mysql -e status | grep Connection:
Connection:             Localhost via UNIX socket

```



# ▲配置SSL
