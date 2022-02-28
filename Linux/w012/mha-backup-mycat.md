# Linux Administrator

[toc]

# 主从复制及主主复制的实现

### 实验：一主一从（MariaDB 10.6 + C7）新建

实验环境

```
c79mamaster  -->  c79maslave
```

ip▲OS初期设置，密码，ip，防火墙，SELinux等▲

```sh
[root@c79mamaster ~]# nmcli con add type ethernet ifname enp0s8 con-name enp0s8a autoconnect yes save yes ipv4.method manual ipv4.addr 192.168.50.80/24

[root@c79maslave ~]# nmcli con add type ethernet ifname enp0s8 con-name enp0s8a autoconnect yes save yes ipv4.method manual ipv4.addr 192.168.50.81/24

nmcli con show
nmcli con up enp0s8a

[root@c79mamaster ~]# ip -br a | grep enp0s8
enp0s8           UP             192.168.50.80/24 fe80::d51f:4903:a424:9e44/64

[root@c79maslave ~]# ip -br a | grep enp0s8
enp0s8           UP             192.168.50.81/24 fe80::f3cb:efcc:7fcd:c645/64

# SELinux
sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# firewalld
systemctl disable firewalld --now

```

主节点搭建

```sh
# 安装

# cat /etc/yum.repos.d/MariaBD.repo
# MariaDB 10.6 CentOS repository list - created 2021-12-31 01:49 UTC
# https://mariadb.org/download/
[mariadb]
name = MariaDB
baseurl = https://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/yum/10.6/centos7-amd64
gpgkey=https://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/yum/RPM-GPG-KEY-MariaDB
gpgcheck=1

# yum install MariaDB-server MariaDB-client -y



# 配置文件

[root@c79mamaster ~]# vi /etc/my.cnf.d/server.cnf

[mysqld]
log-bin
server-id=1
log-basename=master1
binlog-format=mixed

[root@c79mamaster ~]# systemctl restart mariadb
[root@c79mamaster ~]# mysql

MariaDB [(none)]> show master logs;
+--------------------+-----------+
| Log_name           | File_size |
+--------------------+-----------+
| master1-bin.000001 |       330 |
+--------------------+-----------+
1 row in set (0.000 sec)

# 创建用户

MariaDB [(none)]> CREATE USER 'replica_user'@'%' IDENTIFIED BY 'MariaDB123!';
Query OK, 0 rows affected (0.003 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'replica_user'@'%';
Query OK, 0 rows affected (0.001 sec)


[root@c79mamaster ~]# cat ~/.my.cnf
[mysql]
prompt='Master [\\d] '


```

搭建从节点

```sh
# 安装

# cat /etc/yum.repos.d/MariaBD.repo
# MariaDB 10.6 CentOS repository list - created 2021-12-31 01:49 UTC
# https://mariadb.org/download/
[mariadb]
name = MariaDB
baseurl = https://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/yum/10.6/centos7-amd64
gpgkey=https://ftp.yz.yamagata-u.ac.jp/pub/dbms/mariadb/yum/RPM-GPG-KEY-MariaDB
gpgcheck=1

# yum install MariaDB-server MariaDB-client -y


# 配置


[root@c79maslave ~]# vi /etc/my.cnf.d/server.cnf

[mysqld]
log-bin
server_id=20
read_only=ON

[root@c79maslave ~]# systemctl restart mariadb
[root@c79maslave ~]# mysql

# 查看help


MariaDB [(none)]> help change master to
Name: 'CHANGE MASTER TO'


CHANGE MASTER TO
 MASTER_HOST='master2.mycompany.com',
 MASTER_USER='replication',
 MASTER_PASSWORD='bigs3cret',
 MASTER_PORT=3306,
 MASTER_LOG_FILE='master2-bin.001',
 MASTER_LOG_POS=4,
 MASTER_CONNECT_RETRY=10;

START SLAVE;



URL: https://mariadb.com/kb/en/library/change-master-to/


# 指定master的命令。注意log文件和pos是master上的数据

CHANGE MASTER TO MASTER_HOST='192.168.50.80', MASTER_USER='replica_user', MASTER_PASSWORD='MariaDB123!', MASTER_PORT=3306, MASTER_LOG_FILE='master1-bin.000001', MASTER_LOG_POS=330, MASTER_CONNECT_RETRY=10;


MariaDB [(none)]> CHANGE MASTER TO MASTER_HOST='192.168.50.80', MASTER_USER='replica_user', MASTER_PASSWORD='MariaDB123!', MASTER_PORT=3306, MASTER_LOG_FILE='master1-bin.000001', MASTER_LOG_POS=330, MASTER_CONNECT_RETRY=10;
Query OK, 0 rows affected (0.019 sec)


# 启动slave


MariaDB [(none)]> start slave;
Query OK, 0 rows affected (0.002 sec)


MariaDB [(none)]> show slave status\G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.50.80
                   Master_User: replica_user
                   Master_Port: 3306
                 Connect_Retry: 10
               Master_Log_File: master1-bin.000001
           Read_Master_Log_Pos: 666
                Relay_Log_File: c79maslave-relay-bin.000002
                 Relay_Log_Pos: 893
         Relay_Master_Log_File: master1-bin.000001
              Slave_IO_Running: Yes
             Slave_SQL_Running: Yes
               Replicate_Do_DB:
           Replicate_Ignore_DB:
            Replicate_Do_Table:
        Replicate_Ignore_Table:
       Replicate_Wild_Do_Table:
   Replicate_Wild_Ignore_Table:
                    Last_Errno: 0
                    Last_Error:
                  Skip_Counter: 0
           Exec_Master_Log_Pos: 666
               Relay_Log_Space: 1207
               Until_Condition: None
                Until_Log_File:
                 Until_Log_Pos: 0
            Master_SSL_Allowed: No
            Master_SSL_CA_File:
            Master_SSL_CA_Path:
               Master_SSL_Cert:
             Master_SSL_Cipher:
                Master_SSL_Key:
         Seconds_Behind_Master: 0
 Master_SSL_Verify_Server_Cert: No
                 Last_IO_Errno: 0
                 Last_IO_Error:
                Last_SQL_Errno: 0
                Last_SQL_Error:
   Replicate_Ignore_Server_Ids:
              Master_Server_Id: 1
                Master_SSL_Crl:
            Master_SSL_Crlpath:
                    Using_Gtid: No
                   Gtid_IO_Pos:
       Replicate_Do_Domain_Ids:
   Replicate_Ignore_Domain_Ids:
                 Parallel_Mode: optimistic
                     SQL_Delay: 0
           SQL_Remaining_Delay: NULL
       Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
              Slave_DDL_Groups: 2
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 0
1 row in set (0.000 sec)


[root@c79maslave ~]# cat ~/.my.cnf
[mysql]
prompt='Slave [\\d] '


```

由于是新安装的，所有不需要从master那里去全量备份数据到slave（slave的系统数据库怎办？▲）

在master追加数据，在slave上查看

```sql
# 在master

Master [(none)] create database product;
Master [(none)] use product
Master [product] create table computer(id int, computer_name varchar(20),maker varchar(10),price int,made_year int);

Master [product] insert into computer values(1,'zhan 66 pro','HP',4800,2021);

Master [product] insert into computer values(2,'Warrior 88','Gigabye',9800,2018);

Master [product] select * from computer;
+------+---------------+---------+-------+-----------+
| id   | computer_name | maker   | price | made_year |
+------+---------------+---------+-------+-----------+
|    1 | zhan 66 pro   | HP      |  4800 |      2021 |
|    2 | Warrior 88    | Gigabye |  9800 |      2018 |
+------+---------------+---------+-------+-----------+


Master [product] show master status;
+--------------------+----------+--------------+------------------+
| File               | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+--------------------+----------+--------------+------------------+
| master1-bin.000001 |     1428 |              |                  |
+--------------------+----------+--------------+------------------+
1 row in set (0.000 sec)


# 在slave

Slave [(none)] show slave status\G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.50.80
                   Master_User: replica_user
                   Master_Port: 3306
                 Connect_Retry: 10
               Master_Log_File: master1-bin.000001
           Read_Master_Log_Pos: 1428
                Relay_Log_File: c79maslave-relay-bin.000002	# 有新的日志
                 Relay_Log_Pos: 1655
         Relay_Master_Log_File: master1-bin.000001
              Slave_IO_Running: Yes
             Slave_SQL_Running: Yes

Slave [(none)] show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| product            |	# 同步
| sys                |
| test               |
+--------------------+
6 rows in set (0.003 sec)


Slave [(none)] select * from product.computer;	# 几乎实时同步？？
+------+---------------+---------+-------+-----------+
| id   | computer_name | maker   | price | made_year |
+------+---------------+---------+-------+-----------+
|    1 | zhan 66 pro   | HP      |  4800 |      2021 |
|    2 | Warrior 88    | Gigabye |  9800 |      2018 |
+------+---------------+---------+-------+-----------+
2 rows in set (0.000 sec)


```

