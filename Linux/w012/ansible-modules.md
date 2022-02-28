# Linux Administrator

[toc]



# ansible常用模块介绍

## command

在远程主机执行命令，默认

不支持：$VAR，<，>，|，;，&等（需要使用这类的话用shell模块）

不具幂等性



栗子

```sh
# help
[root@ansible ~]# ansible-doc command

[root@ansible ~]# ansible node2 -a 'echo hello'
node2 | CHANGED | rc=0 >>
hello

[root@ansible ~]# ansible node2 -m command -a 'echo hello'
node2 | CHANGED | rc=0 >>
hello

# 空格隔开多个命令

[root@ansible ~]# ansible node2 -m command -a 'chdir=/etc cat redhat-release'
node2 | CHANGED | rc=0 >>
AlmaLinux release 8.5 (Arctic Sphynx)

# 直接执行os命令

[root@ansible ~]# ansible node2 -m command -a 'systemctl restart httpd'
node2 | CHANGED | rc=0 >>

# 单引号变量不展开
[root@ansible ~]# ansible node2 -m command -a 'echo $HOSTNAME'
node2 | CHANGED | rc=0 >>
$HOSTNAME

[root@ansible ~]# ansible node2 -m command -a "echo $HOSTNAME"
node2 | CHANGED | rc=0 >>
ansible

[root@ansible ~]# ansible node2 -m command -a 'creates=/tmp/ans.txt'
node2 | FAILED | rc=256 >>
no command given


# 不会创建目录？？
[root@ansible ~]# ansible node2 -m command -a 'creates=/tmp/ans.txt echo 1'

node2 | CHANGED | rc=0 >>
1
[root@ansible ~]# ls /tmp/ans.txt
ls: cannot access '/tmp/ans.txt': No such file or directory

[root@ansible ~]# ansible node2 -m command -a 'chdir=/tmp creates=ans cat fork'


```



## shell

功能和command类似，支持比command全面

不具幂等性



语法

```
[root@ansible ~]# ansible-doc shell

```

栗子

```sh
# 单引号也行

[root@ansible ~]# ansible node2 -m shell -a "echo $HOSTNAME"
node2 | CHANGED | rc=0 >>
ansible
[root@ansible ~]# ansible node2 -m shell -a 'echo $HOSTNAME'
node2 | CHANGED | rc=0 >>
ansible



[root@ansible ~]# ansible node2 -m shell -a 'useradd user01'
node2 | CHANGED | rc=0 >>

[root@ansible ~]# id user01
uid=1002(user01) gid=1002(user01) groups=1002(user01)

[root@ansible ~]# ansible node2 -m shell -a 'echo user01 | passwd --stdin user01'
node2 | CHANGED | rc=0 >>
Changing password for user user01.
passwd: all authentication tokens updated successfully.



[root@ansible ~]# ansible node2 -m shell -a 'echo ansible-shell > /tmp/ans.txt'https://docs.ansible.com/ansible-core/2.12/reference_appendices/interpreter_discovery.html for more information.
node2 | CHANGED | rc=0 >>

[root@ansible ~]# ansible node2 -m shell -a 'cat /tmp/ans.txt'
node2 | CHANGED | rc=0 >>
ansible-shell



```



复杂的命令用shell也可能会失败（解决方法之一：用脚本，使之在远程执行脚本后返回结果）

```sh
[root@ansible ~]# ansible node2 -m shell -a "cat /tmp/ans.txt | awk -F'-' '{print $2}'"
node2 | CHANGED | rc=0 >>
ansible-shell	# 执行结果不一样

[root@ansible ~]# cat /tmp/ans.txt | awk -F'-' '{print $2}'
shell

# 用script模块（脚本无需执行权限。用bash执行的？）
# 见下
```



## script

脚本无需执行权限，也可不写shebang

不具有幂等性

语法

```sh
[root@ansible ~]# ansible-doc script

```

栗子

```sh
[root@ansible ~]# cat ans_test.sh
cat /tmp/ans.txt | awk -F'-' '{print $2}'

[root@ansible ~]# ll ans_test.sh
-rw-r--r-- 1 root root 43 Jan  3 14:46 ans_test.sh

[root@ansible ~]# ansible node2 -m script -a ans_test.sh
node2 | CHANGED => {
    "changed": true,
    "rc": 0,
    "stderr": "Shared connection to 192.168.50.62 closed.\r\n",
    "stderr_lines": [
        "Shared connection to 192.168.50.62 closed."
    ],
    "stdout": "shell\r\n",
    "stdout_lines": [
        "shell"		# 输出
    ]
}

[root@ansible ~]# cat /tmp/ans.txt
ansible-shell_remote_exe


[root@ansible ~]# ansible node2 -m script -a ans_test.sh
node2 | CHANGED => {
    "changed": true,
    "rc": 0,
    "stderr": "Shared connection to 192.168.50.62 closed.\r\n",
    "stderr_lines": [
        "Shared connection to 192.168.50.62 closed."
    ],
    "stdout": "shell_remote_exe\r\n",
    "stdout_lines": [
        "shell_remote_exe"	# 输出
    ]
}

```

带参数

```sh
[root@ansible ~]# cat ans_test2.sh
echo $1

[root@ansible ~]# ansible node2 -m script -a "ans_test2.sh hi_ans"
node2 | CHANGED => {
    "changed": true,
    "rc": 0,
    "stderr": "Shared connection to 192.168.50.62 closed.\r\n",
    "stderr_lines": [
        "Shared connection to 192.168.50.62 closed."
    ],
    "stdout": "hi_ans\r\n",
    "stdout_lines": [
        "hi_ans"	# 输出
    ]
}


```

## copy

（复制：复制文件，然后设置权限，属性等。复制文件夹。凭空生产文件等）

复制文件到远程主机

scr=file没有写绝对路径，则默认当前目录，或者当前目录下的files下的file文件

```sh
[root@ansible ~]# ansible-doc copy

```

栗子

```sh
# backup=yes 存在时先备份

[root@ansible ~]# ansible node2 -m copy -a "src=/root/ans_test.sh dest=/tmp/test.sh owner=admin01 mode=777 backup=yes "
node2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.9"
    },
    "changed": true,
    "checksum": "25c4950725ee6dd1547e2b8aefad250e33e39ae3",
    "dest": "/tmp/test.sh",
    "gid": 0,
    "group": "root",
    "md5sum": "3711373cbb153b565574e97889bacde9",
    "mode": "0777",
    "owner": "admin01",
    "size": 43,
    "src": "/root/.ansible/tmp/ansible-tmp-1641189381.7970076-17769-56897675460356/source",
    "state": "file",
    "uid": 1001
}
[root@ansible ~]# ll /tmp/test.sh
-rwxrwxrwx 1 admin01 root 43 Jan  3 14:56 /tmp/test.sh

# 再执行一次看看备份（没有copy？幂等了？）


[root@ansible ~]# ansible node2 -m copy -a "src=/root/ans_test.sh dest=/tmp/test.sh owner=admin01 mode=777 backup=yes "
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.9"
    },
    "changed": false,	# 没有更改（这个不准）
    "checksum": "25c4950725ee6dd1547e2b8aefad250e33e39ae3",
    "dest": "/tmp/test.sh",
    "gid": 0,
    "group": "root",
    "mode": "0777",
    "owner": "admin01",
    "path": "/tmp/test.sh",
    "size": 43,
    "state": "file",
    "uid": 1001
}
[root@ansible ~]# ls /tmp | grep test
test.sh
[root@ansible ~]#

# 换个属主看看（没有备份）

[root@ansible ~]# ansible node2 -m copy -a "src=/root/ans_test.sh dest=/tmp/test.sh owner=user01 mode=777 backup=yes "
node2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.9"
    },
    "changed": true,
    "checksum": "25c4950725ee6dd1547e2b8aefad250e33e39ae3",
    "dest": "/tmp/test.sh",
    "gid": 0,
    "group": "root",
    "mode": "0777",
    "owner": "user01",
    "path": "/tmp/test.sh",
    "size": 43,
    "state": "file",
    "uid": 1002
}
[root@ansible ~]# ls /tmp | grep test
test.sh
[root@ansible ~]# ll /tmp/test.sh
-rwxrwxrwx 1 user01 root 43 Jan  3 14:56 /tmp/test.sh



```

