# Linux Administrator



## 获取并安装Linux

### 配置虚拟机环境（VirtualBox）

略



### 下载Linux镜像文件ISO

**下载CentOS Minimal**

https://www.centos.org/centos-linux/
http://isoredirect.centos.org/centos/7/isos/x86_64/
http://ty1.mirror.newmediaexpress.com/centos/7.9.2009/isos/x86_64/

![CentOS-Download](imgs/CentOS-Download.jpg)

下载完后进行SHA265校验（在这里确保镜像完整的话，安装时直接安装一般没什么问题）

```
certutil -hashfile CentOS-7-x86_64-Minimal-2009.iso SHA256
```

![CentOS-Download-SHA256](imgs/CentOS-Download-SHA256.jpg)

**下载Ubuntu Desktop**

https://ubuntu.com/download/desktop
Ubuntu 20.04.3 LTS

截图略



**下载Ubuntu Server**

https://ubuntu.com/download/server

验证镜像文件SHA265（官方）

```
echo "f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98 *ubuntu-20.04.3-live-server-amd64.iso" | shasum -a 256 --check
```

没问题时的输出（官方）

```
ubuntu-20.04.3-live-server-amd64.iso: OK
```

验证的方法指导（官方）

https://ubuntu.com/tutorials/how-to-verify-ubuntu#1-overview

上面的"f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"应该就是文件的SHA265，下面在Windows下验证

```
certutil -hashfile ubuntu-20.04.3-live-server-amd64.iso SHA256
```

![Ubuntu-Server-SHA256](imgs/Ubuntu-Server-SHA256.jpg)



### 安装方法

安装到物理机

​	将下载的ISO文件烧录到DVD光盘，或者制作U盘启动；在BIOS设置电脑开机第一启动顺序为DVD或者U盘（临时或者永久，以具体主板设置为准）；启动后安装，流程同虚拟机；安装后去除DVD或者U盘，恢复电脑启动顺序设置（如果需要）。截图略

安装到虚拟机

​	见下方



### 安装Centos 7.9

新建虚拟机

![CentOS-install-VBOX-01](imgs/CentOS-install-VBOX-01.jpg)

创建硬盘，选择动态分配

![CentOS-install-VBOX-02](imgs/CentOS-install-VBOX-02.jpg)

挂载ISO镜像文件

![CentOS-install-VBOX-03](imgs/CentOS-install-VBOX-03.jpg)

启用网卡1，选择网络地址转换(NAT)，以便上网

![CentOS-install-VBOX-04](imgs/CentOS-install-VBOX-04.jpg)

启用网卡2，选择仅主机(Host-Only)网络，以便从宿主电脑访问客户机

![CentOS-install-VBOX-05](imgs/CentOS-install-VBOX-05.jpg)

开机，按需选择测试镜像还是安装CentOS系统

![CentOS-install-VBOX-06](imgs/CentOS-install-VBOX-06.jpg)

进入安装界面，选择语言

![CentOS-install-VBOX-08](imgs/CentOS-install-VBOX-08.jpg)

硬盘分区，选择手动(I will configure partitioning)

![CentOS-install-VBOX-09](imgs/CentOS-install-VBOX-09.jpg)

选择标准模式(Standard Partition)

![CentOS-install-VBOX-10](imgs/CentOS-install-VBOX-10.jpg)

按序追加分区

![CentOS-install-VBOX-11](imgs/CentOS-install-VBOX-11.jpg)

![CentOS-install-VBOX-12](imgs/CentOS-install-VBOX-12.jpg)

分区完成后，执行更改(Accept Changes)

![CentOS-install-VBOX-13](imgs/CentOS-install-VBOX-13.jpg)

开启网卡，修改主机名

![CentOS-install-VBOX-14](imgs/CentOS-install-VBOX-14.jpg)

设置网卡自启动

![CentOS-install-VBOX-15](imgs/CentOS-install-VBOX-15.jpg)

![CentOS-install-VBOX-16](imgs/CentOS-install-VBOX-16.jpg)

其他设置，关闭kdump等

![CentOS-install-VBOX-17](imgs/CentOS-install-VBOX-17.jpg)

点击开始安装(Begin Installation)，设置用户和密码，选择(Make this user adminstrator)以便执行sudo命令

![CentOS-install-VBOX-18](imgs/CentOS-install-VBOX-18.jpg)

![CentOS-install-VBOX-19](imgs/CentOS-install-VBOX-19.jpg)

安装后重启(Reboot)，旧的VirtualBOX需要手动移除光盘，新的直接重启，光盘自动移除

![CentOS-install-VBOX-20](imgs/CentOS-install-VBOX-20.jpg)

开机界面

![CentOS-install-VBOX-21](imgs/CentOS-install-VBOX-21.jpg)

![CentOS-install-VBOX-22](imgs/CentOS-install-VBOX-22.jpg)

登录，检查用户是否可以登录，硬盘分区和网卡是否启动

![CentOS-install-VBOX-23](imgs/CentOS-install-VBOX-23.jpg)



### 安装Ubuntu Server 20.04

新建虚拟机，同上，略

开机 ，

![Ubuntu-Server-install-01](imgs/Ubuntu-Server-install-01.jpg)

![Ubuntu-Server-install-02](imgs/Ubuntu-Server-install-02.jpg)

选择语言和键盘

![Ubuntu-Server-install-03](imgs/Ubuntu-Server-install-03.jpg)

![Ubuntu-Server-install-04](imgs/Ubuntu-Server-install-04.jpg)

设置网卡和查看网卡（默认启用全部网卡），按TAB键移动光标，按Enter键选择和确定

