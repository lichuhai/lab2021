# Linux Administrator



# 1、编写脚本实现登陆远程主机。

## 使用expect

创建用户

```sh
[root@vm7 ~]# useradd user10
[root@vm7 ~]# echo user10 | passwd user10 --stdin

```

安装expect

```sh
[root@vm7 ~]# dnf -y install expect

```

expect脚本

```sh
[root@vm7 ~]# cat remote-login-expect.sh
#!/usr/bin/expect
spawn ssh user10@192.168.50.19
expect {
 "yes/no" { send "yes\n" ; exp_continue }
 "password" { send "user10\n" }
}
interact

[root@vm7 ~]# chmod +x remote-login-expect.sh

```

远程登录

```sh
[root@vm7 ~]# ./remote-login-expect.sh
spawn ssh user10@192.168.50.19
The authenticity of host '192.168.50.19 (192.168.50.19)' can't be established.
ECDSA key fingerprint is SHA256:VsPpd3Lcszfd9HSkU9yiTKPOcqguu0V8LIqNa38D4lo.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.50.19' (ECDSA) to the list of known hosts.
user10@192.168.50.19's password:

[user10@vm7 ~]$ whoami
user10
[user10@vm7 ~]$ hostname -I
10.0.2.15 192.168.50.19 192.168.60.70
[user10@vm7 ~]$ logout
Connection to 192.168.50.19 closed.
[root@vm7 ~]#

```



## 使用shell脚本

通过shell脚本调用expect命令

```sh

[root@vm7 ~]# cat remote.sh
#!/bin/bash

rpm -q expect > /dev/null || dnf -y install expect > /dev/null

cat > expect.sh << EOL
#!/usr/bin/expect
spawn ssh user10@192.168.50.19
expect {
 "yes/no" { send "yes\n" ; exp_continue }
 "password" { send "user10\n" }
}
interact
EOL

expect ./expect.sh

```

执行

```sh

[root@vm7 ~]# bash remote.sh
spawn ssh user10@192.168.50.19
user10@192.168.50.19's password:
Last login: Sun Jan  9 13:28:01 2022 from 192.168.50.19
[user10@vm7 ~]$ whoami
user10
[user10@vm7 ~]$ logout
Connection to 192.168.50.19 closed.

```



# 2、生成10个随机数保存于数组中，并找出其最大值和最小值

脚本

```sh

[root@vm7 ~]# cat array.sh
#!/bin/bash
# compare numbers

[ -z "$1" ] && { echo "Usage: $0 'num of random'.";echo;exit 1; }

declare -i MIN MAX
declare -a NUMS
for ((i=0;i<$1;i++));do
  NUMS[$i]=$RANDOM
  [ $i -eq 0 ] && MIN=${NUMS[0]} && MAX=${NUMS[0]} && continue
  [ ${NUMS[$i]} -gt $MAX ] && MAX=${NUMS[$i]} && continue
  [ ${NUMS[$i]} -lt $MIN ] && MIN=${NUMS[$i]}
done
echo All random numbers are: ${NUMS[*]}
echo MAX: $MAX
echo MIN: $MIN

```

执行

```sh

[root@vm7 ~]# bash array.sh 10
All random numbers are: 26019 18926 25391 14130 26185 18141 3034 19746 2398 362
MAX: 26185
MIN: 362

```



# 3、输入若干个数值存入数组中，采用冒泡算法进行升序或降序排序

脚本

```sh

[root@vm7 ~]# cat sort-numbers.sh
#!/bin/bash
# check if input is ok
if [ -z "$2" ]; then
  echo Need more than one number
  exit 1
fi
if [[ ! "$*" =~ ^[0-9]*([[:space:]]|[0-9])*$ ]]; then
  echo invaild! only number allow
  exit 2
fi

# pass the input to a array
declare -a a

for i in $*; do
  a[${#a[*]}]=$i
done

#echo ${a[*]}

# sort from small to big
for ((i=0;i<${#a[*]}-1;i++)); do
  for ((j=$i+1;j<${#a[*]};j++));do
    if (( ${a[i]} > ${a[j]} ));then
      t=${a[i]}
      a[i]=${a[j]}
      a[j]=$t
    fi
  done
done

unset t
echo sorted:
echo ${a[*]}


```

执行