直接生产文件

```sh
[root@ansible ~]# ansible node2 -m copy -a "content='ansible copy test  line1\n use content to create line2\n' dest=/tmp/copy.con"
node2 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.9"
    },
    "changed": true,
    "checksum": "cb5e5198dcad9ada07b319f20f92d9ed0a88cf75",
    "dest": "/tmp/copy.con",
    "gid": 0,
    "group": "root",
    "md5sum": "d9ce09821f40e700a61f5946051b9714",
    "mode": "0644",
    "owner": "root",
    "size": 54,
    "src": "/root/.ansible/tmp/ansible-tmp-1641189711.3834193-18332-33500697427313/source",
    "state": "file",
    "uid": 0
}

[root@ansible ~]# cat /tmp/copy.con
ansible copy test  line1
 use content to create line2
[root@ansible ~]#

```

复制目录（本身）

```sh
# 目录后没有斜杠/

[root@ansible ~]# ansible node2 -m copy -a "src=/etc/ansible dest=/tmp/backup1"
node2 | FAILED! => {
    "msg": "A vault password or secret must be specified to decrypt /etc/ansible/hello_root.yml"
}

# 有加密时需要指定交互式输入密码。不然只复制其他没有加密的。failed但是也复制了

[root@ansible ~]# ls /tmp/backup1/ansible/
hello.yml  hosts  test


# 换个目录


[root@ansible ~]# ansible node2 -m copy -a "src=/etc/rc.d dest=/tmp/backup1"
node2 | CHANGED => {
    "changed": true,
    "dest": "/tmp/backup1/",
    "src": "/etc/rc.d"
}

[root@ansible ~]# ls /tmp/backup1
ansible  rc.d

[root@ansible ~]# ls /tmp/backup1/rc.d/
init.d  rc0.d  rc1.d  rc2.d  rc3.d  rc4.d  rc5.d  rc6.d  rc.local


```

复制目录（子文件和子文件夹）

```sh
# 有斜杆/


[root@ansible ~]# ansible node2 -m copy -a "src=/etc/rc.d/ dest=/tmp/backup2"
node2 | CHANGED => {
    "changed": true,
    "dest": "/tmp/backup2/",
    "src": "/etc/rc.d/"
}
[root@ansible ~]# ls /tmp/backup2
init.d  rc0.d  rc1.d  rc2.d  rc3.d  rc4.d  rc5.d  rc6.d  rc.local


```

## get_url

功能：从http，https，ftp上，下载文件到远程主机

```sh
[root@ansible ~]# ansible-doc get_url
Downloads files from HTTP, HTTPS, or FTP to the remote server. 


url				# 路径
url_password	# 基本认证的账户
url_username

dest			# 如果是目录，则文件用原来的名
tmp_dest		# 临时？
force			# 强制覆盖文件

mode			# 权限相关
owner
group

attributes
backup
checksum		# 计算摘要
sha256sum
client_cert		# 证书
client_key

force_basic_auth
headers
http_agent	# 模拟什么浏览器

timeout		# 连接超时

unredirected_headers
unsafe_writes

# SELinux相关
selevel
serole
setype
seuser

```

栗子：下载并计算md5

```sh
# 下载php
# https://www.php.net/distributions/php-8.1.1.tar.gz
# sha256
# 4e4cf3f843a5111f6c55cd21de8f26834ea3cd4a5be77c88357cbcec4a2d671d



[root@ansible ~]# ansible vm7 -m get_url -a 'url=https://www.php.net/distributions/php-8.1.1.tar.gz dest=/tmp sha256sum=4e4cf3f843a5111f6c55cd21de8f26834ea3cd4a5be77c88357cbcec4a2d671d'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "checksum_dest": null,
    "checksum_src": "fd134213e28a1f7b6547b958a9695e3368772d22",
    "dest": "/tmp/php-8.1.1.tar.gz",
    "elapsed": 25,
    "gid": 0,
    "group": "root",
    "md5sum": "b3201710e6e68f75f3ba9e89a0c1a59e",
    "mode": "0644",
    "msg": "OK (19624644 bytes)",
    "owner": "root",
    "size": 19624644,
    "src": "/root/.ansible/tmp/ansible-tmp-1641204046.0609725-21881-147544601074577/tmpjw22m7di",
    "state": "file",
    "status_code": 200,
    "uid": 0,
    "url": "https://www.php.net/distributions/php-8.1.1.tar.gz"
}

# 在远程主机查看

[root@CentOS84vm7 ~]# ll /tmp
total 19168
-rw-r--r-- 1 root root 19624644 Jan  3 19:01 php-8.1.1.tar.gz

# 如果sha256不一样的话。比如故意写个不同的（验证失败会直接删除下载的文件）

[root@ansible ~]# ansible vm7 -m get_url -a 'url=https://www.php.net/distributions/php-8.1.1.tar.gz dest=/tmp sha256sum=4e4cf3f843a5111f6'
vm7 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "checksum_dest": null,
    "checksum_src": "fd134213e28a1f7b6547b958a9695e3368772d22",
    "dest": "/tmp/php-8.1.1.tar.gz",
    "elapsed": 45,
    "msg": "The checksum for /tmp/php-8.1.1.tar.gz did not match 4e4cf3f843a5111f6; it was 4e4cf3f843a5111f6c55cd21de8f26834ea3cd4a5be77c88357cbcec4a2d671d.",	# 验证失败
    "src": "/root/.ansible/tmp/ansible-tmp-1641204181.4313264-21911-123776157787190/tmp3plzwz3o",
    "url": "https://www.php.net/distributions/php-8.1.1.tar.gz"
}


# 下载过程的临时目录（远程主机）

[root@CentOS84vm7 ~]# ls /tmp
ansible_get_url_payload_nfct1zkb 

[root@CentOS84vm7 ~]# tree /tmp
/tmp
├── ansible_get_url_payload_nfct1zkb
    └── ansible_get_url_payload.zip


```



## fetch

从远程主机下载文件到Ansible主机，于copy相反。暂时不支持目录

语法

```sh
[root@ansible ~]# ansible-doc fetch

```

栗子