在第3客户端分别查询master和slave

```powershell
# 下载Windows版，添加mysql客户端路径
P:\tmp>setx PATH "%PATH%;E:\mariadb-10.6.5-winx64\bin"

# 为了方便，创建远程登录的用户
CREATE USER 'admin01'@'%' IDENTIFIED BY 'MariaDB123!';
GRANT ALL ON *.* TO 'admin01'@'%';

# 登录（为何拒绝？

C:\Users\CHUHAI>mysql -uadmin01 -p'MariaDB123!' -h 192.168.50.80
ERROR 1045 (28000): Access denied for user 'admin01'@'192.168.50.1' (using password: YES)

C:\Users\CHUHAI>mysql -uadmin01 -p'MariaDB123!' -h 192.168.50.81
ERROR 1045 (28000): Access denied for user 'admin01'@'192.168.50.1' (using password: YES)

# 用Navicat就行。。。哪里的设置问题？

# MariaDB的访问日志？▲

```



### 实验：主主复制（互为主从）

两个节点，都可更新数据，互为主从

容易产生数据不一致问题

需要考虑自动增长id

一个配置奇数id起点

```
auto_increment_offset=1
auto_increment_increment=2
```

另一配置偶数

```
auto_increment_offset=2
auto_increment_increment=2
```

配置步骤概略

- 各节点的唯一server-id
- 都启动bin log 和relay log
- 创建有复制权限的用户账号
- 定义自动增长id的各为奇偶
- 互相把对方指定为主节点，启动复制线程



具体配置

```sh
# 在上面的实验环境下，增加master 2号机

[root@c79mamaster ~]# ip -br a | grep enp0s8
enp0s8           UP             192.168.50.80/24 fe80::32a:894d:833a:a8fb/64 fe80::d51f:4903:a424:9e44/64 fe80::426e:908:367c:6152/64

[root@c79mamaster2 ~]# ip -br a | grep enp0s8
enp0s8           UP             192.168.50.90/24 fe80::44d8:50e5:fd35:6196/64


[root@c79mamaster ~]# cat .my.cnf
[mysql]
prompt='Master [\\d] '

[root@c79mamaster2 ~]# cat .my.cnf
[mysql]
prompt='Master2 [\\d] '


# 2号机，数据库重置

[root@c79mamaster2 ~]# mv /var/lib/mysql{,.bak}
[root@c79mamaster2 ~]# mkdir /var/lib/mysql
[root@c79mamaster2 ~]# mariadb-install-db
[root@c79mamaster2 ~]# chown -R mysql:mysql /var/lib/mysql


```

1号机配置

```sh
[root@c79mamaster ~]# vi /etc/my.cnf.d/server.cnf

[mysqld]
log-bin
server-id=1
log-basename=master1
binlog-format=mixed
auto_increment_offset=1
auto_increment_increment=2

[root@c79mamaster ~]# systemctl restart mariadb


Master [(none)] show master logs;
+--------------------+-----------+
| Log_name           | File_size |
+--------------------+-----------+
| master1-bin.000001 |  28669701 |
| master1-bin.000002 |       438 |
| master1-bin.000003 |      2055 |
| master1-bin.000004 |       393 |
| master1-bin.000005 |       613 |
| master1-bin.000006 |       344 |
+--------------------+-----------+
6 rows in set (0.001 sec)

Master [(none)] show variables like 'auto_increment%';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| auto_increment_increment | 2     |
| auto_increment_offset    | 1     |
+--------------------------+-------+
2 rows in set (0.001 sec)

# 根据需要创建
CREATE USER 'replica_user'@'%' IDENTIFIED BY 'MariaDB123!';
GRANT REPLICATION SLAVE ON *.* TO 'replica_user'@'%';

```

2号机配置

```sh
[root@c79mamaster2 ~]# vi /etc/my.cnf.d/server.cnf

[mysqld]
log-bin
server-id=2
log-basename=master2
binlog-format=mixed
auto_increment_offset=2
auto_increment_increment=2

[root@c79mamaster2 ~]# systemctl restart mariadb

Master [(none)] show master logs;
+--------------------+-----------+
| Log_name           | File_size |
+--------------------+-----------+
| master2-bin.000001 |       330 |
+--------------------+-----------+
1 row in set (0.000 sec)

Master [(none)] show variables like 'auto_increment%';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| auto_increment_increment | 2     |
| auto_increment_offset    | 2     |
+--------------------------+-------+
2 rows in set (0.001 sec)


Master2 [(none)] CREATE USER 'replica_user2'@'%' IDENTIFIED BY 'MariaDB123!';
Query OK, 0 rows affected (0.002 sec)

Master2 [(none)] GRANT REPLICATION SLAVE ON *.* TO 'replica_user2'@'%';
Query OK, 0 rows affected (0.002 sec)

```

在2号机上配置master指向

```sql
Master [(none)] show master status;
+--------------------+----------+--------------+------------------+
| File               | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+--------------------+----------+--------------+------------------+
| master1-bin.000006 |      344 |              |                  |
+--------------------+----------+--------------+------------------+
1 row in set (0.000 sec)



Master2 [(none)] stop slave;
Query OK, 0 rows affected (0.005 sec)

Master2 [(none)] CHANGE MASTER TO MASTER_HOST='192.168.50.80', MASTER_USER='replica_user', MASTER_PASSWORD='MariaDB123!', MASTER_PORT=3306, MASTER_LOG_FILE='master1-bin.000006', MASTER_LOG_POS=344, MASTER_CONNECT_RETRY=10;
Query OK, 0 rows affected (0.046 sec)

Master2 [(none)] start slave;
Query OK, 0 rows affected (0.002 sec)


Master2 [(none)] show master logs;
+--------------------+-----------+
| Log_name           | File_size |
+--------------------+-----------+
| master2-bin.000001 |       678 |
+--------------------+-----------+
1 row in set (0.000 sec)


Master2 [(none)] show master status;
+--------------------+----------+--------------+------------------+
| File               | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+--------------------+----------+--------------+------------------+
| master2-bin.000001 |      678 |              |                  |
+--------------------+----------+--------------+------------------+
1 row in set (0.000 sec)

Master2 [(none)] show slave status\G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.50.80
                   Master_User: replica_user
                   Master_Port: 3306
                 Connect_Retry: 10
               Master_Log_File: master1-bin.000006
           Read_Master_Log_Pos: 344
                Relay_Log_File: master2-relay-bin.000002
                 Relay_Log_Pos: 557
         Relay_Master_Log_File: master1-bin.000006
              Slave_IO_Running: Yes
             Slave_SQL_Running: Yes


```

在1号机配置指向2号

```sql
Master [(none)] CHANGE MASTER TO MASTER_HOST='192.168.50.90', MASTER_USER='replica_user2', MASTER_PASSWORD='MariaDB123!', MASTER_PORT=3306, MASTER_LOG_FILE='master2-bin.000001', MASTER_LOG_POS=678, MASTER_CONNECT_RETRY=10;
Query OK, 0 rows affected (0.038 sec)


Master [(none)] start slave;
Query OK, 0 rows affected (0.002 sec)


Master [(none)] show slave status\G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.50.90
                   Master_User: replica_user2
                   Master_Port: 3306
                 Connect_Retry: 10
               Master_Log_File: master2-bin.000001
           Read_Master_Log_Pos: 678
                Relay_Log_File: master1-relay-bin.000002
                 Relay_Log_Pos: 557
         Relay_Master_Log_File: master2-bin.000001
              Slave_IO_Running: Yes
             Slave_SQL_Running: Yes
               Replicate_Do_DB:


```

创建测试数据（没有同步初期的全量备份导致的问题）

```sql
# 在没有把1号机的数据同步到2号机的情况下，在1号机上新建表

Master [(none)] use product
Database changed
Master [product] create table t1(id int auto_increment primary key, name char(10));
Query OK, 0 rows affected (0.024 sec)

# 2号机出错停止同步（没有数据库所以无法同步）

Master2 [(none)] show slave status\G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.50.80
                   Master_User: replica_user
                   Master_Port: 3306
                 Connect_Retry: 10
               Master_Log_File: master1-bin.000006
           Read_Master_Log_Pos: 1074
                Relay_Log_File: master2-relay-bin.000002
                 Relay_Log_Pos: 557
         Relay_Master_Log_File: master1-bin.000006
              Slave_IO_Running: Yes
             Slave_SQL_Running: No


                    Last_Errno: 1049
                    Last_Error: Error 'Unknown database 'product'' on query. Default database: 'product'. Query: 'create table t1(id int auto_increment primary key, name char(10))'

# 同步数据

[root@c79mamaster ~]# mariadb-dump -A -F --single-transaction --master-data=1 > /data/double-master-init.sql
[root@c79mamaster ~]# scp /data/double-master-init.sql 192.168.50.90:/data


[root@c79mamaster2 ~]# mysql -e 'stop slave'
[root@c79mamaster2 ~]# mysql < /data/double-master-init.sql

Master2 [(none)] start slave;
Query OK, 0 rows affected (0.002 sec)

Master2 [(none)] show slave status\G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.50.80
                   Master_User: replica_user
                   Master_Port: 3306
                 Connect_Retry: 10
               Master_Log_File: master1-bin.000007
           Read_Master_Log_Pos: 389
                Relay_Log_File: master2-relay-bin.000002
                 Relay_Log_Pos: 557
         Relay_Master_Log_File: master1-bin.000007
              Slave_IO_Running: Yes
             Slave_SQL_Running: Yes


```

