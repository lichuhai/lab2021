# Linux Administrator



## 重定向练习

### 1、显示/etc目录下，以非字母开头，后面跟了一个字母以及其它任意长度任意字符的文件或目录

```bash
[root@CentOS79 ~]# ls -a /etc | grep -e ^[^a-zA-Z]	# 非字母开头的
.
..
1abc.test
1.test
2abc.test
2.test
.java
.pwd.lock
.updated
[root@CentOS79 ~]# ls -a /etc | grep -e ^[^[:alpha:]][[:alpha:]].*
1abc.test
2abc.test
.java
.pwd.lock
.updated
[root@CentOS79 ~]# ls -a /etc | grep -e ^[^a-zA-Z][[:alpha:]]
1abc.test
2abc.test
.java
.pwd.lock
.updated
[root@CentOS79 ~]# ls -a /etc | grep -e ^[^[:alpha:]][[:alpha:]]
1abc.test
2abc.test
.java
.pwd.lock
.updated
[root@CentOS79 ~]# ls -a /etc | grep -e ^[^a-zA-Z][a-zA-Z]
1abc.test
2abc.test
.java
.pwd.lock
.updated

[root@CentOS79 ~]# ls -ad -1 /etc/[^a-zA-Z][a-zA-Z]*
/etc/1abc.test
/etc/2abc.test
[root@CentOS79 ~]# ls -a -1 /etc/[^a-zA-Z][a-zA-Z]*	# 点开头的不匹配？？
/etc/1abc.test

/etc/2abc.test:
.
..

```

### 2、复制/etc目录下所有以p开头，以非数字结尾的文件或目录到/tmp/mytest1目录中。

```bash
[root@CentOS79 ~]# mkdir /tmp/mytest1
[root@CentOS79 ~]# cp -r /etc/p*[^0-9] /tmp/mytest1/
[root@CentOS79 ~]# ls /tmp/mytest1/
pam.d      passwd   passwd.admin  pki       pm      postfix  prelink.conf.d  profile      profile.d  pulse
papersize  passwd-  passwd.root   plymouth  popt.d  ppp      printcap        profile.bak  protocols  python

```

### 3、将/etc/issue文件中的内容转换为大写后保存至/tmp/issue.out文件中

```bash
[root@CentOS79 ~]# cat /etc/issue
\S
Kernel \r on an \m
[root@CentOS79 ~]# tr [:lower:] [:upper:] < /etc/issue > /etc/issue.out
[root@CentOS79 ~]# cat /etc/issue.out
\S
KERNEL \R ON AN \M

[root@CentOS79 ~]#  tr 'a-z' 'A-Z' < /etc/issue > /etc/issue.out2
[root@CentOS79 ~]# cat /etc/issue.out2
\S
KERNEL \R ON AN \M

[root@CentOS79 ~]# cat /etc/issue | tr 'a-z' 'A-Z' > /tmp/issue.out3
[root@CentOS79 ~]# cat /tmp/issue.out3
\S
KERNEL \R ON AN \M

```

## 用户权限栗子

### 4、用户和组管理类命令的使用方法总结

```bash
用户管理命令
useradd	# 追加用户
usermod	# 修改用户
userdel	# 删除用户
id	# 查看用户ID
su	# 切换用户
sudo	# 用某用户的权限执行命令
passwd	# 修改用户密码
chage	# 修改用户密码策略
chfn	# 设置用户个人信息
chsh	# 设置用户登录shell
finger	# 查看用户个人信息
newusers	# 批量创建
chpasswd	# 批量修改用户密码

组管理命令
groupadd	# 追加用户组
groupmod	# 修改用户组
groupdel	# 删除用户组
gpasswd	# 修改用户组密码
newgrp	# 临时切换主组
groupmems	# 管理组
groups	# 查看组关系

```

#### (1)、创建组distro，其GID为2019；

```bash
[root@CentOS79 ~]# groupadd -g 2019 distro

```

#### (2)、创建用户mandriva, 其ID号为1005；基本组为distro；

```bash
[root@CentOS79 ~]# useradd mandriva -u 1005 -g distro
[root@CentOS79 ~]# id mandriva
uid=1005(mandriva) gid=2019(distro) groups=2019(distro)

```

#### (3)、创建用户mageia，其ID号为1100，家目录为/home/linux;

```bash
[root@CentOS79 ~]# useradd mageia -d /home/linux -u 1100
[root@CentOS79 ~]# id mageia
uid=1100(mageia) gid=1100(mageia) groups=1100(mageia)
[root@CentOS79 ~]# ls -ld /home/linux
drwx------. 3 mageia mageia 78 Nov 24 17:48 /home/linux

```