```sh
# 指定文件绝对路径

[root@ansible ~]# ansible vm7 -m fetch -a 'src=/tmp/php-8.1.1.tar.gz.bak dest=/tmp/php.tar.gz'
vm7 | CHANGED => {
    "changed": true,
    "checksum": "fd134213e28a1f7b6547b958a9695e3368772d22",
    "dest": "/tmp/php.tar.gz/vm7/tmp/php-8.1.1.tar.gz.bak",
    "md5sum": "b3201710e6e68f75f3ba9e89a0c1a59e",
    "remote_checksum": "fd134213e28a1f7b6547b958a9695e3368772d22",
    "remote_md5sum": null
}
[root@ansible ~]# ll /tmp | grep php
drwxr-xr-x  3 root    root     17 Jan  3 19:07 php.tar.gz

# 指定为目录

[root@ansible ~]# ansible vm7 -m fetch -a 'src=/tmp/php-8.1.1.tar.gz.bak dest=/tmp/'
vm7 | CHANGED => {
    "changed": true,
    "checksum": "fd134213e28a1f7b6547b958a9695e3368772d22",
    "dest": "/tmp/vm7/tmp/php-8.1.1.tar.gz.bak",	# 自动创建远程主机结构的目录
    "md5sum": "b3201710e6e68f75f3ba9e89a0c1a59e",
    "remote_checksum": "fd134213e28a1f7b6547b958a9695e3368772d22",
    "remote_md5sum": null
}

[root@ansible ~]# ls /tmp/vm7/tmp	# 远程主机下的，多个主机有多个结构
php-8.1.1.tar.gz.bak

# 远程主机下的，多个主机有多个结构

[root@ansible ~]# mkdir /tmp/fetch

[root@ansible ~]# ansible remote1 -m fetch -a 'src=/etc/redhat-release dest=/tmp/fetch'
node5 | CHANGED => {
    "changed": true,
    "checksum": "8eeb5502828aef19a71b22cd2f6714a1d95460fd",
    "dest": "/tmp/fetch/node5/etc/redhat-release",
    "md5sum": "abfe96b4c918b73b9d6aa8cf08973b0e",
    "remote_checksum": "8eeb5502828aef19a71b22cd2f6714a1d95460fd",
    "remote_md5sum": null
}
node2 | CHANGED => {
    "changed": true,
    "checksum": "8eeb5502828aef19a71b22cd2f6714a1d95460fd",
    "dest": "/tmp/fetch/node2/etc/redhat-release",
    "md5sum": "abfe96b4c918b73b9d6aa8cf08973b0e",
    "remote_checksum": "8eeb5502828aef19a71b22cd2f6714a1d95460fd",
    "remote_md5sum": null
}
node3 | CHANGED => {
    "changed": true,
    "checksum": "8eeb5502828aef19a71b22cd2f6714a1d95460fd",
    "dest": "/tmp/fetch/node3/etc/redhat-release",
    "md5sum": "abfe96b4c918b73b9d6aa8cf08973b0e",
    "remote_checksum": "8eeb5502828aef19a71b22cd2f6714a1d95460fd",
    "remote_md5sum": null
}


[root@ansible ~]# tree /tmp/fetch/
/tmp/fetch/
├── node2
│   └── etc
│       └── redhat-release
├── node3
│   └── etc
│       └── redhat-release
└── node5
    └── etc
        └── redhat-release

```



## file

设置文件属性，软连接等（不具备文件传输功能。文件传输可用copy，fetch或者shell）

语法

```sh
[root@ansible ~]# ansible-doc file

```

栗子

```sh
# 新建空文件
ansible node2 -m file -a 'path=/tmp/file1 state=touch'
# 删除文件
ansible node2 -m file -a 'path=/tmp/file2 state=absent'
# 修改文件属性
ansible node2 -m file -a 'path=/tmp/file1 owner=admin01 mode=111'
# 创建目录
ansible node2 -m file -a 'path=/tmp/dir1 state=directory'
# 修改文件夹属性。不存在时自动创建。（默认不递归到子文件夹）
ansible node2 -m file -a 'path=/tmp/dir1 state=directory owner=admin01 group=root'
# 修改文件夹属性，递归
ansible node2 -m file -a 'path=/tmp/dir1 state=directory owner=admin01 group=root recurse=yes'

# 删除文件夹（不区分的，只要匹配到？）
ansible node2 -m file -a 'path=/tmp/dir1 state=absent'

# 无法创建同名的文件夹和文件（linux的限制）
[root@ansible ~]# ansible node2 -m file -a 'path=/tmp/filedir state=touch'
[root@ansible ~]# ansible node2 -m file -a 'path=/tmp/filedir state=directory'

    "msg": "/tmp/filedir already exists as a file",

[root@ansible ~]# mkdir /tmp/filedir
mkdir: cannot create directory ‘/tmp/filedir’: File exists

# 创建软链接
[root@ansible ~]# ansible node2 -m file -a 'src=/tmp/dir1 dest=/tmp/dir1-ln state=link'
[root@ansible ~]# ll /tmp/dir1-ln
lrwxrwxrwx 1 root root 9 Jan  3 19:21 /tmp/dir1-ln -> /tmp/dir1




```

## stat



检查文件，或者文件系统的状态

（Windows版win_stat，大多都是加上前缀win_的）

语法

```sh
[root@ansible ~]# ansible-doc  stat

```

栗子

```sh
[root@ansible ~]# ansible node2 -m stat -a 'path=/etc/passwd'
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.9"
    },
    "changed": false,
    "stat": {
        "atime": 1641188197.9872177,
        "attr_flags": "",
        "attributes": [],
        "block_size": 4096,
        "blocks": 8,
        "charset": "us-ascii",
        "checksum": "e2991d2cee58914eeef14746ed151caf2e9d4c47",
        "ctime": 1641188197.4152176,
        "dev": 2049,
        "device_type": 0,
        "executable": false,
        "exists": true,	# 存在
        "gid": 0,
        "gr_name": "root",
        "inode": 135433841,
        "isblk": false,
        "ischr": false,
        "isdir": false,
        "isfifo": false,
        "isgid": false,
        "islnk": false,
        "isreg": true,
        "issock": false,
        "isuid": false,	# 调用者id于所有者id是否匹配？？都是root的0为何？
        "mimetype": "text/plain",
        "mode": "0644",
        "mtime": 1641188197.4072177,
        "nlink": 1,
        "path": "/etc/passwd",
        "pw_name": "root",
        "readable": true,
        "rgrp": true,
        "roth": true,
        "rusr": true,
        "size": 1108,
        "uid": 0,
        "version": "2716538431",
        "wgrp": false,
        "woth": false,
        "writeable": true,
        "wusr": true,
        "xgrp": false,
        "xoth": false,
        "xusr": false
    }
}

```

用Playbook

```sh
[root@ansible play]# ll /etc/foo.conf
-rw-r--r-- 1 root root 5 Jan  3 22:28 /etc/foo.conf

[root@ansible play]# cat stat.yaml
- hosts: node2
  tasks:
    - name: Get stats of a file
      ansible.builtin.stat:
        path: /etc/foo.conf
      register: st
    - name: Fail if the file does not belong to 'root'
      ansible.builtin.fail:
        msg: "Whoops! file ownership has changed"
      when: st.stat.pw_name != 'root'


[root@ansible play]# ansible-playbook stat.yaml

PLAY [node2] *******************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************
ok: [node2]

TASK [Get stats of a file] *****************************************************************************************
ok: [node2]

TASK [Fail if the file does not belong to 'root'] ******************************************************************
skipping: [node2]

PLAY RECAP *********************************************************************************************************
node2                      : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0  

# 修改文件权限

[root@ansible play]# ll /etc/foo.conf
-rw-r--r-- 1 admin01 root 5 Jan  3 22:28 /etc/foo.conf

[root@ansible play]# ansible-playbook stat.yaml

PLAY [node2] *******************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************
ok: [node2]

TASK [Get stats of a file] *****************************************************************************************
ok: [node2]

TASK [Fail if the file does not belong to 'root'] ******************************************************************
fatal: [node2]: FAILED! => {"changed": false, "msg": "Whoops! file ownership has changed"}

PLAY RECAP *********************************************************************************************************
node2                      : ok=2    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0  


```

Playbook的另一种写法

```sh
[root@ansible play]# cat stat2.yaml
- hosts: node2
  tasks:
    - name: Get stats of a file
      stat: path=/etc/foo.conf
      register: st
    - name: debug
      debug:
        msg: 'file not exist'
      when: not st.stat.exists


[root@ansible play]# ansible-playbook stat2.yaml

PLAY [node2] *******************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************
ok: [node2]

TASK [Get stats of a file] *****************************************************************************************
ok: [node2]

TASK [debug] *******************************************************************************************************
skipping: [node2]

PLAY RECAP *********************************************************************************************************
node2                      : ok=2    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0  


[root@ansible play]# rm -f /etc/foo.conf


[root@ansible play]# ansible-playbook stat2.yaml

PLAY [node2] *******************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************
ok: [node2]

TASK [Get stats of a file] *****************************************************************************************
ok: [node2]

TASK [debug] *******************************************************************************************************
ok: [node2] => {
    "msg": "file not exist"
}

PLAY RECAP *********************************************************************************************************
node2                      : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  

# 没有failed这算是捕获异常？？

[root@ansible play]# cat stat3.yaml
- hosts: node2
  tasks:
    - name: Get stats of a file
      stat: path=/etc/foo.conf
      register: st

[root@ansible play]# ansible-playbook stat3.yaml

PLAY [node2] *******************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************
ok: [node2]

TASK [Get stats of a file] *****************************************************************************************
ok: [node2]

PLAY RECAP *********************************************************************************************************
node2                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  




```

