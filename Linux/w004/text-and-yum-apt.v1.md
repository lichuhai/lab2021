# Linux Administrator

## 1、自建yum仓库

方式

- 直接用DVD光盘（本地源），或者复制文件问http / ftp站点的目录下（见上）
- 从0开始创建元数据，添加个别包
- 中继yum源（用户企业内外，类似win的sccm）

### 本地源

挂载DVD并配置本地yum源仓库

```bash
# 把光盘插进电脑，或者在虚拟机设置DVD

# 一般挂载在/mnt，长期使用的避免被覆盖，也可挂载在其他

[root@CentOS79 ~]$ ls /dev/cdrom	# 挂载才能访问
/dev/cdrom
[root@CentOS79 ~]$ ll /dev/cdrom
lrwxrwxrwx 1 root root 3 Nov 29 08:39 /dev/cdrom -> sr0

[root@CentOS79 ~]$ mount /dev/cdrom /mountdvd/
mount: /dev/sr0 is write-protected, mounting read-only
[root@CentOS79 ~]$ ls /mountdvd/
CentOS_BuildTag  EULA  images    LiveOS    repodata              RPM-GPG-KEY-CentOS-Testing-7
EFI              GPL   isolinux  Packages  RPM-GPG-KEY-CentOS-7  TRANS.TBL

# 设置开机自动挂载

[root@CentOS79 ~]$ blkid | grep iso
/dev/sr0: UUID="2020-11-03-14-55-29-00" LABEL="CentOS 7 x86_64" TYPE="iso9660" PTTYPE="dos"

[root@CentOS79 ~]$ umount /mountdvd/
[root@CentOS79 ~]$ blkid | grep iso	# 挂载过后UUID永久记录？？
/dev/sr0: UUID="2020-11-03-14-55-29-00" LABEL="CentOS 7 x86_64" TYPE="iso9660" PTTYPE="dos"
[root@CentOS79 ~]$ blkid
/dev/sda1: UUID="5e995ae8-38e4-49d4-98ab-31fd81a5cfc4" TYPE="ext4"
/dev/sda2: UUID="888945c4-aa95-4d82-8905-bbcc77b9b836" TYPE="xfs"
/dev/sda3: UUID="542c75d0-4bc4-44a1-9b4f-0ddae7ecbf7c" TYPE="xfs"
/dev/sda5: UUID="a88666f4-b215-44e1-b1b0-7721fbdaf68e" TYPE="swap"
/dev/sr0: UUID="2020-11-03-14-55-29-00" LABEL="CentOS 7 x86_64" TYPE="iso9660" PTTYPE="dos"

[root@CentOS79 ~]$ cp /etc/fstab{,.bak}

[root@CentOS79 ~]$ tail -n1 /etc/fstab
UUID="2020-11-03-14-55-29-00"             /mountdvd               iso9660 defaults        0 0

[root@CentOS79 ~]$ ls /mountdvd/
[root@CentOS79 ~]$ mount -a
mount: /dev/sr0 is write-protected, mounting read-only
[root@CentOS79 ~]$ ls /mountdvd/
CentOS_BuildTag  EULA  images    LiveOS    repodata              RPM-GPG-KEY-CentOS-Testing-7
EFI              GPL   isolinux  Packages  RPM-GPG-KEY-CentOS-7  TRANS.TBL

# 配置yum源


[root@CentOS79 ~]$ cat /etc/yum.repos.d/CentOS7-DVD.repo
[CentOS7-DVD]
name=CentOS7-DVD
baseurl=file:///mountdvd
gpgcheck=0
enabled=1


# 确认生效
[root@CentOS79 ~]$ yum repolist
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
epel/x86_64/metalink                                                                     | 5.0 kB  00:00:00
 * base: ftp-srv2.kddilabs.jp
 * epel: ftp.iij.ad.jp
 * extras: ftp-srv2.kddilabs.jp
 * updates: ftp-srv2.kddilabs.jp
CentOS7-DVD                                                                              | 3.6 kB  00:00:00
base                                                                                     | 3.6 kB  00:00:00
epel                                                                                     | 4.7 kB  00:00:00
extras                                                                                   | 2.9 kB  00:00:00
updates                                                                                  | 2.9 kB  00:00:00
(1/4): CentOS7-DVD/group_gz                                                              | 3.5 kB  00:00:00
(2/4): CentOS7-DVD/primary_db                                                            | 832 kB  00:00:00
(3/4): epel/x86_64/updateinfo                                                            | 1.0 MB  00:00:00
(4/4): epel/x86_64/primary_db                                                            | 7.0 MB  00:00:01
repo id                               repo name                                                           status
CentOS7-DVD                           CentOS7-DVD                                                            447
base/7/x86_64                         CentOS-7 - Base                                                     10,072
epel/x86_64                           Extra Packages for Enterprise Linux 7 - x86_64                      13,689
extras/7/x86_64                       CentOS-7 - Extras                                                      500
updates/7/x86_64                      CentOS-7 - Updates                                                   2,963
repolist: 27,671

```