创建测试数据

```sql
# 2号机上

Master2 [(none)] create database db2;

Master2 [(none)] use db2
Database changed

Master2 [db2] create table t1(id int auto_increment primary key, name char(10));
Query OK, 0 rows affected (0.021 sec)


Master2 [db2] insert into t1 (name) values('xiaohong');
Query OK, 1 row affected (0.002 sec)

Master2 [db2] select * from t1;
+----+----------+
| id | name     |
+----+----------+
|  2 | xiaohong |
+----+----------+
1 row in set (0.000 sec)

# 1号机上

Master [db2] select * from t1;
+----+----------+
| id | name     |
+----+----------+
|  2 | xiaohong |
+----+----------+
1 row in set (0.000 sec)


Master [db2] insert t1(name) values('xiaohei');
Query OK, 1 row affected (0.002 sec)

Master [db2] select * from t1;
+----+----------+
| id | name     |
+----+----------+
|  2 | xiaohong |
|  3 | xiaohei  |	# 起点为何是3
+----+----------+
2 rows in set (0.000 sec)

# 两边（同时）插入同样的数据（因为主键id是唯一的所以不冲突）

Master [db2] insert t1(name) values('xiaoqin');
Query OK, 1 row affected (0.002 sec)

Master2 [db2] insert t1(name) values('xiaoqin');
Query OK, 1 row affected (0.002 sec)


Master [db2] select * from t1;
+----+----------+
| id | name     |
+----+----------+
|  2 | xiaohong |
|  3 | xiaohei  |
|  5 | xiaoqin  |
|  6 | xiaoqin  |	# 为何序号不连续？？
+----+----------+
4 rows in set (0.000 sec)


# 两边（同时）创建同名数据库


Master [db2] create database db3;
Query OK, 1 row affected (0.000 sec)

Master2 [db2] create database db3;
ERROR 1007 (HY000): Can't create database 'db3'; database exists


Master2 [db2] show slave status\G	# 不显示错误'


# 两边（同时）在同个数据库下，创建同名表

Master [db2] create table t2(id int);
Query OK, 0 rows affected (0.011 sec)

Master2 [db2] create table t2(id int);
ERROR 1050 (42S01): Table 't2' already exists


```



# xtrabackup实现全量+增量+binlog恢复库

## MariaDB版备份（NG）

```sh
[root@mariadb ~]# systemctl status mariadb
● mariadb.service - MariaDB 10.3 database server

```

### 安装percona

```sh
[root@mariadb ~]# rpm -i percona-xtrabackup-80-8.0.23-16.1.el8.x86_64.rpm
warning: percona-xtrabackup-80-8.0.23-16.1.el8.x86_64.rpm: Header V4 RSA/SHA256 Signature, key ID 8507efa5: NOKEY
error: Failed dependencies:
        libev.so.4()(64bit) is needed by percona-xtrabackup-80-8.0.23-16.1.el8.x86_64
        rsync is needed by percona-xtrabackup-80-8.0.23-16.1.el8.x86_64

[root@mariadb ~]# dnf provides libev.so.4
Last metadata expiration check: 7:47:18 ago on Mon 28 Feb 2022 01:49:20 PM CST.
libev-4.24-6.el8.i686 : High-performance event loop/event model with lots of features
Repo        : appstream
Matched from:
Provide    : libev.so.4

[root@mariadb ~]# dnf -y install libev rsync

[root@mariadb ~]# rpm -i percona-xtrabackup-80-8.0.23-16.1.el8.x86_64.rpm
warning: percona-xtrabackup-80-8.0.23-16.1.el8.x86_64.rpm: Header V4 RSA/SHA256 Signature, key ID 8507efa5: NOKEY

[root@mariadb ~]# rpm -ql percona-xtrabackup-80-8.0.23-16.1.el8.x86_64 | grep bin
/usr/bin/xbcloud
/usr/bin/xbcloud_osenv
/usr/bin/xbcrypt
/usr/bin/xbstream
/usr/bin/xtrabackup

```

### 数据库第一次备份时的状态

```sh
[root@mariadb ~]# mysql -e "select * from hellodb.students;;"
+-------+-------------+-----+--------+---------+-----------+
| StuID | Name        | Age | Gender | ClassID | TeacherID |
+-------+-------------+-----+--------+---------+-----------+
|     1 | Shi Zhongyu |  22 | M      |       2 |         3 |
|     2 | Shi Potian  |  22 | M      |       1 |         7 |
|     3 | Xie Yanke   |  53 | M      |       2 |        16 |
|     4 | Ding Dian   |  32 | M      |       4 |         4 |
|     5 | Yu Yutong   |  26 | M      |       3 |         1 |
+-------+-------------+-----+--------+---------+-----------+

```

### 第一次备份

```sh
[root@mariadb ~]# mkdir /data/mariadb/backup -p
[root@mariadb ~]# xtrabackup -uroot --backup --target-dir=/data/mariadb/backup/01-base
xtrabackup: recognized server arguments: --datadir=/var/lib/mysql
xtrabackup: recognized client arguments: --user=root --backup=1 --target-dir=/data/mariadb/backup/01-base
xtrabackup version 8.0.23-16 based on MySQL server 8.0.23 Linux (x86_64) (revision id: 934bc8f)
220228 22:14:31  version_check Connecting to MySQL server with DSN 'dbi:mysql:;mysql_read_default_group=xtrabackup' as 'root'  (using password: NO).
220228 22:14:31  version_check Connected to MySQL server
220228 22:14:31  version_check Executing a version check against the server...

# A software update is available:
220228 22:14:35  version_check Done.
220228 22:14:35 Connecting to MySQL server host: localhost, user: root, password: not set, port: not set, socket: not set
Error: Unsupported server version: '10.3.28-MariaDB'.
This version of Percona XtraBackup can only perform backups and restores against MySQL 8.0 and Percona Server 8.0
Please use Percona XtraBackup 2.4 for this database.

```

### 更换percona-xtrabackup软件版本

```sh

[root@mariadb ~]# rpm -e percona-xtrabackup-80-8.0.23-16.1.el8.x86_64

[root@mariadb ~]# rpm -i percona-xtrabackup-24-2.4.22-1.el8.x86_64.rpm
warning: percona-xtrabackup-24-2.4.22-1.el8.x86_64.rpm: Header V4 RSA/SHA256 Signature, key ID 8507efa5: NOKEY

[root@mariadb ~]# xtrabackup -uroot --backup --target-dir=/data/mariadb/backup/01-base
xtrabackup: recognized server arguments: --datadir=/var/lib/mysql
xtrabackup: recognized client arguments: --user=root --backup=1 --target-dir=/data/mariadb/backup/01-base
220228 22:16:26  version_check Connecting to MySQL server with DSN 'dbi:mysql:;mysql_read_default_group=xtrabackup' as 'root'  (using password: NO).
220228 22:16:26  version_check Connected to MySQL server
220228 22:16:26  version_check Executing a version check against the server...
220228 22:16:26  version_check Done.
220228 22:16:26 Connecting to MySQL server host: localhost, user: root, password: not set, port: not set, socket: not set
Using server version 10.3.28-MariaDB
xtrabackup version 2.4.22 based on MySQL server 5.7.32 Linux (x86_64) (revision id: c99a781)
xtrabackup: uses posix_fadvise().
xtrabackup: cd to /var/lib/mysql
xtrabackup: open files limit requested 0, set to 1024
xtrabackup: using the following InnoDB configuration:
xtrabackup:   innodb_data_home_dir = .
xtrabackup:   innodb_data_file_path = ibdata1:12M:autoextend
xtrabackup:   innodb_log_group_home_dir = ./
xtrabackup:   innodb_log_files_in_group = 2
xtrabackup:   innodb_log_file_size = 50331648
InnoDB: Number of pools: 1
InnoDB: Unsupported redo log format. The redo log was created with MariaDB 10.3.28. Please follow the instructions at http://dev.mysql.com/doc/refman/5.7/en/upgrading-downgrading.html

```



## MySQL5.7版备份

MySQL版本

```sh
[root@mariadb mysql57]# mysql -uroot -p'8F%JOa8im6<!'
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.35

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> exit

```

### 安装percona

