# Linux Administrator



## 1、统计出/etc/passwd文件中其默认shell为非/sbin/nologin的用户个数，并将用户都显示出来



```sh
# 方法1
[root@CentOS84vm2 scripts]# grep -v -E '.*/sbin/nologin$' /etc/passwd | awk -F: '{print $1}END{print "Total users:",NR}'
root
sync
shutdown
halt
hi
Total users: 5


# 方法2
[root@CentOS84vm2 scripts]# grep -v -e '/sbin/nologin' /etc/passwd | wc -l
5
[root@CentOS84vm2 scripts]# grep -v -e '/sbin/nologin' /etc/passwd | cut -d: -f1
root
sync
shutdown
halt
hi


```



## 2、查出用户UID最大值的用户名、UID及shell类型

```sh

[root@CentOS84vm2 scripts]# grep `grep -v -e '/sbin/nologin' /etc/passwd | cut -d: -f3 | sort -nr | head -n1` /etc/passwd | cut -d: -f1,3,7
hi:1000:/bin/bash


```



## 3、统计当前连接本机的每个远程主机IP的连接数，并按从大到小排序



```sh

[root@CentOS84vm2 scripts]# ss -ntu | awk -F' '  '{print $6}' | awk -F: '{print $1}' | grep -v Add | sort -nr | uniq -c | sort -k1 -r
      4 192.168.50.1
      1 192.168.50.9
      1 10.0.2.2



[root@CentOS84vm2 scripts]# ss -ntu | awk -F"[[:space:]]+|:"  '{print $7}' | grep -v Port | sort -nr | uniq -c  | sort -k1 -r
      4 192.168.50.1
      1 192.168.50.9
      1 10.0.2.2


```

更多

```sh
# 方法一，ss | awk | sort | uniq | sort
ss -nt4 | awk -F "[: ]+" 'NR>1 {print $(NF-2)}' | sort | uniq -c | sort -nr
# 方法二，ss | awk | awk | sort | uniq | sort 
ss -nt4 -H | awk '{print $5}'|awk -F: '{print $1}'| sort| uniq -c | sort -nr 
# 方法三，ss | grep | cut | sort | uniq | sort
ss -nt4 -H | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]*[[:space:]]*$" | cut -d: -f1 |sort| uniq -c| sort -nr


# 栗子

[root@vm7 ~]# ss -nt4 | awk -F "[: ]+" 'NR>1 {print $(NF-2)}' | sort | uniq -c | sort -nr
      2 192.168.50.1
[root@vm7 ~]# ss -nt4 -H | awk '{print $5}'|awk -F: '{print $1}'| sort| uniq -c | sort -nr
      2 192.168.50.1
[root@vm7 ~]# ss -nt4 -H | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]*[[:space:]]*$" | cut -d: -f1 |sort| uniq -c| sort -nr
      2 192.168.50.1

# 

[root@vm7 ~]# cat ss.log
State  Recv-Q    Send-Q          Local Address:Port        Peer Address:Port
ESTAB  0         36            192.168.223.110:22         33.93.235.53:60962
ESTAB  0         36            192.168.223.110:22         53.93.235.53:60962
ESTAB  0         36            192.168.223.110:22         53.93.235.53:60962
ESTAB  0         36            192.168.223.110:22         222.93.235.53:60962
ESTAB  0         36            192.168.223.110:22         222.93.235.52:60962
ESTAB  0         0             192.168.223.110:22         222.93.235.52:59556
ESTAB  0         36            192.168.223.110:22         222.93.235.53:60962
ESTAB  0         36            192.168.223.110:22         222.93.235.54:60962
ESTAB  0         36            192.168.223.110:22         33.93.235.53:60962
ESTAB  0         36            192.168.223.110:22         33.93.235.53:60962
ESTAB  0         36            192.168.223.110:22         53.93.235.53:60962
ESTAB  0         36            192.168.223.110:22         53.93.235.53:60962
ESTAB  0         36            192.168.223.110:22         53.93.235.53:60962


[root@vm7 ~]# cat ss.log | awk -F "[: ]+" 'NR>1 {print $(NF-2)}' | sort | uniq -c | sort -nr
     13 22
[root@vm7 ~]# cat ss.log | awk '{print $5}'|awk -F: '{print $1}'| sort| uniq -c | sort -nr
      5 53.93.235.53
      3 33.93.235.53
      2 222.93.235.53
      2 222.93.235.52
      1 Address
      1 222.93.235.54
[root@vm7 ~]# cat ss.log | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]*[[:space:]]*$" | cut -d: -f1 |sort| uniq -c| sort -nr
      5 53.93.235.53
      3 33.93.235.53
      2 222.93.235.53
      2 222.93.235.52
      1 222.93.235.54


```