### 网络源



创建私有yum：从本地DVD复制包等文件到httpd目录

```bash
[root@CentOS79 httpdpkgs]$ yum -y install httpd

[root@CentOS79 httpdpkgs]$ systemctl enable --now httpd

[root@CentOS79 httpdpkgs]$ systemctl status httpd

[root@CentOS79 httpdpkgs]$ mkdir /var/www/html/localrepo

[root@CentOS79 httpdpkgs]$ cp -a /mountdvd/* /var/www/html/localrepo/	# 和DVD相比也就是把文件复制了一下，放到网页服务器而已

# 查看文件，ftp也是可以的
http://192.168.50.15/localrepo

# 配置客户端的yum

[root@CentOS79 httpdpkgs]$ cat > /etc/yum.repos.d/web.repo <<EOL
> [webrepo]
> name=WebRepo
> baseurl=http://192.168.50.15/localrepo
> gpgcheck=0
> enabled=1
> EOL

[root@CentOS79 httpdpkgs]$ yum repolist | grep -e web -e dvd	# 和DVD一样
mountdvd          added from: file:///mountdvd                               447
webrepo           WebRepo                                                    447

# 测试

[root@CentOS79 ~]$ yum info rsync --disablerepo=* --enablerepo=webrepo
...
Repo        : webrepo
...

```



同步外网yum源1