## unarchive

解压

- 将Ansible主机上的压缩包传送到远程主机后解压到特定目录。设置copy=yes（默认）
- 将远程主机上的某个压缩包解压到远程主机的指定目录下，这只copy=no

语法

```sh
[root@ansible ~]# ansible-doc unarchive

copy	# 默认yes（从本地复制过去远程）
If true, the file is copied from local controller to the managed (remote) node,
This option has been deprecated in favor of `remote_src'.

remote_src	# 默认no（远程没有）
Set to `yes` to indicate the archived file is already on the remote system and not local to the Ansible controller.

src # 源。可以是Ansible主机上的，也可为被管理的远程主机
dest # 远程主机的路径
mode	# 权限

```

栗子（仅仅支持tar和unzip命令的操作。不支持gzip）

```sh
# dest是目录

[root@ansible ~]# ansible vm7 -m unarchive -a 'src=/tmp/fqq.gz dest=/tmp/fqq.txt owner=admin01'
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
vm7 | FAILED! => {
    "changed": false,
    "msg": "dest '/tmp/fqq.txt' must be an existing dir"
}

# 需要解压命令unzip和tar

[root@ansible ~]# ansible vm7 -m unarchive -a 'src=/tmp/fqq.gz dest=/tmp/ owner=admin01'
vm7 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "msg": "Failed to find handler for \"/root/.ansible/tmp/ansible-tmp-1641258357.1463103-1005-165634988024777/source\". Make sure the required command to extract the file is installed. Unable to find required 'unzip' or 'zipinfo' binary in the path. Unable to find required 'gtar' or 'tar' binary in the path"
}


[root@ansible ~]# yum -y install zip unzip tar

[root@CentOS84vm7 ~]# yum -y install zip unzip tar

# 不支持纯gz

[root@ansible ~]# ansible vm7 -m unarchive -a 'src=/tmp/fqq.gz dest=/tmp/ owner=admin01'
vm7 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "msg": "Failed to find handler for \"/root/.ansible/tmp/ansible-tmp-1641258469.2276523-1668-175470231086919/source\". Make sure the required command to extract the file is installed. Command \"/usr/bin/unzip\" could not handle archive. Command \"/usr/bin/gtar\" could not handle archive. Command \"/usr/bin/gtar\" found no files in archive. Empty archive files are not supported."
}


[root@ansible ~]# tar -czvf /tmp/fqq.tar.gz /tmp/fqq


[root@ansible ~]# ansible vm7 -m unarchive -a 'src=/tmp/fqq.tar.gz dest=/tmp/ owner=admin01'
vm7 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "gid": 0,
    "group": "root",
    "mode": "0644",
    "msg": "chown failed: failed to look up user admin01",
    "owner": "root",
    "path": "/tmp/tmp/fqq",
    "size": 4,
    "state": "file",
    "uid": 0
}

```

从第三方（网上）复制到远程主机（也可用get_url+shell解压）

```sh
# http://nginx.org/download/nginx-1.20.2.tar.gz


[root@ansible ~]# ansible vm7 -m unarchive -a 'src=http://nginx.org/download/nginx-1.20.2.tar.gz dest=/tmp remote_src=yes'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "dest": "/tmp",
    "extract_results": {
        "cmd": [
            "/usr/bin/gtar",
            "--extract",
            "-C",
            "/tmp",
            "-z",
            "-f",
            "/root/.ansible/tmp/ansible-tmp-1641258866.4433594-1754-256472848114923/nginx-1.20.2.tarj2kkozss.gz"
        ],
        "err": "",
        "out": "",
        "rc": 0
    },
    "gid": 0,
    "group": "root",
    "handler": "TgzArchive",
    "mode": "01777",
    "owner": "root",
    "size": 209,
    "src": "/root/.ansible/tmp/ansible-tmp-1641258866.4433594-1754-256472848114923/nginx-1.20.2.tarj2kkozss.gz",
    "state": "directory",
    "uid": 0
}

# 复制过程中

[root@CentOS84vm7 ~]# ls /tmp
ansible_ansible.legacy.unarchive_payload_7xhl0pih  

# 复制完后自动解包，删除旧文件
[root@CentOS84vm7 ~]# ls /tmp/nginx-1.20.2/
auto  CHANGES  CHANGES.ru  conf  configure  contrib  html  LICENSE  man  README  src

# 把remote_src改为copy=no（一样的效果）

[root@ansible ~]# ansible vm7 -m unarchive -a 'src=http://nginx.org/download/nginx-1.20.2.tar.gz dest=/tmp copy=no'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "dest": "/tmp",
    "extract_results": {
        "cmd": [
            "/usr/bin/gtar",
            "--extract",
            "-C",
            "/tmp",
            "-z",
            "-f",
            "/root/.ansible/tmp/ansible-tmp-1641258971.481326-1777-134361162355886/nginx-1.20.2.tarymhc_91y.gz"
        ],
        "err": "",
        "out": "",
        "rc": 0
    },
    "gid": 0,
    "group": "root",
    "handler": "TgzArchive",
    "mode": "01777",
    "owner": "root",
    "size": 209,
    "src": "/root/.ansible/tmp/ansible-tmp-1641258971.481326-1777-134361162355886/nginx-1.20.2.tarymhc_91y.gz",
    "state": "directory",
    "uid": 0
}

# 复制过程。
[root@CentOS84vm7 ~]# ls /tmp
ansible_ansible.legacy.unarchive_payload_omf5a4lr 


[root@CentOS84vm7 ~]# ls /tmp/nginx-1.20.2/
auto  CHANGES  CHANGES.ru  conf  configure  contrib  html  LICENSE  man  README  src


```

## archive

把远程主机的文件夹，文件，打包保存在远程主机

语法

```sh
[root@ansible ~]# ansible-doc archive
dest
The file name of the destination archive. The parent directory must exists on the remote host.既存则覆盖

path
Remote absolute path, glob, or list of paths or globs for the file or files to compress or archive.远程主机的源文件


```

栗子

```sh
[root@ansible ~]# ansible vm7 -m archive -a 'path=/var/log dest=/tmp/vm7.log.tar.gz format=gz mode=0660'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "archived": [
        "/var/log/private",
	....
        "/var/log/httpd/error_log"
    ],
    "arcroot": "/var/",
    "changed": true,
    "dest": "/tmp/vm7.log.tar.gz",
    "dest_state": "archive",
    "expanded_exclude_paths": [],
    "expanded_paths": [
        "/var/log"
    ],
    "gid": 0,
    "group": "root",
    "missing": [],
    "mode": "0660",
    "owner": "root",
    "size": 804790,
    "state": "file",
    "uid": 0
}


# 没有？

[root@ansible ~]# ls "/tmp/vm7.log.tar.gz"
ls: cannot access '/tmp/vm7.log.tar.gz': No such file or directory

# 是保存在远程主机

[root@CentOS84vm7 ~]# ll /tmp/vm7.log.tar.gz
-rw-rw---- 1 root root 805700 Jan  4 10:21 /tmp/vm7.log.tar.gz


```

## hostname

管理主机名

```sh
[root@ansible ~]# ansible-doc hostname

