---
layout: post
title:  "Debian常用命令"
summary: "Learn how to use command "
author: Miles
date: '2025-06-10 11:35:23 +0530'
category: ['debian']
tags: debian
thumbnail: /assets/img/posts/code.jpg
keywords: debian
usemathjax: false
permalink: /blog/debian-cmd/
---
# 清理内存
```
 sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

```
# 修改密码
```
passwd  root  
```
# 打印环境变量
```
printenv
echo $PATH
```
# 设置shell变量
```
MYVAR=foo
```
# 将 shell 变量转换为单个环境变量
```
export MYVAR
```
# 取消设置环境变量
```
unset NAME
```
# 多用户模式关机
```
# shutdown -h now   
```
# 单用户模式关机
```
# poweroff -i -f 
```

# 查看文件内容
```
cat
```
# 系统重启
```
reboot

```
# 安装包
```
apt-get install  
```
# 更新源
```
apt-get upgrade 

```
# 创建目录
```
mkdir 
```
# 拷贝目录
```
cp -r
```
# 删除目录
```
rm -rf  
```
# 更改文件或者目录权限
## 添加写的权限
```
chmod u+w /etc/sudoers 
chmod u=r-- /etc/sudoers   
```
u表示该档案的拥有者 + 表示增加权限、- 表示取消权限、= 表示唯一设定权限 r 表示可读取，w 表示可写入，x 表示可执行，X 表示只有当该档案是个子目录或者该档案已经被设定过为可执行。

# 显示目录下内容详情
```
ls - l
```
# 显示当前路径
```
pwd
```
# 清除屏幕内容，效果等同于 clear
```
Ctrl + l 
```
# 终止命令
```
Ctrl + c 
```
# 启动 停止 重启 查看 服务
```
systemctl stop start  restart reload status nginx
```
# 查看进程
```
ps aux 
ps -ef | grep nginx

```
# 显示系统当前的进程状况
```
top
```
# 内存监控
```
free -m
```
# 查看服务器运行了多长时间以及有多少个用户登录
```
uptime
```
# 杀死进程
```
# 如果您知道可以使用的进程名称：
killall Dock
#，你有正确的PID
sudo kill -9 PID 
```
# 测试端口
## 使用nc
```
### 使用tcp连接测试
nc -zv example.com 80
**这里的选项解释如下：

-z：扫描监听守护进程，不发送任何数据。

-v：显示详细信息。

如果端口是开放的，你将看到类似如下的输出：
Connection to example.com 80 port [tcp/http] succeeded!
**
### 使用udp连接测试
nc -zv example.com 53 -u
```
## 使用telnet
```
telnet <主机名或IP地址> <端口号>
```
## nmap
```
sudo apt-get update
sudo apt-get install nmap
nmap -p <端口号> <主机名或IP地址>
```
## curl
```
curl -I http://<主机名或IP地址>:<端口号>
```

# 查看端口
## 使用 netstat
```

netstat -lnp|grep 3000
# 输出结果中的 `29/node` 列即为进程ID/调用命令
#tcp6       0      0 :::3000                 :::*                    LISTEN      29/node
````
## 或者 lsof
```
lsof -i:3000
# 输出结果中的 `PID` 列即为进程ID
# COMMAND PID USER   FD   TYPE    DEVICE SIZE/OFF NODE NAME
# node     29 root   18u  IPv6 642925968      0t0  TCP *:3000 (LISTEN)
```

# 卸载应用
```
apt remove 
apt autoremove
apt list | grep xxx
```


# 查看文件夹大小
```
du -sh
```

# 查看内存信息
```
# 1. free 命令
#free 命令显示系统的总内存、已用内存、空闲内存以及交换空间的使用情况。

free -h
# -h 选项表示以易读的格式（如MB、GB）显示信息。

# 2. top 命令
#top 命令提供了一个实时的视图，显示了系统的运行情况，包括CPU使用率、内存使用情况等。

top
# 在top界面中，你可以看到内存（Mem）和交换空间（Swap）的使用情况。

# 3. htop 命令
# htop 是top命令的一个增强版本，提供了一个更友好的用户界面。如果你还没有安装# htop，可以使用以下命令安装：

sudo apt update
sudo apt install htop
# 然后运行：

htop
#在htop中，你可以看到内存使用情况的详细信息。

# 4. vmstat 命令
# vmstat 命令报告关于内核线程、中断、内存、交换、I/O块、和CPU活动的信息。它也可以用来查看内存使用情况。

vmstat -s
# 这个命令将列出各种统计信息，包括内存使用情况。

# 5. /proc/meminfo 文件
#你也可以直接查看/proc/meminfo文件来获取内存的详细信息。这个文件包含了系统内存的实时信息。

cat /proc/meminfo
# 这个命令会列出所有关于内存的详细信息，包括总内存、空闲内存、缓存的内存等。

# 6. glances 命令（可选）
# glances是一个跨平台的监控工具，它可以监控CPU、内存、磁盘I/O、网络等系统状态。如果你需要更全面的系统监控，可以安装glances：

sudo apt update
sudo apt install glances
# 然后运行：

glances
# glances提供了一个非常直观的界面来查看系统资源的使用情况
```

# 查看cup信息
```
lscpu

# lshw 命令
# lshw（Hardware Lister）是一个列出系统硬件配置的工具。它也可以用来查看CPU信息。
sudo lshw -short -C cpu

# dmidecode 命令
# dmidecode 命令用于解码系统的DMI（桌面管理接口）表，其中包括CPU信息。这个命令需要root权限
sudo dmidecode -t processor
```


# 查看磁盘信息
```
# 使用lsblk命令
# lsblk命令可以列出所有可用的存储设备及其分区信息。这是一个快速查看硬盘及其分区情况的好方法。
lsblk

# 使用fdisk命令
# fdisk是一个用于磁盘分区的工具，也可以用来查看硬盘的分区表。不过，通常我们用它来查看或修改分区表。
sudo fdisk -l

# 使用ls /dev/sd*命令
#在Linux中，硬盘通常被映射为/dev/sdX（例如，/dev/sda、/dev/sdb等），其中X是a、b等字母。你可以通过列出这些设备来查看你的硬盘。

ls /dev/sd*

# 使用df命令
# df命令显示文件系统的磁盘使用情况，包括挂载点和已用空间等信息。这对于查看哪些硬盘分区已被挂载非常有用。

df -h

# 使用hdparm命令
# hdparm是一个用于显示和设置SATA/ATA磁盘驱动器参数的工具。它可以用来查看硬盘的详细信息，如转速、缓存大小等。

sudo hdparm /dev/sda

# 使用blkid命令
# blkid命令用于查找/打印块设备（如硬盘分区）的UUID等信息。这对于识别特定硬盘或分区非常有用。

sudo blkid
# 或者，针对特定设备：

sudo blkid /dev/sda1
# 将/dev/sda1替换为你的具体分区）
```

