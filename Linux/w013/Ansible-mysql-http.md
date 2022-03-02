# Linux Administrator

# 安装并配置Ansible

安装script

```sh
[root@vm1 ~]# cat install_ansible_pip.sh
#!/bin/bash
# usage: install ansible
# verison: 2022-03-02 New

echo "This script install ansible via pip (online), tested at AlmaLinux 8.5."

echo " Installing python39..."
dnf -y install python39 &> /dev/null && echo "Python39 installed." || echo "Python39 installation failed."
echo

echo " Installing ansible(this may cause much time)..."
pip3 install ansible &> /dev/null && echo " ansible installed" || echo "ansible installation failed."
echo

echo " ansible version:"
ansible --version

```

安装Ansible

```sh
[root@vm1 ~]# bash install_ansible_pip.sh
This script install ansible via pip (online), tested at AlmaLinux 8.5.
Installing python39...
Python39 installed.
Installing ansible...

 ansible installed
ansible version:
ansible [core 2.12.3]
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.9/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.9.6 (default, Oct 10 2021, 07:39:06) [GCC 8.5.0 20210514 (Red Hat 8.5.0-3)]
  jinja version = 3.0.3
  libyaml = True

```

配置Ansible

```sh
[root@vm1 ~]# cat /etc/ansible/hosts
[local]
manager ansible_connection=local

[db]
mysql ansible_host=192.168.20.21

```

配置ssh免密

```sh

[root@vm1 ~]# cat hosts
192.168.20.21
[root@vm1 ~]# cat set_ssh_key.sh
#!/bin/bash
# usage: copy ssh key to remote hosts, generate if necessary
# version: 2022-03-02 new

rpm -q sshpass &> /dev/null || { dnf -y install epel-release && dnf -y install sshpass; }

[ -f /root/.ssh/id_rsa ] || ssh-keygen -f /root/.ssh/id_rsa -P ''

[ -f hosts ] || { echo "you need to create a hosts file containing a list of ip first"; exit 1; }

read -s -p "Input the remote vm's password: " INPUT
export SSHPASS=$INPUT
echo $SSHPASS
while read ip; do
  sshpass -e ssh-copy-id -f -o StrictHostKeyChecking=no $ip
done < hosts

[root@vm1 ~]# bash set_ssh_key.sh
Input the remote vm's password: Koredesu22
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh -o 'StrictHostKeyChecking=no' '192.168.20.21'"
and check to make sure that only the key(s) you wanted were added.

```

ping测试

```sh
[root@vm1 ~]# ansible mysql -m ping
mysql | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}

```



# ansible-playbook实现MySQL的二进制部署

## shell安装MySQL

脚本

```sh

[root@mysql ~]# cat install_mysql_bin_online.sh
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

```

## Playbook安装MySQL

### 项目目录

```sh

[root@vm1 mysql8]# pwd
/root/ansible/mysql8
[root@vm1 mysql8]# ls -1
install_mysql_binary.yml
mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz
mysqld8.service
test.yml

```

### Playbook等文件

Playbook

```sh

[root@vm1 mysql8]# cat install_mysql_binary.yml
---
- hosts: mysql
  gather_facts: no
  vars:
    datadir: /data/mysql
    newpass: MySQL123!
  tasks:
    - name: stop mysql services if any
      service: name=mysqld8 state=stopped
      ignore_errors: yes

    - name: remote old pkgs
      shell: yum -y --quiet remove $(rpm -qa | grep -i -e mysql -e maria)
    - name: remote old datadir of yum install
      file: path=/var/lib/mysql state=absent
    - name: remove old log
      file: path=/var/log/mysqld.log state=absent
    - name: remove old datadir
      file: path={{ datadir }} state=absent
    - name: remove user
      user: name=mysql state=absent remove=yes
    - name: remove group
      group: name=mysql state=absent
    - name: add group
      group: name=mysql gid=360
    - name: add user
      user: name=mysql uid=360 group=mysql create_home=no system=yes


    - name: check if mysql program exist
      shell: ls /usr/local/mysql-8.0.11-linux-glibc2.12-x86_64
      register: mysqldir
    - name: extract tarball. you need to get it first
      unarchive: src=mysql-8.0.11-linux-glibc2.12-x86_64.tar.gz dest=/usr/local
      when: mysqldir.rc != 0

    - name: create symbol link
#      shell: chdir=/usr/local ln -sf mysql-8.0.11-linux-glibc2.12-x86_64 mysql
      file: src=/usr/local/mysql-8.0.11-linux-glibc2.12-x86_64 dest=/usr/local/mysql state=link
    - name: create my.cnf
      copy: dest=/etc/my.cnf content='[mysqld]\ndatadir = {{ datadir }}\n' force=yes

    - name: initialize database
      shell: "/usr/local/mysql/bin/mysqld --initialize --user=mysql --datadir={{ datadir }} 2> /var/log/mysqld.log"
      register: oldpass
    - name: get oldpass
      shell: "awk '/A temporary password/{print $NF}' /var/log/mysqld.log"
      register: oldpass


    - name: copy systemd unit
      copy: src=mysqld8.service dest=/etc/systemd/system/mysqld8.service
    - name: start mysqld8
      service: name=mysqld8 state=started
    - name: set mysql root passed
      shell: /usr/local/mysql/bin/mysqladmin -uroot -p{{ oldpass.stdout }} password "{{ newpass }}"
      register: error1
      ignore_errors: yes
    - name: show err
      debug:
        msg: "{{ error1 }}"

```

service