name
```

栗子

```sh
[root@ansible ~]# ansible vm7 -a 'hostname'
vm7 | CHANGED | rc=0 >>
CentOS84vm7
[root@ansible ~]# ansible vm7 -m hostname -a 'name=vm7'
vm7 | CHANGED => {
    "ansible_facts": {
        "ansible_domain": "",
        "ansible_fqdn": "vm7",
        "ansible_hostname": "vm7",
        "ansible_nodename": "vm7",
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "name": "vm7"
}
[root@ansible ~]# ansible vm7 -a 'hostname'
vm7 | CHANGED | rc=0 >>
vm7

```

## cron

计划任务



语法

```sh
[root@ansible ~]# ansible-doc cron

backup
cron_file
disabled	# 启用or禁用是把同名的删除后新建带有新的状态的cron（问题在于不小心修改旧的。。）

day		#  (`1-31', `*', `*/2', and so on).
month	#  (`1-12', `*', `*/2', and so on).
hour	# (`0-23', `*', `*/2', and so on).
minute	# (`0-59', `*', `*/2', and so on).
weekday	#  (`0-6' for Sunday-Saturday, `*', and so on).

job		# 要执行的命令
state	# present or absent，和disable的区别，这个是删除
user

```



栗子

```sh
[root@vm7 ~]# crontab -l
no crontab for root
[root@vm7 ~]#


[root@ansible ~]# ansible vm7 -m cron -a 'hour=1 minute=10 weekday=1-5 name"backup DB at workday" job=/project/db_backup.sh'
ERROR! this task 'cron' has extra params, which is only allowed in the following modules:
...
# name那里少个=

[root@ansible ~]# ansible vm7 -m cron -a 'name=dbbackup job=/project/db_backup.sh'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "envs": [],
    "jobs": [
        "dbbackup"
    ]
}

[root@vm7 ~]# crontab -l
#Ansible: dbbackup
* * * * * /project/db_backup.sh



[root@ansible ~]# ansible vm7 -m cron -a 'hour=1 minute=10 weekday=1-5 name="backup DB at workday" job=/project/db_backup.sh'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "envs": [],
    "jobs": [
        "dbbackup",
        "backup DB at workday"
    ]
}


[root@vm7 ~]# crontab -l
#Ansible: dbbackup
* * * * * /project/db_backup.sh
#Ansible: backup DB at workday
10 1 * * 1-5 /project/db_backup.sh


# 同步时间
[root@vm7 ~]# dnf -y install chrony

[root@vm7 ~]# date -s"2022-01-01"
Sat Jan  1 00:00:00 JST 2022

[root@ansible ~]# ansible vm7 -m systemd -a 'name=chronyd state=restarted'

[root@vm7 ~]# date	# 重启后过几秒自动
Tue Jan  4 11:10:01 JST 2022



# 禁用计划任务（不能禁用已有的？？）

[root@ansible ~]# ansible vm7 -m cron -a 'name=dbbackup disabled=yes'
vm7 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "msg": "You must specify 'job' to install a new cron job or variable"
}



[root@ansible ~]# ansible vm7 -m cron -a 'name=dbbackup disabled=yes job=/test.sh'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,	# 什么修改了 啊。。
    "envs": [],
    "jobs": [
        "dbbackup",
        "backup DB at workday"
    ]
}


[root@vm7 ~]# crontab -l
#Ansible: dbbackup
#* * * * * /test.sh		# 原来的被删，新的禁用。。。
#Ansible: backup DB at workday
10 1 * * 1-5 /project/db_backup.sh

# 启用

[root@ansible ~]# ansible vm7 -m cron -a 'name=dbbackup disabled=no job=/test2.sh'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "envs": [],
    "jobs": [
        "dbbackup",
        "backup DB at workday"
    ]
}

[root@vm7 ~]# crontab -l
#Ansible: dbbackup
* * * * * /test2.sh	# 同名的旧的被删
#Ansible: backup DB at workday
10 1 * * 1-5 /project/db_backup.sh

# 删除

[root@ansible ~]# ansible vm7 -m cron -a 'name=dbbackup state=absent'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "envs": [],
    "jobs": [
        "backup DB at workday"
    ]
}


[root@vm7 ~]# crontab -l
#Ansible: backup DB at workday
10 1 * * 1-5 /project/db_backup.sh


```

## yum（dnf）和apt

软件安装

yum语法

```sh
[root@ansible ~]# ansible-doc dnf

[root@ansible ~]# ansible-doc yum

download_dir
download_only

disablerepo
enablerepo

installroot

list

name
state	# install (`present' or `installed', `latest'), or remove (`absent' or `removed') a package.

update_cache

```

apt语法

```sh
[root@ansible ~]# ansible-doc apt

deb
dpkg_options
name
state	# (Choices: absent, build-dep, latest, present, fixed)[Default: present]

update_cache

```

栗子

```sh
# 安装

[root@ansible ~]# ansible vm7 -m dnf -a 'name=nginx state=present enablerepo=epel'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
        "Installed: libXpm-3.5.12-8.el8.x86_64",
        "Installed: perl-Digest-MD5-2.55-396.el8.x86_64",
...


[root@vm7 ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server


# 卸载

[root@ansible ~]# ansible vm7 -m dnf -a 'name=nginx state=absent'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
        "Removed: nginx-1:1.14.1-9.module_el8.0.0+184+e34fea82.x86_64",
        "Removed: nginx-all-modules-1:1.14.1-9.module_el8.0.0+184+e34fea82.noarch",
        "Removed: nginx-mod-http-image-filter-1:1.14.1-9.module_el8.0.0+184+e34fea82.x86_64",
        "Removed: nginx-mod-http-perl-1:1.14.1-9.module_el8.0.0+184+e34fea82.x86_64",
        "Removed: nginx-mod-http-xslt-filter-1:1.14.1-9.module_el8.0.0+184+e34fea82.x86_64",
        "Removed: nginx-mod-mail-1:1.14.1-9.module_el8.0.0+184+e34fea82.x86_64",
        "Removed: nginx-mod-stream-1:1.14.1-9.module_el8.0.0+184+e34fea82.x86_64"
    ]
}

[root@vm7 ~]# systemctl status nginx
Unit nginx.service could not be found.

```

直接安装网上的rpm包（在线仓库）

```sh
# https://mirrors.cat.net/centos/8.5.2111/AppStream/x86_64/os/Packages/nmap-7.70-6.el8.x86_64.rpm


[root@ansible ~]# ansible vm7 -m dnf -a 'name=https://mirrors.cat.net/centos/8.5.2111/AppStream/x86_64/os/Packages/nmap-7.70-6.el8.x86_64.rpm'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
        "Installed /root/.ansible/tmp/ansible-tmp-1641263165.486547-2171-196259305551575/nmap-7.70-6.el8.x86_64bkq5jbmi.rpm",
        "Installed: nmap-2:7.70-6.el8.x86_64",
        "Installed: nmap-ncat-2:7.70-6.el8.x86_64"
    ]
}

```

安装多个

```sh
[root@ansible ~]# ansible vm7 -m dnf -a 'name=htop,psmisc state=present'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
        "Installed: htop-3.0.5-1.el8.x86_64",
        "Installed: psmisc-23.1-5.el8.x86_64"
    ]
}

# 幂等

[root@ansible ~]# ansible vm7 -m dnf -a 'name=htop,psmisc state=present'
vm7 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "msg": "Nothing to do",
    "rc": 0,
    "results": []
}


```

查看包信息（包括在线的）（ commands for usage with `/usr/bin/ansible` and not' `playbooks`. ）

```sh
[root@ansible ~]# ansible vm7 -m dnf -a 'list=htop'
vm7 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "msg": "",
    "results": [
        {
            "arch": "x86_64",
            "envra": "0:htop-3.0.5-1.el8.x86_64",
            "epoch": "0",
            "name": "htop",
            "nevra": "0:htop-3.0.5-1.el8.x86_64",
            "release": "1.el8",
            "repo": "@System",
            "version": "3.0.5",
            "yumstate": "installed"	# 这个安装了
        },
        {
            "arch": "x86_64",
            "envra": "0:htop-3.0.5-1.el8.x86_64",
            "epoch": "0",
            "name": "htop",
            "nevra": "0:htop-3.0.5-1.el8.x86_64",
            "release": "1.el8",
            "repo": "epel",
            "version": "3.0.5",
            "yumstate": "available"	# 可以选
        }
    ]
}

