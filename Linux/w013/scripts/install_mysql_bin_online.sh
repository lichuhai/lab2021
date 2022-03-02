#!/bin/bash
# usage: install mysql online
# version: 2022-03-02 New

# set -e

echo "This script assume that is machine is a new machine and now any other mysql release here."
echo "Going to install MySQL 8.0"

echo

# Set env vars
datadir=/data/mysql
#binhome=
#pidfile=
newpass=MySQL123!

echo "Prepare system..."
rpm -e $(rpm -qa  | grep -i -e mysql -e mariadb) &> /dev/null

# hard to define a machine onw what pkgs...so always new os creation
# rpm -qa  | grep -i -e mysql -e mariadb &> /dev/null || echo "Failed to remove other mysql.." 

rm -f /etc/my.cnf &> /dev/null
rm -rf /usr/local/mysql-8.0.11-linux-glibc2.12-x86_64
rm -rf ${datadir}

echo "Install pre-request pkgs:"
dnf -y install libaio ncurses-compat-libs wget &> /dev/null

echo "Create group and user:"
userdel -r mysql &> /dev/null
groupdel mysql&> /dev/null
groupadd -r -g 360 mysql &> /dev/null
useradd -r -g 360 -u 360 -d ${datadir} mysql &> /dev/null
id mysql &> /dev/null || echo user create failed

# su mysql -c mkdir ${datadir}
# sudo -b -u mysql mkdir ${datadir}
ls -d ${datadir} &> /dev/null || mkdir ${datadir} && chown -R mysql:mysql ${datadir}

# download online or get it another way and put it in the same directory of this script
# wget https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz

echo "Unpacking installer..."
tar xf mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz -C /usr/local || echo "You need to get MySQL binary first."
cd /usr/local
ln -sf mysql-8.0.11-linux-glibc2.12-x86_64 mysql

chown -R root:root /usr/local/mysql/

echo "Make dirs:"
# mkdir -p /data/mysql
cat > /etc/my.cnf << _EOF_
[mysqld]
datadir = ${datadir}
_EOF_

echo "Init:"
mv /var/log/mysqld.log /var/log/mysqld.log.`date +%F`_$[RANDOM%1000]
cd mysql
bin/mysqld --initialize --user=mysql --datadir=${datadir} 2> /var/log/mysqld.log

oldpass=$(awk '/A temporary password/{print $NF}' /var/log/mysqld.log)

echo "Generate systemd unit file"

cat > /etc/systemd/system/mysqld8.service << _EOF_
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
_EOF_

systemctl daemon-reload
systemctl start mysqld8

echo "Change password"
bin/mysqladmin -uroot -p${oldpass} password ${newpass}

echo "Create client conf"
cat > ~/my.cnf << _EOF_
[client]
user=root
password=MySQL123!
_EOF_

echo "The END"
echo


