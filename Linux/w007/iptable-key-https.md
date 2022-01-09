# Linux Administrator

# 1、防止DOS攻击

## 描述

> 解决DOS攻击生产案例:根据web日志或者或者网络连接数，监控当某个IP 并发连接数或者短时内PV达到100，即调用防火墙命令封掉对应的IP，监控频 率每隔5分钟。防火墙命令为:iptables -A INPUT -s IP -j REJECT

## 设置网页服务器nginx

```sh
# 安装
[root@vm7 ~]# yum -y install nginx
# 启动
[root@vm7 ~]# systemctl start nginx
# 日志
[root@vm7 ~]# cat /var/log/nginx/access.log
# 访问
[root@vm7 ~]# curl http://192.168.60.70  --user-agent browser

```

日志

```sh

[root@vm7 ~]# cut -d- -f1 /var/log/nginx/access.log | sort -rn | uniq -c | sort -rn
     35 192.168.60.70
      9 ::1
      4 192.168.50.1
      1 192.168.50.19

```

脚本（判断日志文件）

```sh
[root@vm7 ~]# cat dos.sh
#!/bin/bash

MAX=10
cut -d- -f1 /var/log/nginx/access.log | sort -rn | uniq -c | sort -rn | while read count ip; do
  if [ $count -ge $MAX ]; then
    logger block dangerous ip access: $ip
    iptables -A INPUT -s $ip -j REJECT
  fi
done

[root@vm7 ~]# chmod +x dos.sh

```

设置启动任务

```sh

[root@vm7 ~]# crontab -l
*/5 * * * * /root/dos.sh

```

任务启动后（没有效果？）

```sh
[root@vm7 ~]# tail -f /var/log/messages
Jan 10 02:16:01 vm7 systemd[1]: Started Session 44 of user root.
Jan 10 02:16:01 vm7 root[22177]: block dangerous ip access: 192.168.60.70
...

# 然而

[root@vm7 ~]# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination

```

手动执行时

```sh

[root@vm7 ~]# /root/dos.sh
[root@vm7 ~]# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination
REJECT     all  --  vm7                  anywhere             reject-with icmp-port-unreachable

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
[root@vm7 ~]#

```



## 通过网络连接数

？有状态的？持久化连接？





# 2、描述密钥交换的过程



- 对称密钥
  - 双方实现会面交换
  - 通过非对称密钥
- 非对称密钥
  - 无CA
    - 直接把自己的公钥公开
    - 用其他人的公钥加密消息后发出去
    - 中间人攻击
  - 有CA
    - 直接把自己的公钥 / 证书公开
    - 把对方的证书和CA证书链对比，在链上的且状态OK的则使用之



# 3、https的通信过程

访问https网站时的密钥交换

- client访问webserver
- webserver提供证书
- client收到webserver证书后，验证是否在信任的证书链
- client验证webserver证书可信之后，利用webserver的公钥加密详细和client的公钥
- 协商后用双方支持的对称密钥算法生成密钥，用公钥传送
- 接着用对称密钥加密会话信息



# 4、使用awk以冒号分隔获取/etc/passwd文件第一列



```sh

[root@vm7 ~]# awk -F: '{print $1}' /etc/passwd
root
bin
daemon
adm
lp
sync
shutdown
halt
mail
operator
games
ftp
nobody
dbus
systemd-coredump
systemd-resolve
tss
polkitd
unbound
sssd
sshd
hi
dhcpd
apache
chrony
nginx
user34
user35
user36
mysql
ap
user10
user11

```