# 找不到的时候也是成功？如何所有的？

[root@ansible ~]# ansible vm7 -m dnf -a 'list=all'
vm7 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "msg": "",
    "results": []
}


```

## yum_repository

可以简单地复制`xx.repo`文件的，为何要用Ansible来做这么复杂的事？？

幂等性都有



栗子

```sh

[root@ansible ansible]# cat add_epel.yaml
- hosts: realremote
  tasks:
  - name: add epel
    yum_repository:
      name: epel2
      description: epel #2
      file: epel2.repo
      baseurl: https://download.fedoraproject.org/pub/epel/$releasever/Everything/$basearch
      gpgcheck: no


[root@ansible ansible]# ansible-playbook add_epel.yaml

PLAY [realremote] **************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************
ok: [vm7]

TASK [add epel] ****************************************************************************************************
changed: [vm7]

PLAY RECAP *********************************************************************************************************
vm7                        : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  

# 会自己再加后缀

[root@vm7 ~]# ll /etc/yum.repos.d/epel2.repo.repo
-rw-r--r-- 1 root root 133 Jan  1 02:15 /etc/yum.repos.d/epel2.repo.repo


[root@vm7 ~]# yum repolist | grep epel2
epel2              epel 2



```

栗子（复制文件）

```sh
[root@ansible ansible]# cat /etc/yum.repos.d/epel1.repo

[epel1]
name=Extra Packages for Enterprise Linux $releasever - $basearch
#baseurl=https://download.fedoraproject.org/pub/epel/$releasever/Everything/$basearch
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8


[root@ansible ansible]# ansible vm7 -m copy -a 'src=/etc/yum.repos.d/epel1.repo dest=/etc/yum.repos.d/epel1.repo'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "checksum": "54d099bfd03934e43ac21ed6268089403f215ac1",
    "dest": "/etc/yum.repos.d/epel1.repo",
    "gid": 0,
    "group": "root",
    "md5sum": "c69010d2789e20e006c3e9ca74170730",
    "mode": "0644",
    "owner": "root",
    "size": 364,
    "src": "/root/.ansible/tmp/ansible-tmp-1641270493.563265-2444-62300439736521/source",
    "state": "file",
    "uid": 0
}



[root@vm7 ~]# yum repolist | grep epel1
epel1              Extra Packages for Enterprise Linux 8 - x86_64


[root@vm7 ~]# ll /etc/yum.repos.d/epel1.repo
-rw-r--r-- 1 root root 364 Jan  1 02:17 /etc/yum.repos.d/epel1.repo

```



## service / systemd

管理服务sysV / systemd

语法

```sh
# service管的比systemd多

[root@ansible ~]# ansible-doc service

Controls services on remote hosts. Supported init systems include BSD init, OpenRC
SysV, Solaris SMF, systemd, upstart. 

```

栗子



```sh
# 先看服务安装了没

[root@ansible ansible]# ansible vm7 -m dnf -a 'list=httpd'
"yumstate": "installed"

# 启动，并开机启动


[root@ansible ansible]# ansible vm7 -m service -a 'name=httpd state=started enabled=yes'

[root@vm7 ~]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2022-01-01 02:24:32 JST; 8s ago


[root@vm7 ~]# systemctl is-enabled httpd
enabled

# 停止，并移除开机启动

[root@ansible ansible]# ansible vm7 -m service -a 'name=httpd state=stopped enabled=no'

# 重载配置
[root@ansible ansible]# ansible vm7 -m service -a 'name=httpd state=reloaded'


```

systemd（语法同service）

```sh
[root@ansible ansible]# ansible vm7 -m systemd -a 'name=httpd state=started enabled=yes'

[root@vm7 ~]# systemctl is-enabled httpd
enabled
[root@vm7 ~]# systemctl status httpd
● httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2022-01-01 02:26:29 JST; 5s ago


[root@ansible ansible]# ansible vm7 -m systemd -a 'name=httpd state=stopped enabled=no'


```

## user



栗子

```sh
[root@ansible ansible]# ansible vm7 -m user -a 'name=user33 comment="ansible user" uid=10033 group=root'

[root@vm7 ~]# id user33
uid=10033(user33) gid=0(root) groups=0(root)


# 删除用户，包括其家目录

[root@ansible ansible]# ansible vm7 -m user -a 'name=user33 state=absent remove=yes'

[root@vm7 ~]# id user33
id: ‘user33’: no such user

[root@vm7 ~]# ls /home
hi


```

生产用户并创建用户密码

```sh
# linux用的是sha512的密码的意思？？▲

[root@ansible ~]# ansible-doc user


- password
        Optionally set the user's password to this crypted value.
        On macOS systems, this value has to be cleartext. Beware of security issues.
        To create a disabled account on Linux systems, set this to `'!'' or `'*''.
        To create a disabled account on OpenBSD, set this to `'*************''.
        See FAQ entry
        <https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#how-do-i-generate-encrypted-passwords-for-the-user-module> 
for details on various ways to
        generate these password values.
        [Default: (null)]
        type: str



ansible all -i localhost, -m debug -a "msg={{ 'mypassword' | password_hash('sha512', 'mysecretsalt') }}"

mkpasswd --method=sha-512
pip install passlib
python -c "from passlib.hash import sha512_crypt; import getpass; print(sha512_crypt.using(rounds=5000).hash(getpass.getpass()))"


```

密码栗子

```sh
# 密码

[root@ansible ansible]# ansible vm7 -m debug -a "msg={{ 'user34' | password_hash('sha512','salt') }}"
vm7 | SUCCESS => {
    "msg": "$6$salt$16BO9YlChusbdPEx6P.dQWYcyShcWdyvpTfssLsAw0viP8wO28S2YzLVC/n.YW5tsq7Pf1.6OEL9ImSdOydX1."
}

# 用py得到的密码不一样，每次都不一样
pip3 install passlib
[root@ansible ansible]# python3 -c "from passlib.hash import sha512_crypt; import getpass; print(sha512_crypt.using(rounds=5000).hash(getpass.getpass()))"
Password:
$6$uJKenlJY11nlh9bE$PlXEtNyDaIfO8qluBlRjm3JbS9PNZYKe6F0bmPCPHLCnPoNaXx8SfpzzZIwCpBk9dyqo81nYGLpUXlZl17P.g.



# 创建用户。用上面的密码，msg后边的一串，包括引号的数据


[root@ansible ansible]# ansible vm7 -m user -a 'name=user34 password="$6$salt$16BO9YlChusbdPEx6P.dQWYcyShcWdyvpTfssLsAw0viP8wO28S2YzLVC/n.YW5tsq7Pf1.6OEL9ImSdOydX1."'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "comment": "",
    "create_home": true,
    "group": 1001,
    "home": "/home/user34",
    "name": "user34",
    "password": "NOT_LOGGING_PASSWORD",	# ？？？不登陆的？
    "shell": "/bin/bash",
    "state": "present",
    "system": false,
    "uid": 1001
}


[root@vm7 ~]# id user34
uid=1001(user34) gid=1001(user34) groups=1001(user34)

[hi@vm7 ~]$ su - user34
Password:	# 用上面的密码测试
Last login: Sat Jan  1 02:34:35 JST 2022 on pts/0
[user34@vm7 ~]$



```

创建用户顺便生产 密钥

```sh
[root@ansible ansible]# ansible vm7 -m user -a 'name=user35 generate_ssh_key=yes ssh_key_bits=4096'

    "ssh_key_file": "/home/user35/.ssh/id_rsa",


[root@ansible ansible]# ansible vm7 -m user -a 'name=user36 generate_ssh_key=yes ssh_key_bits=4096 password="$6$salt$16BO9YlChusbdPEx6P.dQWYcyShcWdyvpTfssLsAw0viP8wO28S2YzLVC/n.YW5tsq7Pf1.6OEL9ImSdOydX1."'


[root@vm7 ~]# id user36
uid=1003(user36) gid=1003(user36) groups=1003(user36)

[root@vm7 ~]# ls /home/user36/.ssh
id_rsa  id_rsa.pub


```