```sh

[root@mysql57 ~]# rpm -i percona-xtrabackup-24-2.4.22-1.el8.x86_64.rpm
warning: percona-xtrabackup-24-2.4.22-1.el8.x86_64.rpm: Header V4 RSA/SHA256 Signature, key ID 8507efa5: NOKEY
error: Failed dependencies:
        perl(DBD::mysql) is needed by percona-xtrabackup-24-2.4.22-1.el8.x86_64
[root@mysql57 ~]# dnf -y install perl-DBD-mysql
Last metadata expiration check: 0:33:10 ago on Mon 28 Feb 2022 10:23:46 PM CST.
Dependencies resolved.

[root@mysql57 ~]# rpm -i percona-xtrabackup-24-2.4.22-1.el8.x86_64.rpm
warning: percona-xtrabackup-24-2.4.22-1.el8.x86_64.rpm: Header V4 RSA/SHA256 Signature, key ID 8507efa5: NOKEY
[root@mysql57 ~]#

```



### 数据库第一次备份时的状态

```sh

[root@mysql57 ~]# mysql -e "select * from hellodb.students;"
+-------+-------------+-----+--------+---------+-----------+
| StuID | Name        | Age | Gender | ClassID | TeacherID |
+-------+-------------+-----+--------+---------+-----------+
|     1 | Shi Zhongyu |  22 | M      |       2 |         3 |
|     2 | Shi Potian  |  22 | M      |       1 |         7 |
|     3 | Xie Yanke   |  53 | M      |       2 |        16 |
|     4 | Ding Dian   |  32 | M      |       4 |         4 |
|     5 | Yu Yutong   |  26 | M      |       3 |         1 |
+-------+-------------+-----+--------+---------+-----------+

```

### 第一次备份（完全备份）

```sh

[root@mysql57 ~]# xtrabackup -uroot --backup --target-dir=/data/mariadb/backup/01-base
xtrabackup: recognized server arguments: --datadir=/var/lib/mysql
xtrabackup: recognized client arguments: --user=root --password=* --user=root --backup=1 --target-dir=/data/mariadb/backup/01-base
220228 22:57:33  version_check Connecting to MySQL server with DSN 'dbi:mysql:;mysql_read_default_group=xtrabackup' as 'root'  (using password: YES).
220228 22:57:33  version_check Connected to MySQL server
220228 22:57:33  version_check Executing a version check against the server...
220228 22:57:33  version_check Done.
220228 22:57:33 Connecting to MySQL server host: localhost, user: root, password: set, port: not set, socket: not set
Using server version 5.7.35
xtrabackup version 2.4.22 based on MySQL server 5.7.32 Linux (x86_64) (revision id: c99a781)
xtrabackup: uses posix_fadvise().
xtrabackup: cd to /var/lib/mysql
xtrabackup: open files limit requested 0, set to 1024
xtrabackup: using the following InnoDB configuration:
xtrabackup:   innodb_data_home_dir = .
xtrabackup:   innodb_data_file_path = ibdata1:12M:autoextend
xtrabackup:   innodb_log_group_home_dir = ./
xtrabackup:   innodb_log_files_in_group = 2
xtrabackup:   innodb_log_file_size = 50331648
InnoDB: Number of pools: 1
220228 22:57:33 >> log scanned up to (2806777)
xtrabackup: Generating a list of tablespaces
InnoDB: Allocated tablespace ID 2 for mysql/plugin, old maximum was 0
220228 22:57:33 [01] Copying ./ibdata1 to /data/mariadb/backup/01-base/ibdata1
220228 22:57:33 [01]        ...done
...

220228 22:57:33 [01] Copying ./hellodb/students.ibd to /data/mariadb/backup/01-base/hellodb/students.ibd
220228 22:57:33 [01]        ...done
...

220228 22:57:34 [01] Copying ./hellodb/toc.frm to /data/mariadb/backup/01-base/hellodb/toc.frm
220228 22:57:34 [01]        ...done
220228 22:57:34 Finished backing up non-InnoDB tables and files
220228 22:57:34 Executing FLUSH NO_WRITE_TO_BINLOG ENGINE LOGS...
xtrabackup: The latest check point (for incremental): '2806768'
xtrabackup: Stopping log copying thread.
.220228 22:57:34 >> log scanned up to (2806777)

220228 22:57:34 Executing UNLOCK TABLES
220228 22:57:34 All tables unlocked
220228 22:57:34 [00] Copying ib_buffer_pool to /data/mariadb/backup/01-base/ib_buffer_pool
220228 22:57:34 [00]        ...done
220228 22:57:34 Backup created in directory '/data/mariadb/backup/01-base/'
220228 22:57:34 [00] Writing /data/mariadb/backup/01-base/backup-my.cnf
220228 22:57:34 [00]        ...done
220228 22:57:34 [00] Writing /data/mariadb/backup/01-base/xtrabackup_info
220228 22:57:34 [00]        ...done
xtrabackup: Transaction log of lsn (2806768) to (2806777) was copied.
220228 22:57:35 completed OK!

```

### 第一次修改数据

```sh

[root@mysql57 ~]# mysql -e "insert into hellodb.students() values (6,'xiaohong',27,'F',1,1);"
[root@mysql57 ~]# mysql -e "select * from hellodb.students;"
+-------+-------------+-----+--------+---------+-----------+
| StuID | Name        | Age | Gender | ClassID | TeacherID |
+-------+-------------+-----+--------+---------+-----------+
|     1 | Shi Zhongyu |  22 | M      |       2 |         3 |
|     2 | Shi Potian  |  22 | M      |       1 |         7 |
|     3 | Xie Yanke   |  53 | M      |       2 |        16 |
|     4 | Ding Dian   |  32 | M      |       4 |         4 |
|     5 | Yu Yutong   |  26 | M      |       3 |         1 |
|     6 | xiaohong    |  27 | F      |       1 |         1 |
+-------+-------------+-----+--------+---------+-----------+

```

### 第一次增量备份

```sh
[root@mysql57 ~]# xtrabackup --backup --target-dir=/data/mariadb/backup/02-inc1 --incremental-basedir=/data/mariadb/backup/01-base

```

增量备份的文件小

```sh
[root@mysql57 ~]# du -d1 -h /data/mariadb/backup/
27M     /data/mariadb/backup/01-base
3.2M    /data/mariadb/backup/02-inc1
30M     /data/mariadb/backup/

```

### 第二次修改数据

```sh

[root@mysql57 ~]# mysql -e "insert into hellodb.students() values (7,'xiaobaibai',25,'F',1,1);"                       [root@mysql57 ~]# mysql -e "select * from hellodb.students;"
+-------+-------------+-----+--------+---------+-----------+
| StuID | Name        | Age | Gender | ClassID | TeacherID |
+-------+-------------+-----+--------+---------+-----------+
|     1 | Shi Zhongyu |  22 | M      |       2 |         3 |
|     2 | Shi Potian  |  22 | M      |       1 |         7 |
|     3 | Xie Yanke   |  53 | M      |       2 |        16 |
|     4 | Ding Dian   |  32 | M      |       4 |         4 |
|     5 | Yu Yutong   |  26 | M      |       3 |         1 |
|     6 | xiaohong    |  27 | F      |       1 |         1 |
|     7 | xiaobaibai  |  25 | F      |       1 |         1 |
+-------+-------------+-----+--------+---------+-----------+

```

### 第二次增量备份

```sh

[root@mysql57 ~]# xtrabackup --backup --target-dir=/data/mariadb/backup/02-inc2 --incremental-basedir=/data/mariadb/backup/02-inc1

```

数据文件

```sh

[root@mysql57 ~]# du -d1 -h /data/mariadb/backup/                                                                     27M     /data/mariadb/backup/01-base
3.2M    /data/mariadb/backup/02-inc1
3.1M    /data/mariadb/backup/02-inc2
33M     /data/mariadb/backup/

```

## MySQL5.7版数据还原

### 关闭数据库

```sh

[root@mysql57 ~]# systemctl stop mysqld

```

### 备份原数据库文件

```sh

[root@mysql57 ~]# mv /var/lib/mysql /var/lib/mysql-backup-`date +%F`
[root@mysql57 ~]# mkdir /var/lib/mysql
[root@mysql57 ~]# chown -R mysql.mysql /var/lib/mysql

[root@mysql57 ~]# ll -d /var/lib/mysql
drwxr-xr-x 2 mysql mysql 6 Feb 28 23:12 /var/lib/mysql

[root@mysql57 ~]# ll -d /var/lib/mysql-backup-2022-02-28/
drwxr-x--x 6 mysql mysql 329 Feb 28 23:10 /var/lib/mysql-backup-2022-02-28/

```

### 准备备份数据（全量）