```sh

[root@vm1 mysql8]# cat mysqld8.service
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
ExecStart=/usr/local/mysql/bin/mysqld
# EnvironmentFile=-/etc/sysconfig/mysql
LimitNOFILE = 10000
Restart=on-failure
RestartPreventExitStatus=1
Environment=MYSQLD_PARENT_PID=1
PrivateTmp=false

```



### 执行

```sh

[root@vm1 mysql8]# ansible-playbook install_mysql_binary.yml

PLAY [mysql] *************************************************************************************************************************************************************************************************

TASK [stop mysql services if any] ****************************************************************************************************************************************************************************
changed: [mysql]

TASK [remote old pkgs] ***************************************************************************************************************************************************************************************
changed: [mysql]

TASK [remote old datadir of yum install] *********************************************************************************************************************************************************************
ok: [mysql]

TASK [remove old log] ****************************************************************************************************************************************************************************************
ok: [mysql]

TASK [remove old datadir] ************************************************************************************************************************************************************************************
ok: [mysql]

TASK [remove user] *******************************************************************************************************************************************************************************************
changed: [mysql]

TASK [remove group] ******************************************************************************************************************************************************************************************
ok: [mysql]

TASK [add group] *********************************************************************************************************************************************************************************************
changed: [mysql]

TASK [add user] **********************************************************************************************************************************************************************************************
changed: [mysql]

TASK [check if mysql program exist] **************************************************************************************************************************************************************************
changed: [mysql]

TASK [extract tarball. you need to get it first] *************************************************************************************************************************************************************
skipping: [mysql]

TASK [create symbol link] ************************************************************************************************************************************************************************************
ok: [mysql]

TASK [create my.cnf] *****************************************************************************************************************************************************************************************
ok: [mysql]

TASK [initialize database] ***********************************************************************************************************************************************************************************
changed: [mysql]

TASK [get oldpass] *******************************************************************************************************************************************************************************************
changed: [mysql]

TASK [copy systemd unit] *************************************************************************************************************************************************************************************
ok: [mysql]

TASK [start mysqld8] *****************************************************************************************************************************************************************************************
changed: [mysql]

TASK [set mysql root passed] *********************************************************************************************************************************************************************************
changed: [mysql]

TASK [show err] **********************************************************************************************************************************************************************************************
ok: [mysql] => {
    "msg": {
        "changed": true,
        "cmd": "/usr/local/mysql/bin/mysqladmin -uroot -pyyzJ?g.Po4k1 password \"MySQL123!\"",
        "delta": "0:00:00.073611",
        "end": "2022-03-02 12:39:20.960395",
        "failed": false,
        "msg": "",
        "rc": 0,
        "start": "2022-03-02 12:39:20.886784",
        "stderr": "mysqladmin: [Warning] Using a password on the command line interface can be insecure.\nWarning: Since password will be sent to server in plain text, use ssl connection to ensure password safety.",
        "stderr_lines": [
            "mysqladmin: [Warning] Using a password on the command line interface can be insecure.",
            "Warning: Since password will be sent to server in plain text, use ssl connection to ensure password safety."
        ],
        "stdout": "",
        "stdout_lines": []
    }
}

PLAY RECAP ***************************************************************************************************************************************************************************************************
mysql                      : ok=18   changed=10   unreachable=0    failed=0    skipped=1    rescued=0    ignored=0


```

### 查看结果

```sh

[root@mysql ~]# hostname -I
192.168.20.21

[root@mysql ~]# systemctl status mysqld8
● mysqld8.service - MySQL Server 8 GPL
   Loaded: loaded (/etc/systemd/system/mysqld8.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2022-03-02 12:39:20 CST; 3min 16s ago
     Docs: man:mysqld(8)
           http://dev.mysql.com/doc/refman/en/using-systemd.html
 Main PID: 11850 (mysqld)
   Status: "SERVER_OPERATING"
    Tasks: 37 (limit: 5807)
   Memory: 377.6M
   CGroup: /system.slice/mysqld8.service
           └─11850 /usr/local/mysql/bin/mysqld

Mar 02 12:39:19 mysql systemd[1]: Starting MySQL Server 8 GPL...
Mar 02 12:39:19 mysql mysqld[11850]: 2022-03-02T04:39:19.947685Z 0 [System] [MY-010116] [Server] /usr/local/mysql/bin/mysqld (mysqld 8.0.11) starting as process 11850
Mar 02 12:39:20 mysql mysqld[11850]: 2022-03-02T04:39:20.383687Z 0 [Warning] [MY-010068] [Server] CA certificate ca.pem is self signed.
Mar 02 12:39:20 mysql mysqld[11850]: 2022-03-02T04:39:20.415569Z 0 [System] [MY-010931] [Server] /usr/local/mysql/bin/mysqld: ready for connections. Version: '8.0.11'  socket: '/tmp/mysql.sock'  port: 3306>
Mar 02 12:39:20 mysql systemd[1]: Started MySQL Server 8 GPL.

```

日志

```sh

[root@mysql ~]# cat /var/log/mysqld.log
2022-03-02T04:39:12.241528Z 0 [System] [MY-013169] [Server] /usr/local/mysql/bin/mysqld (mysqld 8.0.11) initializing of server in progress as process 11465
2022-03-02T04:39:14.166469Z 5 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: yyzJ?g.Po4k1
2022-03-02T04:39:15.536970Z 0 [System] [MY-013170] [Server] /usr/local/mysql/bin/mysqld (mysqld 8.0.11) initializing of server has completed

```



# Ansible playbook实现apache批量部署

并对不同主机提供以各自IP地址为内容的index.html

# http的报文结构和状态码总结