```bash
# 栗子：同步系统extras源

[root@CentOS79 ~]$ yum repolist | grep -E ^extras
extras/7/x86_64   CentOS-7 - Extras                    500

[root@CentOS79 ~]$ mkdir /var/www/html/reposyncextras

# dnf reposync --repoid=extras --download-metadata -p /xxx
[root@CentOS79 ~]$ reposync --repoid=extras --download-metadata -p /var/www/html/reposyncextras
(1/500): ansible-collection-microsoft-sql-1.1.0-1.el7_9.noarch.rpm                       |  36 kB  00:00:00
(2/500): WALinuxAgent-2.2.32-1.el7.noarch.rpm                                            | 371 kB  00:00:00
(3/500): WALinuxAgent-2.2.38-2.el7_7.noarch.rpm                                          | 383 kB  00:00:00
(4/500): atomic-registries-1.22.1-26.gitb507039.el7.centos.x86_64.rpm                    |  35 kB  00:00:00
(5/500): WALinuxAgent-2.2.46-2.el7_9.noarch.rpm                                          | 420 kB  00:00:00
(6/500): atomic-registries-1.22.1-33.gitb507039.el7_8.x86_64.rpm                         |  36 kB  00:00:00
(7/500): atomic-1.22.1-33.gitb507039.el7_8.x86_64.rpm                                    | 917 kB  00:00:00
(8/500): atomic-registries-1.22.1-29.gitb507039.el7.x86_64.rpm                           |  35 kB  00:00:00
(9/500): atomic-1.22.1-29.gitb507039.el7.x86_64.rpm                                      | 916 kB  00:00:00
(10/500): atomic-1.22.1-26.gitb507039.el7.centos.x86_64.rpm                              | 916 kB  00:00:01
(11/500): cadvisor-0.4.1-0.3.git6906a8ce.el7.x86_64.rpm                                  | 1.9 MB  00:00:01
(12/500): centos-packager-0.5.5-2.el7.centos.noarch.rpm                                  |  18 kB  00:00:00
(13/500): centos-release-ansible-27-1-1.el7.noarch.rpm                                   | 3.9 kB  00:00:00


KeyboardInterrupt	# 有点多，意思意思就行
...

[root@CentOS79 ~]$ du -h /var/www/html/reposyncextras
422M    /var/www/html/reposyncextras/extras/Packages	# 没有meta。。。可另行创建
422M    /var/www/html/reposyncextras/extras
422M    /var/www/html/reposyncextras


[root@CentOS79 ~]$ yum -y install createrepo
[root@CentOS79 ~]$ createrepo /var/www/html/reposyncextras	# 创建repo的meta
Spawning worker 0 with 211 pkgs
Workers Finished
Saving Primary metadata
Saving file lists metadata
Saving other metadata
Generating sqlite DBs
Sqlite DBs complete


[root@CentOS79 ~]$ du -h /var/www/html/reposyncextras
422M    /var/www/html/reposyncextras/extras/Packages
422M    /var/www/html/reposyncextras/extras
352K    /var/www/html/reposyncextras/repodata
422M    /var/www/html/reposyncextras

# 配置yum
[root@CentOS79 ~]$ cat /etc/yum.repos.d/webextras.repo
[webrepoextras]
name=WebRepoExtras
baseurl=http://192.168.50.15/reposyncextras
gpgcheck=0
enabled=1

# 测试

[root@CentOS79 ~]$ yum info atomic --disablerepo=* --enablerepo=webrepoextras

Repo        : webrepoextras


[root@CentOS79 ~]$ yum -y install atomic --disablerepo=* --enablerepo=webrepoextras

Error: Package: 1:atomic-1.22.1-33.gitb507039.el7_8.x86_64 (webrepoextras)
           Requires: skopeo >= 1:0.1.29-3
Error: Package: 1:atomic-1.22.1-33.gitb507039.el7_8.x86_64 (webrepoextras)
           Requires: runc	# 依赖包不在这个源上
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest


[root@CentOS79 ~]$ yum --disablerepo=* --enablerepo=webrepoextras list available

```

栗子：同步阿里云

```bash
# 配置阿里云yum源
# https://developer.aliyun.com/mirror/
# epel
# https://mirrors.aliyun.com/epel/7Server/x86_64/
# https://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-7Server


[root@CentOS79 ~]$ cat /etc/yum.repos.d/Aliyun-Epel.repo
[aliyun-epel]
name=Aliyun-Epel
baseurl=https://mirrors.aliyun.com/epel/7Server/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-7Server


[root@CentOS79 ~]$ yum repolist
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: ftp.jaist.ac.jp
 * elrepo: ftp.ne.jp
 * epel: ftp.jaist.ac.jp
 * extras: ftp.jaist.ac.jp
 * updates: ftp.jaist.ac.jp
aliyun-epel                                                                              | 4.7 kB  00:00:00
(1/3): aliyun-epel/group_gz                                                              |  96 kB  00:00:01
(2/3): aliyun-epel/updateinfo                                                            | 1.0 MB  00:00:04
(3/3): aliyun-epel/primary_db                                                            | 7.0 MB  00:00:09
repo id                           repo name                                                               status
CentOS7-DVD-sh                    CentOS7-DVD-sh                                                             447
aliyun-epel                       Aliyun-Epel                                                             13,689
base/7/x86_64                     CentOS-7 - Base                                                         10,072
elrepo                            ELRepo.org Community Enterprise Linux Repository - el7                     144
epel/x86_64                       Extra Packages for Enterprise Linux 7 - x86_64                          13,689
extras/7/x86_64                   CentOS-7 - Extras                                                          500
mountdvd                          added from: file:///mountdvd                                               447
updates/7/x86_64                  CentOS-7 - Updates                                                       2,963
webrepo                           WebRepo                                                                    447
webrepoextras                     WebRepoExtras                                                              211
repolist: 42,609

# 同步阿里云epel


[root@CentOS79 ~]$ mkdir /var/www/html/repo-aliyun-epel
[root@CentOS79 ~]$ reposync --repoid=aliyun-epel --download-metadata -p /var/www/html/repo-aliyun-epel


aliyun-epel/group                                                                        | 391 kB  00:00:01
aliyun-epel/prestodelta                                                                  |  326 B  00:00:00
(1/13689): 0ad-0.0.22-1.el7.x86_64.rpm                                                   | 3.7 MB  00:00:12
(3/13689): 0install-2.11-1.el7.x86_64.rpm 0% [                                ] 3.2 MB/s |  35 MB  01:25:03 ETA
# 包超级多。。。

# 下载完后，配置本地的源，指向复制的阿里云yum，/var/www/html/repo-aliyun-epel
# 步骤同上，略


```