![Ubuntu-Server-install-05](imgs/Ubuntu-Server-install-05.jpg)

![Ubuntu-Server-install-06](imgs/Ubuntu-Server-install-06.jpg)

![Ubuntu-Server-install-07](imgs/Ubuntu-Server-install-07.jpg)

代理设置

![Ubuntu-Server-install-08](imgs/Ubuntu-Server-install-08.jpg)

备用镜像网址设置

![Ubuntu-Server-install-09](imgs/Ubuntu-Server-install-09.jpg)

硬盘分区和格式化，选择(Custom storage layout)进行手动分区（想偷懒则选默认设置）

![Ubuntu-Server-install-10](imgs/Ubuntu-Server-install-10.jpg)

选中(AVAILABLE DEVICES)，按Enter键显示菜单，选择(Add GPT Partition)新建分区

![Ubuntu-Server-install-11](imgs/Ubuntu-Server-install-11.jpg)

支持输入数字+单位，输入分区信息后按(Create)

![Ubuntu-Server-install-12](imgs/Ubuntu-Server-install-12.jpg)

![Ubuntu-Server-install-13](imgs/Ubuntu-Server-install-13.jpg)

重复新建分区步骤，完成其他分区的设置

![Ubuntu-Server-install-14](imgs/Ubuntu-Server-install-14.jpg)

![Ubuntu-Server-install-15](imgs/Ubuntu-Server-install-15.jpg)

![Ubuntu-Server-install-17](imgs/Ubuntu-Server-install-17.jpg)

![Ubuntu-Server-install-18](imgs/Ubuntu-Server-install-18.jpg)

新建完所需分区后，按(Done)

![Ubuntu-Server-install-19](imgs/Ubuntu-Server-install-19.jpg)

![Ubuntu-Server-install-20](imgs/Ubuntu-Server-install-20.jpg)

新建用户

![Ubuntu-Server-install-21](imgs/Ubuntu-Server-install-21.jpg)

安装SSH服务器

![Ubuntu-Server-install-22](imgs/Ubuntu-Server-install-22.jpg)

根据需要选择追加软件包

![Ubuntu-Server-install-23](imgs/Ubuntu-Server-install-23.jpg)

安装ing

![Ubuntu-Server-install-24](imgs/Ubuntu-Server-install-24.jpg)

安装更新，不喜欢可以取消

![Ubuntu-Server-install-25](imgs/Ubuntu-Server-install-25.jpg)

安装完毕，重启

![Ubuntu-Server-install-26](imgs/Ubuntu-Server-install-26.jpg)

重启报错，提示无法卸载光盘，查看挂载情况发现光盘已卸载（开机状态下也无法拔出，不是热插拔）

![Ubuntu-Server-install-27](imgs/Ubuntu-Server-install-27.jpg)

无视错误，按Enter，交给虚拟机处理

![Ubuntu-Server-install-28](imgs/Ubuntu-Server-install-28.jpg)

重启成功，用户登录

![Ubuntu-Server-install-29](imgs/Ubuntu-Server-install-29.jpg)

查看分区，网卡是否正常，SSHD服务是否启动

![Ubuntu-Server-install-30](imgs/Ubuntu-Server-install-30.jpg)



### 安装Ubuntu Desktop 20.04

具体步骤同上，图如下

![Ubuntu-install-1](imgs/Ubuntu-install-1.png)

![Ubuntu-install-2](imgs/Ubuntu-install-2.png)

![Ubuntu-install-3](imgs/Ubuntu-install-3.png)

![Ubuntu-install-4](imgs/Ubuntu-install-4.png)

![Ubuntu-install-5](imgs/Ubuntu-install-5.png)

![Ubuntu-install-6](imgs/Ubuntu-install-6.png)

![Ubuntu-install-7](imgs/Ubuntu-install-7.png)

![Ubuntu-install-8](imgs/Ubuntu-install-8.png)

![Ubuntu-install-9](imgs/Ubuntu-install-9.png)

![Ubuntu-install-10](imgs/Ubuntu-install-10.png)

![Ubuntu-install-11](imgs/Ubuntu-install-11.png)

![Ubuntu-install-12](imgs/Ubuntu-install-12.png)

![Ubuntu-install-13](imgs/Ubuntu-install-13.png)

![Ubuntu-install-14](imgs/Ubuntu-install-14.png)

![Ubuntu-install-15](imgs/Ubuntu-install-15.png)

![Ubuntu-install-16](imgs/Ubuntu-install-16.png)

![Ubuntu-install-17](imgs/Ubuntu-install-17.png)

![Ubuntu-install-18](imgs/Ubuntu-install-18.png)

![Ubuntu-install-19](imgs/Ubuntu-install-19.png)

![Ubuntu-install-20](imgs/Ubuntu-install-20.png)

![Ubuntu-install-21](imgs/Ubuntu-install-21.png)

![Ubuntu-install-22](imgs/Ubuntu-install-22.png)

![Ubuntu-install-23](imgs/Ubuntu-install-23.png)

![Ubuntu-install-24](imgs/Ubuntu-install-24.png)

![Ubuntu-install-25](imgs/Ubuntu-install-25.png)

![Ubuntu-install-26](imgs/Ubuntu-install-26.png)



### 初次登录Linux

**CentOS**

可用创建的账号登录（能不能执行sudo看创建时有没有Make this user adminsitrator），也可用root登录

**Ubuntu**

只能用创建的账号登录（创建的账号具有administrator权限，可以执行sudo）

root没有创建密码，无法用su命令切换，可用sudo + su命令切换

```bash
sudo su -
```

![Ubuntu-Server-install-31](imgs/Ubuntu-Server-install-31.jpg)