#### (4)、给用户mageia添加密码，密码为magege，并设置用户密码7天后过期

```bash
[root@CentOS79 ~]# echo magege | passwd --stdin mageia
Changing password for user mageia.
passwd: all authentication tokens updated successfully.
[root@CentOS79 ~]# passwd  -x 7 mageia
Adjusting aging data for user mageia.
passwd: Success

```

#### (5)、删除mandriva，但保留其家目录；

```bash
[root@CentOS79 ~]# userdel mandriva
[root@CentOS79 ~]# ls -ld /home/mandriva/
drwx------. 3 1005 distro 78 Nov 24 17:47 /home/mandriva/
[root@CentOS79 ~]# id mandriva
id: mandriva: no such user

```

#### (6)、创建用户slackware，其ID号为2002，基本组为distro，附加组peguin；

```bash
[root@CentOS79 ~]# groupadd peguin
[root@CentOS79 ~]# useradd -u 2002 -g distro -G peguin slackware
[root@CentOS79 ~]# id slackware
uid=2002(slackware) gid=2019(distro) groups=2019(distro),2020(peguin)

```

#### (7)、修改slackware的默认shell为/bin/tcsh；

```bash
[root@CentOS79 ~]# yum -y install tcsh
...
[root@CentOS79 ~]# chsh -l
/bin/sh
/bin/bash
/usr/bin/sh
/usr/bin/bash
/bin/tcsh
/bin/csh
[root@CentOS79 ~]# chsh -s /bin/tcsh slackware
Changing shell for slackware.
Shell changed.
[root@CentOS79 ~]# grep slackware /etc/passwd
slackware:x:2002:2019::/home/slackware:/bin/tcsh
[root@CentOS79 ~]# finger slackware | grep Shell
Directory: /home/slackware          	Shell: /bin/tcsh

```

#### (8)、为用户slackware新增附加组admins，并设置不可登陆。

```bash
[root@CentOS79 ~]# groupadd admins
[root@CentOS79 ~]# usermod -G -a admins -s /bin/nologin slackware
usermod: group '-a' does not exist
[root@CentOS79 ~]# usermod -a -G admins -s /bin/nologin slackware
[root@CentOS79 ~]# id slackware
uid=2002(slackware) gid=2019(distro) groups=2019(distro),2020(peguin),2021(admins)
[root@CentOS79 ~]# grep slackware /etc/passwd
slackware:x:2002:2019::/home/slackware:/bin/nologin

```

### 5、创建用户user1、user2、user3。在/data/下创建目录test

```bash
[root@CentOS79 ~]# cat > users.txt <<EOL
> user1:x:2001:2001::/home/user1:/bin/bash
> user2:x:2002:2002::/home/user2:/bin/bash
> user3:x:2003:2003::/home/user3:/bin/bash
> EOL
[root@CentOS79 ~]# cat users.txt 
user1:x:2001:2001::/home/user1:/bin/bash
user2:x:2002:2002::/home/user2:/bin/bash
user3:x:2003:2003::/home/user3:/bin/bash
[root@CentOS79 ~]# newusers users.txt 
[root@CentOS79 ~]# tail -3 /etc/passwd
user1:x:2001:2001::/home/user1:/bin/bash
user2:x:2002:2002::/home/user2:/bin/bash
user3:x:2003:2003::/home/user3:/bin/bash
[root@CentOS79 ~]# su user1
bash-4.2$ pwd
/root

[root@CentOS79 ~]# userdel user1 
[root@CentOS79 ~]# userdel user2
[root@CentOS79 ~]# userdel user3

[root@CentOS79 ~]# useradd user1
[root@CentOS79 ~]# useradd user2
[root@CentOS79 ~]# useradd user3

[root@CentOS79 test]# mkdir /data/test

```

#### (1)、目录/data/test属主、属组为user1

```bash
[root@CentOS79 ~]# mkdir /data/test
[root@CentOS79 ~]# chown user1 /data/test
[root@CentOS79 ~]# ls -ld /data/test
drwxr-xr-x. 2 user1 root 6 Nov 24 18:13 /data/test

```

#### (2)、在目录属主、属组不变的情况下，user2对文件有读写权限