```sh

[root@mysql57 ~]# xtrabackup --prepare --apply-log-only --target-dir=/data/mariadb/backup/01-base
xtrabackup: recognized server arguments: --innodb_checksum_algorithm=crc32 --innodb_log_checksum_algorithm=strict_crc32 --innodb_data_file_path=ibdata1:12M:autoextend --innodb_log_files_in_group=2 --innodb_log_file_size=50331648 --innodb_fast_checksum=0 --innodb_page_size=16384 --innodb_log_block_size=512 --innodb_undo_directory=./ --innodb_undo_tablespaces=0 --server-id=0 --redo-log-version=1
xtrabackup: recognized client arguments: --prepare=1 --apply-log-only=1 --target-dir=/data/mariadb/backup/01-base
xtrabackup version 2.4.22 based on MySQL server 5.7.32 Linux (x86_64) (revision id: c99a781)

xtrabackup: cd to /data/mariadb/backup/01-base/
xtrabackup: This target seems to be not prepared yet.

...

InnoDB: Starting crash recovery.

xtrabackup: starting shutdown with innodb_fast_shutdown = 1
InnoDB: Starting shutdown...
InnoDB: Shutdown completed; log sequence number 2806802
InnoDB: Number of pools: 1
220228 23:13:47 completed OK!

[root@mysql57 ~]# du -h -d1 /var/lib/mysql
0       /var/lib/mysql


```

### 准备数据（第一次增量)

```SH

[root@mysql57 ~]# xtrabackup --prepare --apply-log-only --target-dir=/data/mariadb/backup/01-base --incremental-dir=/data/mariadb/backup/02-inc1
xtrabackup: recognized server arguments: --innodb_checksum_algorithm=crc32 --innodb_log_checksum_algorithm=strict_crc32 --innodb_data_file_path=ibdata1:12M:autoextend --innodb_log_files_in_group=2 --innodb_log_file_size=50331648 --innodb_fast_checksum=0 --innodb_page_size=16384 --innodb_log_block_size=512 --innodb_undo_directory=./ --innodb_undo_tablespaces=0 --server-id=0 --redo-log-version=1
xtrabackup: recognized client arguments: --prepare=1 --apply-log-only=1 --target-dir=/data/mariadb/backup/01-base --incremental-dir=/data/mariadb/backup/02-inc1
xtrabackup version 2.4.22 based on MySQL server 5.7.32 Linux (x86_64) (revision id: c99a781)
incremental backup from 2806768 is enabled.
xtrabackup: cd to /data/mariadb/backup/01-base/
xtrabackup: This target seems to be already prepared with --apply-log-only.
InnoDB: Number of pools: 1
...



[root@mysql57 ~]# du -h -d1 /var/lib/mysql
0       /var/lib/mysql
[root@mysql57 ~]# du -h -d1 /data/mariadb/backup/
35M     /data/mariadb/backup/01-base
12M     /data/mariadb/backup/02-inc1
3.1M    /data/mariadb/backup/02-inc2
49M     /data/mariadb/backup/

```



### 准备数据（第二次增量）

最后一次不用`--apply-log-only`选项

```sh

[root@mysql57 ~]# xtrabackup --prepare --target-dir=/data/mariadb/backup/01-base --incremental-dir=/data/mariadb/backup/02-inc2
xtrabackup: recognized server arguments: --innodb_checksum_algorithm=crc32 --innodb_log_checksum_algorithm=strict_crc32 --innodb_data_file_path=ibdata1:12M:autoextend --innodb_log_files_in_group=2 --innodb_log_file_size=50331648 --innodb_fast_checksum=0 --innodb_page_size=16384 --innodb_log_block_size=512 --innodb_undo_directory=./ --innodb_undo_tablespaces=0 --server-id=0 --redo-log-version=1
xtrabackup: recognized client arguments: --prepare=1 --target-dir=/data/mariadb/backup/01-base --incremental-dir=/data/mariadb/backup/02-inc2
xtrabackup version 2.4.22 based on MySQL server 5.7.32 Linux (x86_64) (revision id: c99a781)
incremental backup from 2806982 is enabled.
xtrabackup: cd to /data/mariadb/backup/01-base/
xtrabackup: This target seems to be already prepared with --apply-log-only.
InnoDB: Number of pools: 1
xtrabackup: xtrabackup_logfile detected: size=8388608, start_lsn=(2807182)
...

# 备份目录越来愈大，都集合到base取了，总体的比原来的大。。
[root@mysql57 ~]# du -h -d1 /data/mariadb/backup/     
143M    /data/mariadb/backup/01-base
12M     /data/mariadb/backup/02-inc1
12M     /data/mariadb/backup/02-inc2
165M    /data/mariadb/backup/

[root@mysql57 ~]# du -h -d1 /var/lib/mysql
0       /var/lib/mysql
[root@mysql57 ~]#

[root@mysql57 ~]# du -h -d0 /var/lib/mysql-backup-2022-02-28
123M    /var/lib/mysql-backup-2022-02-28


```

### 还原

```sh

[root@mysql57 ~]# xtrabackup --copy-back --target-dir=/data/mariadb/backup/01-base
xtrabackup: recognized server arguments: --datadir=/var/lib/mysql
xtrabackup: recognized client arguments: --user=root --password=* --copy-back=1 --target-dir=/data/mariadb/backup/01-base
xtrabackup version 2.4.22 based on MySQL server 5.7.32 Linux (x86_64) (revision id: c99a781)
220228 23:21:28 [01] Copying ib_logfile0 to /var/lib/mysql/ib_logfile0
...


[root@mysql57 ~]# du -h -d0 /var/lib/mysql-backup-2022-02-28
123M    /var/lib/mysql-backup-2022-02-28
[root@mysql57 ~]# du -h -d1 /var/lib/mysql
12M     /var/lib/mysql/mysql
680K    /var/lib/mysql/sys
760K    /var/lib/mysql/hellodb
1.1M    /var/lib/mysql/performance_schema
135M    /var/lib/mysql


```

### 修改目录所有者和组，启动服务

```sh
[root@mysql57 ~]# chown -R mysql.mysql /var/lib/mysql

[root@mysql57 ~]# systemctl start mysqld

```

### 查看还原结果

```sh

[root@mysql57 ~]# mysql -e "select * from hellodb.students;"
+-------+-------------+-----+--------+---------+-----------+
| StuID | Name        | Age | Gender | ClassID | TeacherID |
+-------+-------------+-----+--------+---------+-----------+
|     1 | Shi Zhongyu |  22 | M      |       2 |         3 |
|     2 | Shi Potian  |  22 | M      |       1 |         7 |
|     3 | Xie Yanke   |  53 | M      |       2 |        16 |
|     4 | Ding Dian   |  32 | M      |       4 |         4 |
|     5 | Yu Yutong   |  26 | M      |       3 |         1 |
|     6 | xiaohong    |  27 | F      |       1 |         1 |
|     7 | xiaobaibai  |  25 | F      |       1 |         1 |
+-------+-------------+-----+--------+---------+-----------+

```



# MyCAT实现MySQL读写分离

### 实验：Mycat+MySQL主从

#### 实验环境，架构

```
client --- Mycat --- MariaDB (master)
             |-------MariaDB (slave)

```

#### MariaDB主从配置

```sh
# OS配置

[root@c79mamaster ~]# ip -br a | grep enp0s8
enp0s8           UP             192.168.50.80/24 fe80::d51f:4903:a424:9e44/64
[root@c79mamaster ~]# uname -a
Linux c79mamaster 3.10.0-1160.el7.x86_64 #1 SMP Mon Oct 19 16:18:59 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
[root@c79mamaster ~]# cat /etc/redhat-release
CentOS Linux release 7.9.2009 (Core)
[root@c79mamaster ~]# getenforce
Disabled
[root@c79mamaster ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)


[root@c79maslave ~]# ip -br a | grep enp0s8
enp0s8           UP             192.168.50.81/24 fe80::f3cb:efcc:7fcd:c645/64
[root@c79maslave ~]# uname -a
Linux c79maslave 3.10.0-1160.el7.x86_64 #1 SMP Mon Oct 19 16:18:59 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
[root@c79maslave ~]# cat /etc/redhat-release
CentOS Linux release 7.9.2009 (Core)
[root@c79maslave ~]# getenforce
Disabled
[root@c79maslave ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)

# 主从配置

[root@c79mamaster ~]# egrep '^[^#]' /etc/my.cnf.d/server.cnf

[mysqld]
binlog_ignore_db=db5
log-bin
server-id=1
log-basename=master1
binlog-format=mixed
rpl_semi_sync_master_enabled=ON
rpl_semi_sync_master_timeout=3000

[root@c79maslave ~]# egrep '^[^#]' /etc/my.cnf.d/server.cnf

[mysqld]
log-bin
server_id=20
read_only=ON
rpl_semi_sync_master_enabled=ON



# 主从status

Master [(none)] show databases;
+--------------------+
| Database           |
+--------------------+
| db1                |
| information_schema |
| mysql              |
| performance_schema |
| product            |
| sys                |
| test               |
+--------------------+
7 rows in set (0.000 sec)


Slave [(none)] show databases;
+--------------------+
| Database           |
+--------------------+
| db1                |
| information_schema |
| mysql              |
| performance_schema |
| product            |
| sys                |
| test               |
+--------------------+
7 rows in set (0.000 sec)

Slave [(none)] show slave status\G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.50.80
                   Master_User: replica_user
                   Master_Port: 3306
                 Connect_Retry: 10
               Master_Log_File: master1-bin.000010
           Read_Master_Log_Pos: 1024
                Relay_Log_File: c79maslave-relay-bin.000011
                 Relay_Log_Pos: 1325
         Relay_Master_Log_File: master1-bin.000010
              Slave_IO_Running: Yes
             Slave_SQL_Running: Yes



# 设置root密码（用root来连接Mycat是不是权限太大？▲有更新和查询就够了？？）
Master [(none)] create user root@'%' identified by 'MariaDB123!';
Query OK, 0 rows affected (0.004 sec)

Slave [(none)] create user root@'%' identified by 'MariaDB123!';
Query OK, 0 rows affected (10.005 sec)

Master [(none)] GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
Query OK, 0 rows affected (0.002 sec)

Slave [(none)] GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
Query OK, 0 rows affected (0.001 sec)

Master [(none)] flush privileges;
Query OK, 0 rows affected (0.001 sec)

Slave [(none)] flush privileges;
Query OK, 0 rows affected (0.001 sec)


```

