# Linux Administrator

# sql操作

## 导入hellodb.sql生成数据库



```sh
[root@mariadb ~]# mysql < hellodb_innodb.sql

[root@mariadb ~]# mysql -e 'show databases;'
+--------------------+
| Database           |
+--------------------+
| hellodb            |
| information_schema |
| mysql              |
| performance_schema |
+--------------------+

```



## 在students表中，查询年龄大于25岁，且为男性的同学的名字和年龄 

```sh

MariaDB [(none)]> use hellodb

MariaDB [hellodb]> desc students;
+-----------+---------------------+------+-----+---------+----------------+
| Field     | Type                | Null | Key | Default | Extra          |
+-----------+---------------------+------+-----+---------+----------------+
| StuID     | int(10) unsigned    | NO   | PRI | NULL    | auto_increment |
| Name      | varchar(50)         | NO   |     | NULL    |                |
| Age       | tinyint(3) unsigned | NO   |     | NULL    |                |
| Gender    | enum('F','M')       | NO   |     | NULL    |                |
| ClassID   | tinyint(3) unsigned | YES  |     | NULL    |                |
| TeacherID | int(10) unsigned    | YES  |     | NULL    |                |
+-----------+---------------------+------+-----+---------+----------------+
6 rows in set (0.002 sec)

MariaDB [hellodb]> select Name,Age from students where Age>25 and Gender='M';
+--------------+-----+
| Name         | Age |
+--------------+-----+
| Xie Yanke    |  53 |
| Ding Dian    |  32 |
| Yu Yutong    |  26 |
| Shi Qing     |  46 |
| Tian Boguang |  33 |
| Xu Xian      |  27 |
| Sun Dasheng  | 100 |
+--------------+-----+
7 rows in set (0.000 sec)

```



## 以ClassID为分组依据，显示每组的平均年龄

```sh

MariaDB [hellodb]> select ClassID, avg(Age) from students group by ClassID;
+---------+----------+
| ClassID | avg(Age) |
+---------+----------+
|    NULL |  63.5000 |
|       1 |  20.5000 |
|       2 |  36.0000 |
|       3 |  20.2500 |
|       4 |  24.7500 |
|       5 |  46.0000 |
|       6 |  20.7500 |
|       7 |  19.6667 |
+---------+----------+
8 rows in set (0.000 sec)

```



## ？显示第2题中平均年龄大于30的分组及平均年龄

```sql

MariaDB [hellodb]> create view avgage as select ClassID, avg(Age) as avgage from students group by ClassID;
Query OK, 0 rows affected (0.001 sec)

MariaDB [hellodb]> select * from avgage where avgage>30;
+---------+---------+
| ClassID | avgage  |
+---------+---------+
|    NULL | 63.5000 |
|       2 | 36.0000 |
|       5 | 46.0000 |
+---------+---------+
3 rows in set (0.001 sec)


```



## 显示以L开头的名字的同学的信息

```sh

MariaDB [hellodb]> select * from students where Name like "L%";
+-------+-------------+-----+--------+---------+-----------+
| StuID | Name        | Age | Gender | ClassID | TeacherID |
+-------+-------------+-----+--------+---------+-----------+
|     8 | Lin Daiyu   |  17 | F      |       7 |      NULL |
|    14 | Lu Wushuang |  17 | F      |       3 |      NULL |
|    17 | Lin Chong   |  25 | M      |       4 |      NULL |
+-------+-------------+-----+--------+---------+-----------+
3 rows in set (0.001 sec)

```



# 数据库授权hai用户，允许192.168.20.0/24网段连接mysql

```sh

MariaDB [hellodb]> create user "hai"@"192.168.20.%" identified by "hai123456";
Query OK, 0 rows affected (0.001 sec)


[root@www ~]# hostname -I
192.168.20.21 192.168.12.10

[root@www ~]# mysql -uhai -phai123456 -h192.168.20.21
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 13
Server version: 10.3.28-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>

```

