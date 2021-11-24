# Linux Administrator



## Linux发行版本

### Linux主流发行版本

主流发行版本：

| Linux系列 | Linux发行版本（例）                                          | 包管理器           |
| --------- | ------------------------------------------------------------ | ------------------ |
| 红帽      | RHEL，Fedora，CentOS，Oracle Linux，Rocky Linux，Miracle Linux | rpm，yum，dnf      |
| Debian    | Debian，Ubuntu，Kali，优麒麟，deepin，zorin，elementary  OS  | dpkg，apt，apt-get |
| Slackware | Slackware，SUSE                                              | slackpkg           |
| 其他      | Android-x86，Arch Linux                                      | -                  |

**各个发行版本之间的相同点**

​	同系的包管理器相同，代码基于同一个父版本，同样的Linux内核（相同或者不同版本）

**不同发行版本之间的区别**

​	默认shell可能不同，桌面可能不同，yum源 / apt源可能不同，系统配置文件可能有区别，特定发行版本有专用软件包（比如红帽subscription-manager）等



### 参考资料

Linux发行版本大全：

https://en.wikipedia.org/wiki/Comparison_of_Linux_distributions

Linux发行版本时间线：

https://upload.wikimedia.org/wikipedia/commons/8/8c/Linux_Distribution_Timeline_Dec._2020.svg



## 获取并安装Linux

[linux-install.md](linux-install.md)




## 配置history命令

相关配置文件

```
/etc/profile
~/.bash_profile
~/.bashrc
~/.bash_history
```

history命令相关环境变量

```
$HISTSIZE	# 记录历史命令条数
$HISTFILE	# 保存到文件
$HISTFILESIZE	# 保存到文件的历史命令条数
$HISTIGNORE	# 忽视的命令，不保存到文件
$HISTCONTROL	# 控制历史命令的记录（默认ignoredups）
$HISTTIMEFORMAT	# 历史命令的格式
```

配置history命令，记录命令执行的时间，

```
[root@CentOS79 ~]# HISTTIMEFORMAT="[%F %T `whoami` `tty`] "
[root@CentOS79 ~]# history
    1  [2021-11-20 15:16:12 root /dev/pts/1] ip -br a
    2  [2021-11-20 15:16:12 root /dev/pts/1] free -h
```

问题：同一个用户如果登录了多个终端，最终退出的时候，历史命令保留谁的