#### Mycat配置

```sh
# OS配置

[root@mycat ~]# ip -br a | grep enp0s8
enp0s8           UP             192.168.50.90/24 fe80::44d8:50e5:fd35:6196/64
[root@mycat ~]# uname -a
Linux mycat 3.10.0-1160.el7.x86_64 #1 SMP Mon Oct 19 16:18:59 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
[root@mycat ~]# getenforce
Disabled
[root@mycat ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)

# 如果有，卸载MariaDB server

[root@mycat ~]# yum -y remove MariaDB*

# 需要用到mysql客户端

[root@mycat conf]# yum -y install MariaDB-client

```

安装JDK

```sh
[root@mycat mycat]# yum -y install java

[root@mycat mycat]# java -version
openjdk version "1.8.0_312"
OpenJDK Runtime Environment (build 1.8.0_312-b07)
OpenJDK 64-Bit Server VM (build 25.312-b07, mixed mode)

```

https://github.com/MyCATApache/Mycat-download

##### 下载

```sh
# https://github.com/MyCATApache/Mycat-Server/releases
# https://github.com/MyCATApache/Mycat-Server/releases/download/Mycat-server-1675-release/Mycat-server-1.6.7.5-release-20200422133810-linux.tar.gz

[root@mycat ~]# mkdir mycat
[root@mycat ~]# cd mycat/
[root@mycat mycat]# yum -y install wget

[root@mycat mycat]# wget https://github.com/MyCATApache/Mycat-Server/releases/download/Mycat-server-1675-release/Mycat-server-1.6.7.5-release-20200422133810-linux.tar.gz

[root@mycat mycat]# tar xvf Mycat-server-1.6.7.5-release-20200422133810-linux.tar.gz -C /usr/local

[root@mycat mycat]# cd /usr/local/mycat

[root@mycat mycat]# mkdir /usr/local/mycat/logs

[root@mycat mycat]# ls -1
bin			# 程序目录
catlet		# 扩展功能
conf		# 配置
lib			# jar包，java
version.txt # 版本
logs		# 日志，刚刚解压没有这个目录：wrapper.log启动日志，mycat.log详细日志


[root@mycat mycat]# ls -1 conf | grep -e server.xml -e schema.xml -e rule.xml
server.xml		# mycat配置。账号，参数等
schema.xml		# 对应的数据库和表的配置，读写分离，HA，分布式策略，节点控制等
rule.xml		# 分库分表的配置文件

```



#### 配置Mycat

配置环境变量

```sh
[root@mycat mycat]# cat /etc/profile.d/mycat.sh
PATH=/usr/local/mycat/bin:$PATH
[root@mycat mycat]# source /etc/profile.d/mycat.sh
```

备份主要配置文件

```sh
[root@mycat ~]# cd /usr/local/mycat/conf

[root@mycat conf]# cp server.xml{,.bak}
[root@mycat conf]# cp schema.xml{,.bak}
[root@mycat conf]# cp rule.xml{,.bak}

```

#### 启动测试

```sh
[root@mycat conf]# mycat start
Starting Mycat-server...
[root@mycat conf]# mycat status
Mycat-server is running (1412).

[root@mycat conf]# ss -ntlp | grep java
LISTEN     0      1      127.0.0.1:32000                    *:*                   users:(("java",pid=1414,fd=4))
LISTEN     0      50        [::]:41850                 [::]:*                   users:(("java",pid=1414,fd=69))
LISTEN     0      50        [::]:1984                  [::]:*                   users:(("java",pid=1414,fd=70))
LISTEN     0      100       [::]:8066                  [::]:*                   users:(("java",pid=1414,fd=91))
LISTEN     0      50        [::]:36645                 [::]:*                   users:(("java",pid=1414,fd=71))
LISTEN     0      100       [::]:9066                  [::]:*                   users:(("java",pid=1414,fd=87))

# 连接测试，默认密码123456

[root@mycat conf]# mysql -uroot -p123456 -h127.0.0.1 -P 8066
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 1
Server version: 5.6.29-mycat-1.6.7.5-release-20200422133810 MyCat Server (OpenCloudDB)

[root@mycat conf]# mysql -uroot -p123456 -h127.0.0.1 -P 8066 -e 'show databases\G'
*************************** 1. row ***************************
DATABASE: TESTDB

# 停止Mycat服务

[root@mycat conf]# mycat stop
Stopping Mycat-server...
Stopped Mycat-server.
[root@mycat conf]# mycat status
Mycat-server is not running.

```

#### server.xml

```sh
# 配置用来登录Mycat的用户，配置只Mycat的端口

# 用户权限怎么配置▲

# 基本都是注释<!-- -->

<mycat:server xmlns:mycat="http://io.mycat/">

        <!--  <property name="fakeMySQLVersion">5.6.20</property>--> <!--设置模拟的MySQL版本号-->

                <!--
                        <property name="serverPort">8066</property> <property name="managerPort">9066</property>

                        <property name="dataNodeIdleCheckPeriod">300000</property> 5 * 60 * 1000L; //连接空闲检查
                        <property name="frontWriteQueueSize">4096</property> <property name="processors">32</property> -->


        <firewall>
           <whitehost>
              <host host="1*7.0.0.*" user="root"/>
           </whitehost>
       <blacklist check="false">
       </blacklist>
        </firewall>
        -->


        <user name="user">
                <property name="password">user</property>
                <property name="schemas">TESTDB</property>
        </user>
</mycat:server>

# 把上面的修改为（追加）


                        <property name="serverPort">3306</property> <property name="managerPort">9066</property> <!-- 单独追加 -->

        <user name="admin"> <!-- 单独追加 -->
                <property name="password">admin</property> <!-- 单独追加 -->
                <property name="schemas">TESTDB</property> <!-- 单独追加 -->
        </user> <!-- 单独追加 -->




[root@mycat conf]# vi server.xml
[root@mycat conf]# grep '单独追加' server.xml
                <property name="serverPort">3306</property> <property name="managerPort">9066</property> <!-- 单独追加 -->
        <user name="admin"> <!-- 单独追加 -->
                <property name="password">admin</property> <!-- 单独追加 -->
                <property name="schemas">TESTDB</property> <!-- 单独追加 -->
        </user> <!-- 单独追加 -->

# 启动测试

[root@mycat conf]# mycat start
Starting Mycat-server...
[root@mycat conf]# mycat status
Mycat-server is running (2361).

# 登录测试

[root@mycat conf]# mysql -uadmin -padmin -h127.0.0.1 -P3306
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 22
Server version: 5.6.29-mycat-1.6.7.5-release-20200422133810 MyCat Server (OpenCloudDB)


Mycat [(none)] show databases;
+----------+
| DATABASE |
+----------+
| TESTDB   |
+----------+
1 row in set (0.002 sec)

# ok，关闭

[root@mycat conf]# mycat stop
Stopping Mycat-server...
Stopped Mycat-server.

```

#### schema.xml（读写分离配置）