## 4、编写脚本disk.sh，显示当前硬盘分区中空间利用率最大的值



```sh

[root@CentOS84vm2 scripts]# cat diskmax.sh
#!/bin/bash
# ----------------------------------------
# Script Name: diskusage.sh
# Author: Chuhai Li
# Email: xxx@xxx.com
# Website: https://xxx.com
# Purpose / Description: monitoring disk usage
# License: MIT
# Version: {Date}      {Who}      {Detail}
#          2021/12/03  Chuhai Li  New
#
# -----------------------------------------

#
SPACEUSED=`df | grep '^/dev/sd' | tr -s ' ' % | cut -d% -f5 | sort -nr | head -1`
echo "The Max disk usage: $SPACEUSED"


[root@CentOS84vm2 scripts]# bash diskmax.sh
The Max disk usage: 15

```





## 5、编写脚本 showSysInfo.sh，显示当前主机系统信息，包括:主机名，IPv4地址，操作系统版本，内核版本，CPU型号，内存大小，硬盘大小



```sh

[root@CentOS84vm2 scripts]# cat showSysInfo.sh
#!/bin/bash
# ----------------------------------------
# Script Name: showSysInfo.sh
# Author: Chuhai Li
# Email: xxx@xxx.com
# Website: https://xxx.com
# Purpose / Description: A showSysInfo script
# Usage:
#       ./template.sh
#       /{real full path}/tempalte.sh
#
# License: MIT
# Version: {Date}      {Who}      {Detail}
#          2021/12/03  Chuhai Li  New
#
# -----------------------------------------

# Configure display color
RED="\E[1;31m"
GREEN="echo -e \E[1;32m"
WHITE="\E[0m"

# show system infomation
${GREEN}-------------System Information-----------------------------${WHITE}
echo -e "Hostname:    ${RED}`hostname`${WHITE}"
echo -e "IPAddr:      ${RED}`ifconfig enp0s8 | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1`${WHITE}"
echo -e "OS:          ${RED}`cat /etc/redhat-release`${WHITE}"
echo -e "Kernel:      ${RED}`uname -r`${WHITE}"
echo -e "CPU:         ${RED}`lscpu | grep 'Model name' | tr -s ' ' | cut -d: -f2 | sed '/^[ ]/s# ##'`${WHITE}"
echo -e "Memory:      ${RED}`free -h | grep Mem | tr -s ' ' : | cut -d: -f2`${WHITE}"
echo -e "Disk:        ${RED}`lsblk | grep '^sd' | tr -s ' '| cut -d " " -f1,4`${WHITE}"
$GREEN-------------------------------------------------------------${WHITE}





[root@CentOS84vm2 scripts]# bash showSysInfo.sh
-------------System Information-----------------------------
Hostname:    CentOS84vm2
IPAddr:      192.168.50.19
OS:          CentOS Linux release 8.4.2105
Kernel:      4.18.0-305.3.1.el8.x86_64
CPU:         AMD Ryzen 5 5600U with Radeon Graphics
Memory:      465Mi
Disk:        sda 256G
-------------------------------------------------------------



```





## 6、20分钟内通关vimtutor



（可参考https://yyqing.me/post/2017/2017-02-22-vimtutor-chinese-summary）



