# Linux Administrator

# 1、网络分层模型对比



| OSI        | 5层        | TCP/IP     | 代表性协议            |
| ---------- | ---------- | ---------- | --------------------- |
| 应用层     |            |            | http, smtp, ftp       |
| 表示层     |            |            | gif, ascii            |
| 会话层     | 应用层     | 应用层     | rpc, nfs              |
| 传输层     | 传输层     | 传输层     | tcp, udp              |
| 网络层     | 互联网层   | 互联网层   | ip, ipx               |
| 数据链路层 | 数据链路层 | 网络接口层 | ppp, IEEE 802.3/802.2 |
| 物理层     | 物理层     |            | RJ45, ethernet        |



# 2、TCP三次握手和四次挥手总结

## 三次握手

客户端发送同步请求（syn-sent）服务器收到请求，发送响应（listen --> syn-recv）完成第一次握手（客户端半连接）

客户端接到响应，发送确认（syn-sent --> estab）完成第二次握手（服务器半连接，客户端全连接）

服务器收到客户端的确认（syn-recv -> estab）完成第三次握手，开始正式通信（服务器全连接）



## 四次挥手

客户端发送关闭请求（estab --> fin-wait-1），服务器收到并开始处理（estab）第一次挥手

服务器发出响应（estab --> close-wait），客户端收到（fin-wait-2）第二次挥手

服务器处理完后，服务器发出响应（close-wait --> last-ack）第三次挥手

客户端收到服务器的第二次响应后发出结束信息，等到超时后断开（time-wait），服务器收到客户端的回复后断开连接





# 3、对比TCP和UDP



| 属性     | TCP  | UDP  |
| -------- | ---- | ---- |
| 可靠连接 | Y    | N    |
| 面向连接 | Y    | N    |
| 错误检查 | Y    | less |
| 传输性能 | -    | High |
| 数据恢复 | Y    | N    |
|          |      |      |





# 4、用nmcli实现bonding



```sh
# bonding接口
[root@CentOS84T ~]# nmcli con add type bond con-name bond3 ifname bond3 mode active-backup ipv4.method manual ipv4.addresses 192.168.60.210/24
Connection 'bond3' (942b55d9-6455-4a9c-8dde-1b4b304e579f) successfully added.

# 从属接口。不指定连接名则，连接名为接口类型+接口名称
[root@CentOS84T ~]# nmcli con add type bond-slave ifname enp0s9 master bond3
Connection 'bond-slave-enp0s9' (36567dde-d11c-42fe-8356-fa2ee192ba67) successfully added.
[root@CentOS84T ~]# nmcli con add type bond-slave ifname enp0s10 master bond3
Connection 'bond-slave-enp0s10' (a664dd89-6019-4741-a9b8-214edc621c11) successfully added.

# 查看
[root@CentOS84T ~]# nmcli con show
NAME                UUID                                  TYPE      DEVICE
ethernet-enp0s3     574caa05-2d0f-424e-945f-32a3399a823f  ethernet  enp0s3
connecton3          1ab5555d-b773-430d-9e7d-2317aab531ec  ethernet  enp0s9
enp0s8              4eb19ee0-7246-41f6-a280-b5649378333b  ethernet  enp0s8
Wired connection 1  b61c7db6-0b8d-3a0c-8ca6-155f2718e84e  ethernet  enp0s10
bond1               92306dc1-4142-23de-097b-b1464cfab5ee  bond      bond1
bond3               942b55d9-6455-4a9c-8dde-1b4b304e579f  bond      bond3
bond-slave-enp0s10  a664dd89-6019-4741-a9b8-214edc621c11  ethernet  --
bond-slave-enp0s9   36567dde-d11c-42fe-8356-fa2ee192ba67  ethernet  --
enp0s3              c2a1a18d-3f25-423a-974e-9c1e90e6735a  ethernet  --
Wired connection 2  4a90ba1c-8b5e-3fba-af02-e700adf4714c  ethernet  --

# 启动从属接口

[root@CentOS84T ~]# nmcli con up bond-slave-enp0s9
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/9)
[root@CentOS84T ~]# nmcli con up bond-slave-enp0s10
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/10)


[root@CentOS84T ~]# nmcli con up bond3
Connection successfully activated (master waiting for slaves) (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/11)


[root@CentOS84T ~]# ip -br a
lo               UNKNOWN        127.0.0.1/8 ::1/128
enp0s3           UP             10.0.0.21/24 10.0.2.15/24 fe80::c662:230e:8975:4447/64
enp0s8           UP             192.168.50.19/24 fe80::a00:27ff:fe14:1052/64
enp0s9           UP		# 作为从属，本身的ip消失。这个是永久性的？？
enp0s10          UP
bond1            DOWN           192.168.60.123/24
bond3            UP             192.168.60.210/24 fe80::4f0e:5e93:ba13:b6c8/64


# 永久性设置
[root@CentOS84T ~]# ls /etc/sysconfig/network-scripts/ | grep bond
ifcfg-bond1
ifcfg-bond3
ifcfg-bond-slave-enp0s10
ifcfg-bond-slave-enp0s9


```