```bash
[root@CentOS79 ~]# chmod o+w /data/test
[user2@CentOS79 root]$ echo test > /data/test/user2.txt
[user2@CentOS79 root]$ cat /data/test/user2.txt 
test

# 或者加入组，给组加写权限
[root@CentOS79 ~]# ls -ld /data/test
drwxr-xr-x. 2 user1 root 23 Nov 24 18:16 /data/test
[user2@CentOS79 root]$ echo test > /data/test/user2.txt
bash: /data/test/user2.txt: Permission denied
[root@CentOS79 ~]# usermod -a -G root user2
[root@CentOS79 ~]# chmod g+w /data/test
[user2@CentOS79 root]$ echo test > /data/test/user2.txt
[user2@CentOS79 root]$ cat /data/test/user2.txt 
test

```

#### (3)、user1在/data/test目录下创建文件a1.sh, a2.sh, a3.sh, a4.sh，设置所有用户都不可删除1.sh，2.sh文件、除了user1及root之外，所有用户都不可删除a3.sh, a4.sh

```bash
[root@CentOS79 test]# chmod o+t /data/test
[root@CentOS79 test]# ls -ld /data/test
drwxrwxr-t. 2 user1 root 6 Nov 24 18:23 /data/test

[user1@CentOS79 test]$ pwd
/data/test
[user1@CentOS79 test]$ touch a{1..4}.sh
[user1@CentOS79 test]$ ll
total 0
-rw-rw-r--. 1 user1 user1 0 Nov 24 18:27 a1.sh
-rw-rw-r--. 1 user1 user1 0 Nov 24 18:27 a2.sh
-rw-rw-r--. 1 user1 user1 0 Nov 24 18:27 a3.sh
-rw-rw-r--. 1 user1 user1 0 Nov 24 18:27 a4.sh

[user2@CentOS79 test]$ rm a1.sh 
rm: remove write-protected regular empty file ‘a1.sh’? y
rm: cannot remove ‘a1.sh’: Operation not permitted

[user3@CentOS79 test]$ rm a1.sh 
rm: remove write-protected regular empty file ‘a1.sh’? y
rm: cannot remove ‘a1.sh’: Permission denied

[user1@CentOS79 test]$ chattr +a a1.sh 
chattr: Operation not permitted while setting flags on a1.sh

[root@CentOS79 test]# chattr +a a{1,2}.sh
[root@CentOS79 test]# lsattr
-----a---------- ./a2.sh
---------------- ./a3.sh
---------------- ./a4.sh
-----a---------- ./a1.sh

[user1@CentOS79 test]$ rm a1.sh
rm: cannot remove ‘a1.sh’: Operation not permitted
[user1@CentOS79 test]$ rm a3.sh
[user1@CentOS79 test]$ ll
total 0
-rw-rw-r--. 1 user1 user1 0 Nov 24 18:30 a1.sh
-rw-rw-r--. 1 user1 user1 0 Nov 24 18:27 a2.sh
-rw-rw-r--. 1 user1 user1 0 Nov 24 18:27 a4.sh

```

#### (4)、user3增加附加组user1，同时要求user1不能访问/data/test目录及其下所有文件

```bash
[root@CentOS79 test]# usermod -a -G user1 user3
[root@CentOS79 test]# id user3
uid=2005(user3) gid=2005(user3) groups=2005(user3),2003(user1)

[root@CentOS79 test]# chown user03 /data/test
[root@CentOS79 test]# chmod o-t /data/test
[root@CentOS79 test]# chmod o-x /data/test


[root@CentOS79 test]# ll -d /data/test
drwxrwxr--. 2 user03 root 45 Nov 24 18:33 /data/test

[user1@CentOS79 ~]$ cd /data/test
bash: cd: /data/test: Permission denied

[root@CentOS79 ~]# ll -d /data/test
drwxrwxr-x+ 2 user03 root 45 Nov 24 18:33 /data/test
[root@CentOS79 ~]# getfacl /data/test
getfacl: Removing leading '/' from absolute path names
# file: data/test
# owner: user03
# group: root
user::rwx
user:user1:---	# 设置拒绝的facl
group::rwx
mask::rwx
other::r-x

[user1@CentOS79 root]$ cd /data/test
bash: cd: /data/test: Permission denied

[root@CentOS79 ~]# setfacl -x u:user1 /data/test
[root@CentOS79 ~]# getfacl /data/test
getfacl: Removing leading '/' from absolute path names
# file: data/test
# owner: user03
# group: root
user::rwx
group::rwx
mask::rwx
other::r-x
[user1@CentOS79 root]$ cd /data/test
[user1@CentOS79 test]$ pwd
/data/test

```

#### (5)、清理/data/test目录及其下所有文件的acl权限

```bash
[root@CentOS79 ~]# setfacl -b /data/test

```