```sh
# 把注释行删除，留下结构为
# <mycat最大的标签
#  <schema逻辑数据库，用来隐藏后端真实数据库的名字
#   <table这个表？？
#  <dataNode节点，后端数据库的真实名字，可为主从集群（和schema逻辑数据库一一对应？▲）
#  <dataHost节点下的真实数据库实例集群，主从集群等，一个数据库在多个host上
#   <writeHost真实的数据库实例

<mycat:schema xmlns:mycat="http://io.mycat/">
        <schema name="TESTDB" checkSQLschema="true" sqlMaxLimit="100" randomDataNode="dn1"></schema>
        <dataNode name="dn1" dataHost="localhost1" database="db1" />
        <dataHost name="localhost1" maxCon="1000" minCon="10" balance="0"
                          writeType="0" dbType="mysql" dbDriver="jdbc" switchType="1"  slaveThreshold="100">
                <heartbeat>select user()</heartbeat>
                <!-- can have multi write hosts -->
                <writeHost host="hostM1" url="jdbc:mysql://localhost:3306" user="root"
                                   password="root">
                </writeHost>
                <!-- <writeHost host="hostM2" url="localhost:3316" user="root" password="123456"/> -->
        </dataHost>
</mycat:schema>


# 修改为

[root@mycat conf]# cat schema.xml
<?xml version="1.0"?>
<!DOCTYPE mycat:schema SYSTEM "schema.dtd">
<mycat:schema xmlns:mycat="http://io.mycat/">

        <schema name="TESTDB" checkSQLschema="false" sqlMaxLimit="100" dataNode="dn1"></schema>
        <dataNode name="dn1" dataHost="mariadbcluster" database="db1" />
        <dataHost name="mariadbcluster" maxCon="1000" minCon="10" balance="1" writeType="0" dbType="mysql" dbDriver="native" switchType="1"  slaveThreshold="100">
                <heartbeat>select user()</heartbeat>
                <writeHost host="hostM" url="192.168.50.80:3306" user="root" password="MariaDB123!"></writeHost>
                <writeHost host="hostS" url="192.168.50.81:3306" user="root" password="MariaDB123!"></writeHost>
        </dataHost>
</mycat:schema>


# dataHost
balance="1" #读写分离
writeType="0" 
dbType="mysql" 
dbDriver="native" # 用mysql协议
switchType="1"  
slaveThreshold="100"

# 启动测试


[root@mycat conf]# mycat start
Starting Mycat-server...
[root@mycat conf]# mycat status
Mycat-server is running (2811).
[root@mycat conf]# ss -ntlp
State       Recv-Q Send-Q                                                                       Local Address:Port                                                                                      Peer Address:Port
LISTEN      0      1                                                                                127.0.0.1:32000                                                                                                *:*                   users:(("java",pid=2813,fd=4))
LISTEN      0      128                                                                                      *:22                                                                                                   *:*                   users:(("sshd",pid=820,fd=3))
LISTEN      0      50                                                                                    [::]:35611                                                                                             [::]:*                   users:(("java",pid=2813,fd=71))
LISTEN      0      50                                                                                    [::]:1984                                                                                              [::]:*                   users:(("java",pid=2813,fd=70))
LISTEN      0      100                                                                                   [::]:3306                                                                                              [::]:*                   users:(("java",pid=2813,fd=91))
LISTEN      0      100                                                                                   [::]:9066                                                                                              [::]:*                   users:(("java",pid=2813,fd=87))
LISTEN      0      50                                                                                    [::]:40170                                                                                             [::]:*                   users:(("java",pid=2813,fd=69))
LISTEN      0      128                                                                                   [::]:22                                                                                                [::]:*                   users:(("sshd",pid=820,fd=4))
[root@mycat conf]#

# 看不到后端的数据库？

[root@mycat conf]# mysql -uadmin -padmin -h127.0.0.1 -P3306
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 1
Server version: 5.6.29-mycat-1.6.7.5-release-20200422133810 MyCat Server (OpenCloudDB)

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

Mycat [(none)] show databases;
+----------+
| DATABASE |
+----------+
| TESTDB   |	# 只有抽象的这个配置在server.xml的user标签内的指定的数据库。具体的配置在schema的schema标签
+----------+
1 row in set (0.003 sec)

Mycat [(none)]



# 修改抽象数据库名server.xml和schema.xml要一致

[root@mycat conf]# sed -n 's/TESTDB/MycatDB/p' server.xml
                <property name="defaultSchema">MycatDB</property>
                        <schema name="MycatDB" dml="0110" >
                <property name="schemas">MycatDB</property>
                <property name="defaultSchema">MycatDB</property>
                <property name="schemas">MycatDB</property> <!-- 单独追加 -->


[root@mycat conf]# sed -i.TESTDB 's/TESTDB/MycatDB/' server.xml

[root@mycat conf]# grep 'MycatDB' schema.xml
        <schema name="MycatDB" checkSQLschema="false" sqlMaxLimit="100" dataNode="dn1"></schema>


[root@mycat conf]# mycat start
Starting Mycat-server...
[root@mycat conf]# mycat status
Mycat-server is running (3238).


[root@mycat conf]# mysql -uadmin -padmin -h127.0.0.1 -P3306
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 1
Server version: 5.6.29-mycat-1.6.7.5-release-20200422133810 MyCat Server (OpenCloudDB)

Mycat [(none)] show databases;
+----------+
| DATABASE |
+----------+
| MycatDB  |	#新名字
+----------+
1 row in set (0.002 sec)


Mycat [(none)] use MycatDB
Database changed
Mycat [MycatDB]


Mycat [MycatDB] show tables;
+---------------+
| Tables_in_db1 |
+---------------+
| t1            |	# 有映射到后端的实际数据库里的表了
+---------------+
1 row in set (0.002 sec)


Mycat [MycatDB] select * from t1;
Empty set (0.003 sec)


# 在后端查看
Slave [(none)] use db1
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
Slave [db1] show tables;
+---------------+
| Tables_in_db1 |
+---------------+
| t1            |
+---------------+
1 row in set (0.000 sec)

# 插入数据（在slave。。。错误的。。）

Slave [db1] insert into t1 values (1,'xiaobai'),(11,'xiaohei'),(111,'xiaoqin');
Query OK, 3 rows affected (0.002 sec)
Records: 3  Duplicates: 0  Warnings: 0

Slave [db1] select * from t1;
+-----+---------+
| id  | name    |
+-----+---------+
|   1 | xiaobai |
|  11 | xiaohei |
| 111 | xiaoqin |
+-----+---------+
3 rows in set (0.000 sec)


# 可以查到，优先查read-only的原因？？▲

Mycat [MycatDB] select * from t1;
+-----+---------+
| id  | name    |
+-----+---------+
|   1 | xiaobai |
|  11 | xiaohei |
| 111 | xiaoqin |
+-----+---------+
3 rows in set (0.003 sec)

# 没有同步到master 的

Master [db1] select * from t1;
Empty set (0.000 sec)


Slave [db1] delete from t1;
Query OK, 3 rows affected (0.002 sec)


Mycat [MycatDB] select * from t1;
Empty set (0.002 sec)

# 修复slave同步
Slave [db1] show slave status\G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event

              Slave_IO_Running: Yes
             Slave_SQL_Running: No



Master [db1] show master status;
+--------------------+----------+--------------+------------------+
| File               | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+--------------------+----------+--------------+------------------+
| master1-bin.000010 |     1460 |              | db5              |
+--------------------+----------+--------------+------------------+
1 row in set (0.000 sec)


Slave [db1] stop slave;
Query OK, 0 rows affected (0.004 sec)

Slave [db1] reset slave all;
Query OK, 0 rows affected (0.002 sec)

Slave [db1] CHANGE MASTER TO MASTER_HOST='192.168.50.80', MASTER_USER='replica_user', MASTER_PASSWORD='MariaDB123!', MASTER_PORT=3306, MASTER_LOG_FILE='master1-bin.000010', MASTER_LOG_POS=1460, MASTER_CONNECT_RETRY=10;
Query OK, 0 rows affected (0.016 sec)

Slave [db1] start slave;
Query OK, 0 rows affected (0.002 sec)

Slave [db1] show slave status\G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.50.80

         Relay_Master_Log_File: master1-bin.000010
              Slave_IO_Running: Yes
             Slave_SQL_Running: Yes



# 在master上更新数据


Master [db1] insert into t1 values (100,'xiaozhi');
Query OK, 1 row affected (0.003 sec)

Master [db1] select * from t1;
+-----+---------+
| id  | name    |
+-----+---------+
| 100 | xiaozhi |
+-----+---------+
1 row in set (0.000 sec)

Slave [db1] select * from t1;
+-----+---------+
| id  | name    |
+-----+---------+
| 100 | xiaozhi |
+-----+---------+
1 row in set (0.000 sec)


Mycat [MycatDB] select * from t1;
+-----+---------+
| id  | name    |
+-----+---------+
| 100 | xiaozhi |
+-----+---------+
1 row in set (0.002 sec)

#　查看id

Mycat [MycatDB] select @@server_id;
+-------------+
| @@server_id |
+-------------+
|          20 |	# slave的id
+-------------+
1 row in set (0.002 sec)

[root@mycat conf]# grep -E '^[^#]' /etc/my.cnf.d/server.cnf.rpmsave
[mysqld]
log-bin
server-id=2

Mycat [MycatDB] select @@hostname;
+------------+
| @@hostname |
+------------+
| c79maslave |	# 为何是slave的hostname，优先read-only的原因？
+------------+
1 row in set (0.001 sec)


Slave [db1] select @@server_id;
+-------------+
| @@server_id |
+-------------+
|          20 |
+-------------+
1 row in set (0.000 sec)

[root@c79maslave ~]# grep -E '^[^#]' /etc/my.cnf.d/server.cnf

[mysqld]
log-bin
server_id=20



Slave [db1] select @@hostname;
+------------+
| @@hostname |
+------------+
| c79maslave |
+------------+
1 row in set (0.000 sec)

Master [db1] select @@server_id;
+-------------+
| @@server_id |
+-------------+
|           1 |
+-------------+
1 row in set (0.000 sec)

Master [db1] select @@hostname;
+-------------+
| @@hostname  |
+-------------+
| c79mamaster |
+-------------+
1 row in set (0.000 sec)

```