## 2、编译安装httpd2.4

下载httpd

```sh
[root@CentOS84vm3a ~]# mkdir httpd2.4.51

# httpd官网
# https://httpd.apache.org/download.cgi

[root@CentOS84vm3a httpd2.4.51]# wget https://dlcdn.apache.org//httpd/httpd-2.4.51.tar.gz
--2021-12-06 11:22:51--  https://dlcdn.apache.org//httpd/httpd-2.4.51.tar.gz
Resolving dlcdn.apache.org (dlcdn.apache.org)... 151.101.2.132, 2a04:4e42::644
Connecting to dlcdn.apache.org (dlcdn.apache.org)|151.101.2.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 9873874 (9.4M) [application/x-gzip]
Saving to: ‘httpd-2.4.51.tar.gz’

httpd-2.4.51.tar.gz    100%[==========================>]   9.42M  9.05MB/s    in 1.0s

2021-12-06 11:22:54 (9.05 MB/s) - ‘httpd-2.4.51.tar.gz’ saved [9873874/9873874]

```

安装编译环境

```sh
[root@CentOS84vm3a httpd2.4.51]# yum install gcc make autoconf gcc-c++ glibc glibc-devel pcre pcre-devel openssl openssl-devel systemd-devel zlib-devel vim lrzsz tree tmux lsof tcpdump wget net-tools iotop bc bzip2 zip unzip nfs-utils man-pages

```

apr