```sh

[root@vm7 ~]# bash sort-numbers.sh
Need more than one number
[root@vm7 ~]# bash sort-numbers.sh 2
Need more than one number
[root@vm7 ~]# bash sort-numbers.sh 2 x
invaild! only number allow
[root@vm7 ~]# bash sort-numbers.sh x
Need more than one number
[root@vm7 ~]# bash sort-numbers.sh 2 3 4 3 2 43 21 56 11 3
sorted:
2 2 3 3 3 4 11 21 43 56

```



# 4、总结查看系统负载的几种命令，top等

## uptime

```sh

[root@vm7 ~]# uptime
 17:47:35 up  4:46,  2 users,  load average: 0.13, 0.16, 0.09

```



## top / htop / bytop



```sh
# top
top - 17:48:34 up  4:47,  2 users,  load average: 0.08, 0.14, 0.09
Tasks: 110 total,   1 running, 109 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :    465.2 total,    123.4 free,    117.3 used,    224.5 buff/cache
MiB Swap:   2048.0 total,   2032.0 free,     16.0 used.    330.0 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
   3355 root      20   0       0      0      0 I   0.3   0.0   0:00.20 kworker/0:2-ata_sff
      1 root      20   0  172692   6896   4740 S   0.0   1.4   0:01.41 systemd

# dnf -y install bpytop
# dnf -y install htop


```



## sar

```sh
# 安装
dnf -y install sysstat

# 查看所有信息
sar -A 1 2

# 磁盘IO
sar -b 1 2

# swap
sar -W 1 2

# 系统负载
sar -q 1 2

```





# 5、编写脚本，使用for和while分别实现192.168.50.0/24网段内，地址是否能够ping通

## for

脚本

```sh
[root@vm7 ~]# cat ping_for.sh
#!/bin/bash

for i in {1..254} ; do
  ping -c1 -W1 192.168.50.$i > /dev/null && echo "[192.168.50.$i] is online." || echo "[192.168.50.$i] is failed."
done

```

输出

```sh

[root@vm7 ~]# bash ping_for.sh
[192.168.50.1] is online.
[192.168.50.2] is failed.
[192.168.50.3] is failed.
[192.168.50.4] is failed.
...
```



## while

脚本

```sh

[root@vm7 ~]# cat ping_while.sh
#!/bin/bash

i=1

while (( $i<255 ));do
  ping -c1 -W1 192.168.50.$i > /dev/null && echo "[192.168.50.$i] is online." || echo "[192.168.50.$i] is failed."
  let i++
done

```

执行

```sh

[root@vm7 ~]# bash ping_while.sh
[192.168.50.1] is online.
[192.168.50.2] is failed.
[192.168.50.3] is failed.
...
```





# 6、每周的工作日1:30，将/etc备份至/data/backup目录中，保存的文件名称格式 为“etcbak-yyyy-mm-dd_HH-MM.tar.xz”，其中日期是前一天的时间

```sh
# 备份命令
[root@vm7 ~]# tar -Jcvf /data/backup/etcbak-`date +"%F_%H-%M" --date=yesterday`.tar.xz /etc

# 创建目录
[root@vm7 ~]# mkdir /data/backup

# 创建任务（直接写出命令不会执行？？）
[root@vm7 ~]# crontab -l
30 1 * * 1-5 /usr/bin/tar -Jcvf /data/backup/etcbak-`date +"%F_%H-%M" --date=yesterday`.tar.xz /etc

```

脚本

```sh
# 脚本
[root@vm7 ~]# cat backup.sh
#!/bin/bash
[ -d /data/backup ] || mkdir /data/backup
/usr/bin/tar -Jcvf /data/backup/etcbak-`date +"%F_%H-%M" --date=yesterday`.tar.xz /etc

# 任务
[root@vm7 ~]# crontab -l
30 1 * * 1-5 /root/backup.sh

# 调整时间执行
[root@vm7 ~]# date -s"2022-01-10 01:29"

# 结果
[root@vm7 ~]# ls /data/backup
etcbak-2022-01-09_01-30.tar.xz


[root@vm7 ~]# tail -f /var/log/messages
Jan 10 01:30:01 vm7 systemd[1]: Started Session 34 of user root.
Jan 10 01:30:10 vm7 systemd[1]: session-34.scope: Succeeded.
...

```

