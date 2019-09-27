## centos服务器安装搭建KVM虚拟机环境

作者：YSP

时间：2019年4月

### 1. 安装虚拟化（在宿主机上的操作）

```bash
yum -y install qemu-kvm libvirt virt-manager virt-viewer
```

### 2. 支持Xshell GUI界面(装好后重新登录一下)

```bash
yum -y install xorg-x11-xauth mesa-dri-drivers ghostscript-chinese-zh_CN
```

注意：在上面两条命令全部完全正确的执行以后，我们的虚拟机软件环境安装好了。

### 3. 关闭宿主机的防火墙和selinux
```bash
# 查看防火墙状态
systemctl status firewalld.service

# 如果防火墙的状态处在active(running)的状态
systemctl stop firewalld
# 如果想彻底关闭防火墙 即使重启服务器也不会再开启防火墙 则执行（使某服务不自动启动）
systemctl disable firewalld.service

# 临时关闭selinux的方法 执行下面的命令
setenforce 0
# 永久关闭则需要修改配置文件
vi /etc/selinux/config
# 编辑这个文件 添加如下新的一行 然后重启
SELINUX=disabled

reboot
```



### 4. 进入图形化的虚拟机安装和管理界面

```bash
virt-manager
```



### 5. 使用virt-manager图形化安装kvm虚拟机

&nbsp; &nbsp; &nbsp; &nbsp; 将centos镜像通过xftp上传到宿主机上，在安装kvm虚拟机时选择这个上传到的iso镜像。内存和cpu核心数一般选择8/16GB，cpu核心数根据宿主机的实际硬件配置进行选择。

### 6. 虚拟机的网络配置

```bash
cd /etc/sysconfig/network-scripts/
ls 
vi ifcfg-eth0
```

```bash
# 修改或者添加后面加注的那几行
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static # 设置为静态ip  对应则是dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=eth0
UUID=478cbfaa-9368-499a-8b25-1006fedb5f82
DEVICE=eth0 # 表示针对eth0网卡
ONBOOT=yes # 表示已经启用
IPADDR=192.168.122.X # (2---254) 具体的网段请根据virtual network的地址范围
GATEWAY=192.168.122.1
NETMASK=255.255.255.0
DNS1=8.8.8.8
DNS2=202.120.224.6 # 根据自己实际情况编辑

```

重启网络服务使配置生效（下面两种都可以）

```bash
service network restart
systemctl restart network.service
```

### 7. 开启宿主机的内核转发功能

&nbsp; &nbsp; &nbsp; &nbsp; 如果在实际的物理机环境下，重装完系统后，配置完网卡的配置文件ping测试一下外网地址，一般就可以访问了。但安装在服务器上虚拟机则是不同的。Linux系统缺省并没有打开IP转发功能，要确认IP转发功能的状态，可以查看/proc文件系统，使用下面命令：

```bash
cat /proc/sys/net/ipv4/ip_forward
```

**次如果上述文件中的值为0,说明禁止进行IP转发；如果是1,则说明IP转发功能已经打开。**

如果是关闭的，则虚拟机没法连接到外网，只能虚拟机和宿主机之间是可以ping通的。

动态修改内核参数的方法，但这种方法重启失效：

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```

若要永久修改，则需要修改`/etc/sysctl.conf` 文件，

```bash
# 增加一行
net.ipv4.ip_forward=1
```

可以重启系统来使修改生效，也可以执行下面的命令来使修改生效

```bash
sysctl -p /etc/sysctl.conf
```



### 8. 重启libvirtd服务

```bash
systemctl restart libvirtd
```

### 9. ssh连接虚拟机

```bash
ssh 192.168.122.X
```