```sh
# 追加apr
[root@CentOS84vm3a httpd-2.4.51]# yum -y install apr apr-devel apr-util	# 这个安装了没有？没有可执行程序？
[root@CentOS84vm3a ~]# mkdir apr
[root@CentOS84vm3a ~]# cd apr
[root@CentOS84vm3a apr]# wget https://dlcdn.apache.org//apr/apr-1.7.0.tar.gz
[root@CentOS84vm3a apr]# wget https://www.apache.org/dist/apr/apr-1.7.0.tar.gz.sha256

[root@CentOS84vm3a apr]# sha256sum apr-1.7.0.tar.gz
48e9dbf45ae3fdc7b491259ffb6ccf7d63049ffacbc1c0977cced095e4c2d5a2  apr-1.7.0.tar.gz
[root@CentOS84vm3a apr]# cat apr-1.7.0.tar.gz.sha256
48e9dbf45ae3fdc7b491259ffb6ccf7d63049ffacbc1c0977cced095e4c2d5a2 *apr-1.7.0.tar.gz

[root@CentOS84vm3a apr]# tar -xzvf apr-1.7.0.tar.gz
[root@CentOS84vm3a apr]# cd apr-1.7.0/
[root@CentOS84vm3a apr-1.7.0]# ./configure --help

Installation directories:
  --prefix=PREFIX         install architecture-independent files in PREFIX
                          [/usr/local]
  --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
                          [PREFIX]

[root@CentOS84vm3a apr-1.7.0]# ./configure

rm: cannot remove 'libtoolT': No such file or directory

[root@CentOS84vm3a apr-1.7.0]# make
[root@CentOS84vm3a apr-1.7.0]# make install

[root@CentOS84vm3a apr]# cd /root/apr
[root@CentOS84vm3a apr-1.7.0]# wget https://dlcdn.apache.org//apr/apr-util-1.6.1.tar.gz
[root@CentOS84vm3a apr-1.7.0]# wget https://www.apache.org/dist/apr/apr-util-1.6.1.tar.gz.sha256

[root@CentOS84vm3a apr]# cat apr-util-1.6.1.tar.gz.sha256
b65e40713da57d004123b6319828be7f1273fbc6490e145874ee1177e112c459  apr-util-1.6.1.tar.gz
[root@CentOS84vm3a apr]# sha256sum apr-util-1.6.1.tar.gz
b65e40713da57d004123b6319828be7f1273fbc6490e145874ee1177e112c459  apr-util-1.6.1.tar.gz

[root@CentOS84vm3a apr]# tar -xzvf apr-util-1.6.1.tar.gz
[root@CentOS84vm3a apr]# cd apr-util-1.6.1/
[root@CentOS84vm3a apr-util-1.6.1]# ./configure --help
Installation directories:
  --prefix=PREFIX         install architecture-independent files in PREFIX
                          [/usr/local]
  --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
                          [PREFIX]

  --with-apr=PATH         prefix for installed APR or the full path to
                             apr-config

[root@CentOS84vm3a apr-util-1.6.1]# ./configure --with-apr=/usr/local/apr/bin/
[root@CentOS84vm3a apr-util-1.6.1]# make

r_xml.c && touch xml/apr_xml.lo
xml/apr_xml.c:35:10: fatal error: expat.h: No such file or directory
 #include <expat.h>
          ^~~~~~~~~
compilation terminated.
make[1]: *** [/root/apr/apr-util-1.6.1/build/rules.mk:206: xml/apr_xml.lo] Error 1
make[1]: Leaving directory '/root/apr/apr-util-1.6.1'
make: *** [/root/apr/apr-util-1.6.1/build/rules.mk:118: all-recursive] Error 1

[root@CentOS84vm3a apr-util-1.6.1]# yum -y install expat-devel

[root@CentOS84vm3a apr-util-1.6.1]# make
[root@CentOS84vm3a apr-util-1.6.1]# make install

```

解压，编译并安装