## group



```sh
# 新建
[root@ansible ansible]# ansible vm7 -m group -a 'name=group1 gid=2000'

[root@vm7 ~]# grep group1 /etc/gshadow
group1:!::

# 删除

[root@ansible ansible]# ansible vm7 -m group -a 'name=group1 state=absent'


```



## lineinfile / replace

用sed执行复杂命令，需要转义，特殊符号会无法转义

替代：lineinfiile（修改单行）和replace（修改多行）模块

使用lineinfile时，RE匹配到多行，只会修改最后一行（默认）。删除的时候却会删除全部

```sh
[root@ansible ~]# ansible-doc lineinfile

This is primarily useful when you want to change a single line in a file only. 

firstmatch # Used with `insertafter' or `insertbefore'.匹配第一个
line	#  The line to insert/replace into the file.Required for `state=present'.
path	# The file to modify。Before Ansible 2.3 this option was only usable as `dest', `destfile' and `name'.
regexp	# For `state=present', the pattern to replace if found. Only the last line found will be replaced.For `state=absent', the pattern of the line(s) to remove.替换时最后一个，删除时所有匹配到的

search_string
state	# (Choices: absent, present)[Default: present]


EXAMPLES:
- name: Ensure SELinux is set to enforcing mode
  ansible.builtin.lineinfile:
    path: /etc/selinux/config
    regexp: '^SELINUX='
    line: SELINUX=enforcing

- name: Make sure group wheel is not in the sudoers configuration
  ansible.builtin.lineinfile:
    path: /etc/sudoers
    state: absent
    regexp: '^%wheel'

```

lineinfile栗子

```sh
# 修改httpd的默认端口。regexp搜索匹配的行，然后替换为line的内容

[root@vm7 ~]# egrep '^Listen' /etc/httpd/conf/httpd.conf
Listen 80

[root@ansible ~]# ansible vm7 -m lineinfile -a 'path=/etc/httpd/conf/httpd.conf regexp="^Listen" line="Listen 8011"'


[root@vm7 ~]# egrep '^Listen' /etc/httpd/conf/httpd.conf
Listen 8011

# 修改SELinux配置文件（事前用grep等先看效果）（用selinux更简单）

[root@vm7 ~]# egrep '^SELINUX=' /etc/selinux/config.bak
SELINUX=enforcing

[root@ansible ~]# ansible vm7 -m lineinfile -a "path=/etc/selinux/config.bak regexp='^SELINUX=' line='SELINUX=disabled'"
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "backup": "",
    "changed": true,
    "msg": "line replaced"
}

[root@vm7 ~]# egrep '^SELINUX=' /etc/selinux/config.bak
SELINUX=disabled

# 删除

[root@vm7 ~]# cp /etc/fstab{,.test}
[root@vm7 ~]# cat /etc/fstab.test

#
# /etc/fstab
# Created by anaconda on Tue Nov 30 02:07:03 2021
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
UUID=8932965b-bc9c-4a45-8a7b-b530d8605aa8 /                       xfs     defaults        0 0
UUID=e342d394-fc3f-4a9d-9070-f6e1c49d4574 /boot                   ext4    defaults        1 2
UUID=b28143e9-142e-44f1-b4ec-d8c2b9636f85 /data                   xfs     defaults        0 0
UUID=0539fa7e-3248-4f2f-b68b-3558ef73aec5 none                    swap    defaults        0 0

[root@ansible ~]# ansible vm7 -m lineinfile -a 'dest=/etc/fstab.test state=absent regexp="^#"'

[root@vm7 ~]# cat /etc/fstab.test

UUID=8932965b-bc9c-4a45-8a7b-b530d8605aa8 /                       xfs     defaults        0 0
UUID=e342d394-fc3f-4a9d-9070-f6e1c49d4574 /boot                   ext4    defaults        1 2
UUID=b28143e9-142e-44f1-b4ec-d8c2b9636f85 /data                   xfs     defaults        0 0
UUID=0539fa7e-3248-4f2f-b68b-3558ef73aec5 none                    swap    defaults        0 0




```



replace栗子

```sh
[root@vm7 ~]# cat /etc/fstab.test
UUID=8932965b-bc9c-4a45-8a7b-b530d8605aa8 /                       xfs     defaults        0 0
# UUID=e342d394-fc3f-4a9d-9070-f6e1c49d4574 /boot                   ext4    defaults        1 2
UUID=b28143e9-142e-44f1-b4ec-d8c2b9636f85 /data                   xfs     defaults        0 0
UUID=0539fa7e-3248-4f2f-b68b-3558ef73aec5 none                    swap    defaults        0 0

# 替换为#号开头。\1和sed中的意思一样，向前引用，前面匹配的那个直接拿来用


[root@ansible ~]# ansible vm7 -m replace -a 'dest=/etc/fstab.test regexp="^(UUID.*)" replace="#\1"'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": true,
    "msg": "3 replacements made"
}


[root@vm7 ~]# cat /etc/fstab.test
#UUID=8932965b-bc9c-4a45-8a7b-b530d8605aa8 /                       xfs     defaults        0 0
# UUID=e342d394-fc3f-4a9d-9070-f6e1c49d4574 /boot                   ext4    defaults        1 2
#UUID=b28143e9-142e-44f1-b4ec-d8c2b9636f85 /data                   xfs     defaults        0 0
#UUID=0539fa7e-3248-4f2f-b68b-3558ef73aec5 none                    swap    defaults        0 0

# 再去掉开头的#号

# #写在括号内的不起作用
[root@ansible ~]# ansible vm7 -m replace -a 'dest=/etc/fstab.test regexp="^(#UUID.*)" replace="\1"'


[root@ansible ~]# ansible vm7 -m replace -a 'dest=/etc/fstab.test regexp="^#(UUID.*)" replace="\1"'

# #再加空格的
[root@ansible ~]# ansible vm7 -m replace -a 'dest=/etc/fstab.test regexp="^# (UUID.*)" replace="\1"'


# 报错，为何？？不加圆括号的是错的？语法不是RE？？

[root@ansible ~]# ansible vm7 -m replace -a 'dest=/etc/fstab.test regexp="^UUID.*" replace="#\1"'
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: sre_constants.error: invalid 
group reference 1 at position 2


[root@vm7 ~]# egrep '^#.*' /etc/fstab.test
#UUID=8932965b-bc9c-4a45-8a7b-b530d8605aa8 /                       xfs     defaults        0 0
#UUID=e342d394-fc3f-4a9d-9070-f6e1c49d4574 /boot                   ext4    defaults        1 2
#UUID=b28143e9-142e-44f1-b4ec-d8c2b9636f85 /data                   xfs     defaults        0 0
#UUID=0539fa7e-3248-4f2f-b68b-3558ef73aec5 none                    swap    defaults        0 0


```



## selinux

```sh
[root@ansible ~]# ansible-doc selinux

state	# (Choices: disabled, enforcing, permissive


```

栗子

```sh
[root@vm7 ~]# egrep '^SELINUX=' /etc/selinux/config
SELINUX=disabled

# 只能修改enforcing到disabled。反之不能。。也就值关闭selinux专用的模块。。。

[root@ansible ~]# ansible vm7 -m selinux -a 'state=permissive'
vm7 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "msg": "Policy is required if state is not 'disabled'"
}


[root@ansible ~]# ansible vm7 -m selinux -a 'state=enforcing'
vm7 | FAILED! => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "msg": "Policy is required if state is not 'disabled'"
}

[root@ansible ~]# ansible vm7 -m selinux -a 'state=disabled'
vm7 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "configfile": "/etc/selinux/config",
    "msg": "",
    "policy": "targeted",
    "reboot_required": false,
    "state": "disabled"
}