```
在配置文件里追加history相关设置
[root@CentOS79 ~]# tail -n 5 /etc/profile
## add

HISTTIMEFORMAT="[%F %T `whoami`] "
HISTTIMEFORMAT="[%F %T `whoami` `tty`] "

删除当前的 历史记录文件
[root@CentOS79 ~]# mv ~/.bash_history ~/.bash_history.bak

退出所有登录
重新登录，登录多个远程终端，各自执行命令
[root@CentOS79 ~]# w
 15:26:36 up 38 min,  3 users,  load average: 0.15, 0.06, 0.06
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    192.168.50.1     15:25    4.00s  0.00s  0.00s w
root     pts/1    192.168.50.1     15:26   12.00s  0.00s  0.00s -bash
root     pts/2    192.168.50.1     15:26    4.00s  0.01s  0.01s top

以下重新登录后执行的命令
[root@CentOS79 ~]# history
    1  [2021-11-20 15:24:15 root /dev/pts/0] history
    2  [2021-11-20 15:25:08 root /dev/pts/0] tail -n 5 /etc/profile
    3  [2021-11-20 15:25:33 root /dev/pts/0] mv ~/.bash_history ~/.bash_history.bak
    4  [2021-11-20 15:26:00 root /dev/pts/0] ls
    5  [2021-11-20 15:26:36 root /dev/pts/0] w
    6  [2021-11-20 15:27:05 root /dev/pts/0] history

[root@CentOS79 ~]# history
    1  [2021-11-20 15:24:15 root /dev/pts/1] history
    2  [2021-11-20 15:25:08 root /dev/pts/1] tail -n 5 /etc/profile
    3  [2021-11-20 15:25:33 root /dev/pts/1] mv ~/.bash_history ~/.bash_history.bak
    4  [2021-11-20 15:26:26 root /dev/pts/1] passwd user01
    5  [2021-11-20 15:27:29 root /dev/pts/1] history

[root@CentOS79 ~]# history
    1  [2021-11-20 15:24:15 root /dev/pts/2] history
    2  [2021-11-20 15:25:08 root /dev/pts/2] tail -n 5 /etc/profile
    3  [2021-11-20 15:25:33 root /dev/pts/2] mv ~/.bash_history ~/.bash_history.bak
    4  [2021-11-20 15:26:32 root /dev/pts/2] top
    5  [2021-11-20 15:27:40 root /dev/pts/2] history

全部退出后，再次登录
[root@CentOS79 ~]# history
    1  [2021-11-20 15:24:15 root /dev/pts/0] history
    2  [2021-11-20 15:25:08 root /dev/pts/0] tail -n 5 /etc/profile
    3  [2021-11-20 15:25:33 root /dev/pts/0] mv ~/.bash_history ~/.bash_history.bak
    4  [2021-11-20 15:26:32 root /dev/pts/0] top
    5  [2021-11-20 15:27:40 root /dev/pts/0] history
    6  [2021-11-20 15:26:26 root /dev/pts/0] passwd user01
    7  [2021-11-20 15:27:29 root /dev/pts/0] history
    8  [2021-11-20 15:26:00 root /dev/pts/0] ls
    9  [2021-11-20 15:26:36 root /dev/pts/0] w
   10  [2021-11-20 15:27:05 root /dev/pts/0] history

根据执行的时间可以确认，所有登录的命令都会被记录（不知为何tty的记录是动态的），先退出登录的先记录，且记录是追加模式，不会覆盖

查看历史记录文件可以发行，记录的格式更改了。（这里并没有记录时间，用户，tty等信息，从何得来的？）
[root@CentOS79 ~]# cat ~/.bash_history
#1637389455
history
#1637389508
```

问题：不记录passwd命令的执行，以下设置为何不能忽视修改密码的命令？

```
[root@CentOS79 ~]# HISTIGNORE="passwd:*passwd:passwd*:*passwd*:"
```



## Linux哲学思想

一切皆文件

配置都存在文本文件中（systemd的日志不是文本）



## Linux命令格式

**基本格式**

命令+空格+[选项]+[参数]

命令+空格+子命令

**例子**

```
[root@CentOS79 ~]# ls -l anaconda-ks.cfg
-rw-------. 1 root root 1642 Nov 20 11:30 anaconda-ks.cfg

[root@CentOS79 ~]# hostnamectl -h
hostnamectl [OPTIONS...] COMMAND ...

[root@CentOS79 ~]# hostnamectl --help
hostnamectl [OPTIONS...] COMMAND ...

[root@CentOS79 ~]# ip -br a
lo               UNKNOWN        127.0.0.1/8 ::1/128
enp0s3           UP             10.0.2.15/24 fe80::8542:71c1:f2fb:656d/64

[root@CentOS79 ~]# ip address show

[root@CentOS79 ~]# echo -e "hellp \n world"
hellp
 world

[root@CentOS79 ~]# date +"%F"
2021-11-20
```



## Linux的文件系统（FHS）

Linux的文件系统遵循FHS标准（Filesystem Hierarchy Standard）

主要目录

| 目录   | 用途                            |
| ------ | ------------------------------- |
| /      | 根                              |
| /bin   | 可执行程序                      |
| /boot  | 存放linux启动相关文件，内核文件 |
| /dev   | 设备                            |
| /etc   | 系统配置文件                    |
| /home  | 用户的家目录                    |
| /root  | root 的家目录                   |
| /lib   | 库文件                          |
| /lib64 | 库文件（64位）                  |
| /media | 媒体文件                        |
| /mnt   | 默认的挂载目录                  |
| /opt   | 三方软件的安装位置              |
| /proc  | 运行时的各种程序信息            |
| /run   | 运行时的各种程序信息            |
| /sbin  | 可执行程序（管理员）            |
| /sys   | 系统文件（链接）                |
| /tmp   | 临时文件                        |
| /usr   | 另存有bin，sbin等子目录         |
| /var   | 存放经常变动的文件，比如日志    |