```sh

[root@CentOS84vm3a httpd2.4.51]# tar -xzvf httpd-2.4.51.tar.gz
[root@CentOS84vm3a httpd2.4.51]# cd httpd-2.4.51/
[root@CentOS84vm3a httpd-2.4.51]# ./configure --help

  --prefix=PREFIX         install architecture-independent files in PREFIX
                          [/usr/local/apache2]
  --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
                          [PREFIX]
                          
  --with-included-apr     Use bundled copies of APR/APR-Util
  --with-apr=PATH         prefix for installed APR or the full path to
                             apr-config
  --with-apr-util=PATH    prefix for installed APU or the full path to

# 编译到默认目录
[root@CentOS84vm3a httpd-2.4.51]# ./configure

configure:
checking for APR... no
configure: error: APR not found.  Please read the documentation.

[root@CentOS84vm3a httpd-2.4.51]#  ls /usr/local/apr/bin
apr-1-config  apu-1-config

[root@CentOS84vm3a httpd-2.4.51]# ./configure --with-apr=/usr/local/apr/bin --with-apr-util=/usr/local/apr/bin

configure: summary of build options:

    Server Version: 2.4.51
    Install prefix: /usr/local/apache2
    C compiler:     gcc
    CFLAGS:          -g -O2 -pthread
    CPPFLAGS:        -DLINUX -D_REENTRANT -D_GNU_SOURCE
    LDFLAGS:
    LIBS:
    C preprocessor: gcc -E


[root@CentOS84vm3a httpd-2.4.51]# make

collect2: error: ld returned 1 exit status
make[2]: *** [Makefile:48: htpasswd] Error 1
make[2]: Leaving directory '/root/httpd2.4.51/httpd-2.4.51/support'
make[1]: *** [/root/httpd2.4.51/httpd-2.4.51/build/rules.mk:75: all-recursive] Error 1
make[1]: Leaving directory '/root/httpd2.4.51/httpd-2.4.51/support'
make: *** [/root/httpd2.4.51/httpd-2.4.51/build/rules.mk:75: all-recursive] Error 1

[root@CentOS84vm3a httpd-2.4.51]# yum -y install autoconf libtool


[root@CentOS84vm3a httpd-2.4.51]# rpm -qa | grep -e autoconf -e libtool
autoconf-2.69-29.el8.noarch
libtool-2.4.6-25.el8.x86_64



[root@CentOS84vm3a apr]# mv apr-1.7.0 apr-util-1.6.1 ../httpd2.4.51/httpd-2.4.51/srclib/


NG。。。

# yum安装apr套件
[root@CentOS79 httpd-2.4.51]$ yum -y install apr-devel apr-util-devel apr apr-util

# 换个目录
[root@CentOS84vm3a httpd-2.4.51]# ./configure --prefix=/data/app/httpd --sysconfdir=/etc/httpd --enable-ssl

configure: summary of build options:

    Server Version: 2.4.51
    Install prefix: /data/app/httpd
    C compiler:     gcc
    CFLAGS:           -pthread
    CPPFLAGS:        -DLINUX -D_REENTRANT -D_GNU_SOURCE
    LDFLAGS:
    LIBS:
    C preprocessor: gcc -E

[root@CentOS84vm3a httpd-2.4.51]# make -j 4 && make install

make[1]: Leaving directory '/root/httpd2.4.51/httpd-2.4.51'
make: *** [/root/httpd2.4.51/httpd-2.4.51/build/rules.mk:75: all-recursive] Error 1

# 不知道爆什么错，分开重来
[root@CentOS84vm3a httpd-2.4.51]# make
[root@CentOS84vm3a httpd-2.4.51]# make install

Installing configuration files
mkdir /etc/httpd/extra
mkdir /etc/httpd/original
mkdir /etc/httpd/original/extra
Installing HTML documents
mkdir /data/app/httpd/htdocs
Installing error documents
mkdir /data/app/httpd/error
Installing icons
mkdir /data/app/httpd/icons
mkdir /data/app/httpd/logs
Installing CGIs
mkdir /data/app/httpd/cgi-bin
Installing header files
mkdir /data/app/httpd/include
Installing build system files
mkdir /data/app/httpd/build
Installing man pages and online manual
mkdir /data/app/httpd/man
mkdir /data/app/httpd/man/man1
mkdir /data/app/httpd/man/man8
mkdir /data/app/httpd/manual

[root@CentOS84vm3a httpd]# cd /data/app/httpd
[root@CentOS84vm3a httpd]# pwd
/data/app/httpd


[root@CentOS84vm3a httpd]# /data/app/httpd/bin/apachectl -h

[root@CentOS84vm3a httpd]# /data/app/httpd/bin/apachectl -t
httpd: Could not open configuration file /usr/local/apache2/conf/httpd.conf: No such file or directory




```







## 3、利用sed 取出ifconfig命令中本机的IPv4地址



## 4、删除/etc/fstab文件中所有以#开头，后面至少跟一个空白字符的行的行首的#和空白字符



## 5、处理/etc/fstab路径,使用sed命令取出其目录名和基名





## 6、apt的一些用法总结