[root@vm7 ~]# getenforce
Disabled
[root@vm7 ~]# setenforce 1
setenforce: SELinux is disabled
[root@vm7 ~]# setenforce 0
setenforce: SELinux is disabled

```

## reboot

重启

```sh
[root@ansible ~]# ansible vm7 -m reboot

vm7 | CHANGED => {
    "changed": true,
    "elapsed": 22,		# 会不断尝试连接已确定是否重启成功
    "rebooted": true
}

```

## mount

挂载和卸载文件系统

语法

```sh
boot	# filesystem should be mounted on boot, Only applies to Solaris and Linux systems, [Default: True]
fstype	# Required when `state' is `present' or `mounted'
opts	# Mount options (see fstab(5)
path	# mount point 
src		# Device (or NFS volume, or something else) to be mounted on `path'
state	# mounted：挂载并写入fstab。unmounted单纯卸载不修改fstab，present单纯修改fstab，不挂载，absent卸载并修改fstab，

```

栗子

```sh
[root@vm7 ~]# df -h | grep /mnt
[root@vm7 ~]# echo $?
1



[root@ansible ~]# ansible vm7 -m mount -a 'src=/dev/sr0 path=/mnt state=present'
    "msg": "state is present but all of the following are missing: fstype"

[root@ansible ~]# ansible vm7 -m mount -a 'src=/dev/sr0 path=/mnt'
    "msg": "missing required arguments: state"

# 写入配置文件

[root@ansible ~]# ansible vm7 -m mount -a 'src=/dev/sr0 path=/mnt state=present fstype=iso9006'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "backup_file": "",
    "boot": "yes",
    "changed": true,
    "dump": "0",
    "fstab": "/etc/fstab",
    "fstype": "iso9006",
    "name": "/mnt",
    "opts": "defaults",
    "passno": "0",
    "src": "/dev/sr0"
}

[root@vm7 ~]# df -h | grep /mnt
[root@vm7 ~]# echo $?
1
[root@vm7 ~]#

[root@vm7 ~]# grep mnt /etc/fstab
/dev/sr0 /mnt iso9006 defaults 0 0



# 挂载并写入fstab

[root@ansible ~]# ansible vm7 -m mount -a 'src=/dev/sr0 path=/mnt state=mounted fstype=iso9006'
    "msg": "Error mounting /mnt: mount: /mnt: unknown filesystem type 'iso9006'.\n"



[root@ansible ~]# ansible vm7 -m mount -a 'src=/dev/sr0 path=/mnt state=mounted fstype=iso9660'
vm7 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "backup_file": "",
    "boot": "yes",
    "changed": true,
    "dump": "0",
    "fstab": "/etc/fstab",
    "fstype": "iso9660",
    "name": "/mnt",
    "opts": "defaults",
    "passno": "0",
    "src": "/dev/sr0"
}

# 会自动替换已有的（以开头为准？以开头几个为准？后面的数据随时替换？？）

[root@vm7 ~]# grep mnt /etc/fstab
/dev/sr0 /mnt iso9660 defaults 0 0

[root@vm7 ~]# df -h | grep /mnt
/dev/sr0        9.3G  9.3G     0 100% /mnt

```

## setup

收集主机系统信息，facts，可以以变量的形式使用（以变量的形式保存）。主机多时影响执行速度（可设置超时gather_timeout）

playbook默认自动收集，使用`gather_facts: no`禁止收集facts

语法

```sh
[root@ansible ~]# ansible-doc setup
filter	# 匹配模式

gather_subset


```

栗子

```sh
ansible vm7 -m setup -a 'filter=ansible_nodename'
ansible vm7 -m setup -a 'filter=ansible_hostname'
ansible vm7 -m setup -a 'filter=ansible_memory_mb'
ansible vm7 -m setup -a 'filter=ansible_os_family'
ansible vm7 -m setup -a 'filter=ansible_processor_vcpus'
ansible vm7 -m setup -a 'filter=ansible_all_ipv4_addresses'
ansible vm7 -m setup -a 'filter=ansible_default_ipv4'

```

输出

```sh
[root@ansible ~]# ansible vm7 -m setup -a 'filter=ansible_os_family'
vm7 | SUCCESS => {
    "ansible_facts": {
        "ansible_os_family": "RedHat",
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false
}

```

## debug

输出输出信息，msg可定制输出内容，var可替代输出内容

语法

```sh
[root@ansible ansible]# ansible-doc debug
msg	# 要输出的信息，变量的话需要双引号+花括号
var # 获取一个变量的名字，输出其值。不可和msg一起。直接使用，默认已带有花括号`{{ }}'

# 变量的属性，输出结果的属性可以通过点来指定引用部分值：result.rc


[root@ansible project-test]# cat register2.yaml
- hosts: node2
  tasks:
    - shell: echo hello
      ignore_errors: yes		# 可能出错的要忽视才能获取信息
      register: reg1
    - debug: {msg: hi}			# 输出msg
    - debug: var=reg1.stdout	# 获取register的标准输出


[root@ansible project-test]# ansible-playbook register2.yaml

TASK [Gathering Facts] ****
ok: [node2]

TASK [shell] **************
changed: [node2]

TASK [debug] **************
ok: [node2] => {
    "msg": "hi"
}
TASK [debug] ***************
ok: [node2] => {
    "reg1.stdout": "hello"
}


```

 默认输出hello world

```sh
[root@ansible ~]# ansible vm7 -m debug
vm7 | SUCCESS => {
    "msg": "Hello world!"

```

输出变量（主机名，ip等）

```sh
[root@ansible ansible]# cat get_hostname_ip.yaml
- hosts: vm7

  tasks:
  - name: get host name and ip
    debug:
      msg: Host "{{ ansible_nodename }}" IP: "{{ ansible_default_ipv4.address }}"

# 不可用冒号
    debug:
      msg: Host "{{ ansible_nodename }}" IP: "{{ ansible_default_ipv4.address }}"
                                           ^ here


[root@ansible ansible]# cat get_hostname_ip.yaml
- hosts: vm7

  tasks:
  - name: get host name and ip
    debug:
      msg: Host "{{ ansible_nodename }}" IP "{{ ansible_default_ipv4.address }}"

# 只能获取第一个网卡的ip，不真实

[root@ansible ansible]# ansible-playbook get_hostname_ip.yaml

PLAY [vm7] *********************************************************************************************************

TASK [Gathering Facts] *********************************************************************************************
ok: [vm7]

TASK [get host name and ip] ****************************************************************************************
ok: [vm7] => {
    "msg": "Host \"vm7\" IP \"10.0.2.15\""
}

PLAY RECAP *********************************************************************************************************
vm7                        : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  

```



提取字符串的特定字符

```sh
[root@ansible ansible]# cat substr1.yaml
- hosts: vm7
  gather_facts: no
  vars:
    str1: "123456789"
  tasks:
  - debug:
      msg: "{{ str1[2] }}"


[root@ansible ansible]# ansible-playbook substr1.yaml

PLAY [vm7] *********************************************************************************************************

TASK [debug] *******************************************************************************************************
ok: [vm7] => {
    "msg": "3"
}

# 对比shell（shell没有看成数组。这里用切片）

[root@ansible ansible]# str1=123456789

[root@ansible ansible]# echo ${str1:2:1}
3

# 取方位，左边闭区间，右边开区间

[root@ansible ansible]# cat substr2.yaml
- hosts: vm7
  gather_facts: no
  vars:
    str1: "123456789"
  tasks:
  - debug:
      msg: "{{ str1[2:4] }}"


[root@ansible ansible]# ansible-playbook substr2.yaml

PLAY [vm7] *********************************************************************************************************

TASK [debug] *******************************************************************************************************
ok: [vm7] => {
    "msg": "34"

# 对比shell

[root@ansible ansible]# echo ${str1:2:3}
345



```