#### 通过日志确认读写分离

```sh
# 在master和slave上启用日志（临时）


Master [(none)] show variables like 'general_log%';
+------------------+-------------+
| Variable_name    | Value       |
+------------------+-------------+
| general_log      | OFF         |
| general_log_file | master1.log |
+------------------+-------------+
2 rows in set (0.001 sec)


Master [(none)] set global general_log=on;
Query OK, 0 rows affected (0.003 sec)

Master [(none)] show variables like 'general_log%';
+------------------+-------------+
| Variable_name    | Value       |
+------------------+-------------+
| general_log      | ON          |
| general_log_file | master1.log |
+------------------+-------------+
2 rows in set (0.001 sec)


Slave [(none)] show variables like 'general_log%';
+------------------+----------------+
| Variable_name    | Value          |
+------------------+----------------+
| general_log      | OFF            |
| general_log_file | c79maslave.log |
+------------------+----------------+
2 rows in set (0.001 sec)



Slave [(none)] set global general_log=on;
Query OK, 0 rows affected (0.003 sec)

Slave [(none)] show variables like 'general_log%';
+------------------+----------------+
| Variable_name    | Value          |
+------------------+----------------+
| general_log      | ON             |
| general_log_file | c79maslave.log |
+------------------+----------------+
2 rows in set (0.001 sec)


[root@c79mamaster ~]# cat /var/lib/mysql/master1.log

[root@c79maslave ~]# cat /var/lib/mysql/c79maslave.log



# 配置文件的话（永久）

[root@c79mamaster ~]# vi /etc/my.cnf.d/server.cnf
[mysqld]
general_log=ON

```

正常情况的日志

```sh
# heartbeat日志，健康性查询

[root@c79mamaster ~]# tail -f /var/lib/mysql/master1.log
220101 15:06:22     28 Query    select user()
220101 15:06:32     22 Query    select user()
220101 15:06:42     26 Query    select user()


[root@c79maslave ~]# tail -f /var/lib/mysql/c79maslave.log
220101 15:06:22     14 Query    select user()
220101 15:06:32     14 Query    select user()
220101 15:06:42     14 Query    select user()

# 通过Mycat查询时

Mycat [MycatDB] select * from t1;
+-----+---------+
| id  | name    |
+-----+---------+
| 100 | xiaozhi |
+-----+---------+
1 row in set (0.002 sec)


220101 15:09:24     22 Query    SET names utf8
                    22 Field List       t1			# 查询slave，然后由slave去查询master（不是同步到slave了吗？查询有没有更新的意思？？）
220101 15:09:24     14 Query    show tables			# slave日志
220101 15:09:35     14 Query    select * from t1	# slave日志

# 通过Mycat更新时。需要先通过slave？？

Mycat [MycatDB] insert into t1 values (201,'littlecat');
Query OK, 1 row affected (0.005 sec)


220101 15:11:36     18 Query    BEGIN														# slave日志
                    18 Query    insert into t1 values (201,'littlecat')						# slave日志
                    18 Query    COMMIT /* implicit, from Xid_log_event */					# slave日志

220101 15:11:36     30 Query    SET names utf8;insert into t1 values (201,'littlecat')		# master日志




Mycat [MycatDB] select * from t1;
+-----+-----------+
| id  | name      |
+-----+-----------+
| 100 | xiaozhi   |
| 201 | littlecat |
+-----+-----------+
2 rows in set (0.002 sec)



Slave [db1] select * from t1;
+-----+-----------+
| id  | name      |
+-----+-----------+
| 100 | xiaozhi   |
| 201 | littlecat |
+-----+-----------+
2 rows in set (0.000 sec)



Master [db1] select * from t1;
+-----+-----------+
| id  | name      |
+-----+-----------+
| 100 | xiaozhi   |
| 201 | littlecat |
+-----+-----------+
2 rows in set (0.000 sec)


```

停止slave时，

```sh
# 查询

[root@c79maslave ~]# systemctl stop mariadb

Mycat [MycatDB] select * from t1;
ERROR 1184 (HY000): java.net.ConnectException: Connection refused	# 查询禁止了。。。。


Mycat [MycatDB] insert into t1 values (202,'littlecat2');	# 插入却可以，
Query OK, 1 row affected (0.003 sec)


220101 15:15:25     30 Query    insert into t1 values (202,'littlecat2')	# master日志



Mycat [MycatDB] select * from t1;	# 再次循序则可以，所以第一次是太快了？还没有heartbeat超时，还没认定slave跪了
+-----+------------+
| id  | name       |
+-----+------------+
| 100 | xiaozhi    |
| 201 | littlecat  |
| 202 | littlecat2 |
+-----+------------+
3 rows in set (0.002 sec)



220101 15:16:08     24 Query    SET names utf8;select * from t1		# master日志

# 恢复slave

[root@c79maslave ~]# systemctl start mariadb

[root@c79maslave ~]# mysql -e 'select * from db1.t1'
+-----+------------+
| id  | name       |
+-----+------------+
| 100 | xiaozhi    |
| 201 | littlecat  |
| 202 | littlecat2 |
+-----+------------+



```

停止master时

```sh
[root@c79mamaster ~]# systemctl stop mariadb


Mycat [MycatDB] select * from t1;	# 查询ok
+-----+------------+
| id  | name       |
+-----+------------+
| 100 | xiaozhi    |
| 201 | littlecat  |
| 202 | littlecat2 |
+-----+------------+
3 rows in set (0.002 sec)

220101 15:20:05      8 Query    SET names utf8;select * from t1	# slave日志


Mycat [MycatDB] insert into t1 values (203,'littlecat3');
Query OK, 1 row affected (10.004 sec)		# master无法取得联系，超时，最后放弃转向slave？？slave的用户权限太大了！，得设置不在slave上更新？？


220101 15:20:25      8 Query    insert into t1 values (203,'littlecat3')	# slave日志

# 重启master（有得修复slave？？）

[root@c79mamaster ~]# systemctl start mariadb

Slave [(none)] show slave status\G
             Slave_IO_Running: Yes	# 状态OK？
             Slave_SQL_Running: Yes

# 各个节点的状态

Master [db1] select * from t1;
+-----+------------+
| id  | name       |
+-----+------------+
| 100 | xiaozhi    |
| 201 | littlecat  |
| 202 | littlecat2 |
+-----+------------+
3 rows in set (0.000 sec)

Slave [db1] select * from t1;
+-----+------------+
| id  | name       |
+-----+------------+
| 100 | xiaozhi    |
| 201 | littlecat  |
| 202 | littlecat2 |
| 203 | littlecat3 |		# 通过Mycat插入到slave的记录，只有slave可见？？
+-----+------------+
4 rows in set (0.000 sec)


Mycat [MycatDB] select * from t1;
+-----+------------+
| id  | name       |
+-----+------------+
| 100 | xiaozhi    |
| 201 | littlecat  |
| 202 | littlecat2 |
+-----+------------+
3 rows in set (0.003 sec)



Mycat [MycatDB] show master status;	# 这个时候是指向master，所以才会和master一样？？上面的配置没有配置好分离？？
+--------------------+----------+--------------+------------------+
| File               | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+--------------------+----------+--------------+------------------+
| master1-bin.000011 |      344 |              | db5              |
+--------------------+----------+--------------+------------------+
1 row in set (0.003 sec)

Master [db1] show master status;
+--------------------+----------+--------------+------------------+
| File               | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+--------------------+----------+--------------+------------------+
| master1-bin.000011 |      344 |              | db5              |
+--------------------+----------+--------------+------------------+
1 row in set (0.000 sec)



[root@c79mamaster ~]# tail  /var/lib/mysql/master1.log
220101 15:27:03      6 Query    select * from t1	# 在主服务器上查询着。。


[root@c79maslave ~]# tail  /var/lib/mysql/c79maslave.log
220101 15:27:12     14 Query    select user()			# slave依旧存活，所以这里很明显就是读写没有好好分离

```

###### 
