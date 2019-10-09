## Centos7服务器搭建VNC Server环境

在企业级项目的开发中，尤其是分布式项目，经常直接在服务器上进行开发工作，操作系统环境一般是Centos 7。普遍状况是，在服务器上安装IDE 开发工具，通过Xshell等工具远程启动，本地通过虚拟桌面打开IDE，使用体验是非常差的，IDE 卡顿严重，及其影响开发体验。

解决方案：在Centos服务器上安装VNC(virtual network computing) Server。参考书可见：鸟哥的linux私房菜-服务器架设篇。 VNC Server会在服务端启动一个监听用户要求的端口，端口号一般在5901-5910之间。（大概就是说，最多开10个虚拟桌面）

```bash
# 可参考https://linux.cn/article-5335-1.html

yum -y install @x11 @gnome tigervnc-server
yum -y remove gnome-initial-setup 
#取消GNOME引导设置程序

yum -y remove PackageKit 
#取消YUM源后台自动更新

systemctl set-default graphical
#设置默认启动runlevel 5

systemctl isolate graphical.target 
#启动runlevel5

systemctl enable vncserver@:1 
#对应端口号5901,注意避免与虚拟机端口号冲突 设置开机自启

#修改service文件，以root用户为例
vim /etc/systemd/system/multi-user.target.wants/vncserver\@\:1.service
ExecStart=/usr/sbin/runuser -l root -c "/usr/bin/vncserver %i"
PIDFile=/root/.vnc/%H%i.pid

systemctl daemon-reload 
#重新加载systemd服务配置文件

vncpasswd 
#设置当前用户密码

systemctl start vncserver@:1
# 这是一项服务的形式，需要启动

#防火墙放行TCP 5901端口或直接禁用防火墙
systemctl stop firewalld
systemctl disable firewalld

-------------------------------------如果配置多个端口-----------------------------------------
systemctl enable vncserver@:1
# 对应端口号5901, 注意避免与虚拟机端口号冲突
systemctl enable vncserver@:2
# 对应端口号5902（如果要创建两个虚拟桌面的话）

# 修改service文件，以root用户为例
vim /etc/systemd/system/multi-user.target.wants/vncserver\@\:1.service
# 添加下面两行
ExecStart=/usr/sbin/runuser -l root -c "/usr/bin/vncserver %i"
PIDFile=/root/.vnc/%H%i.pid
 
systemctl daemon-reload #重新加载systemd服务配置文件
vncpasswd #设置当前用户密码
systemctl start vncserver@:1 <br>
# 防火墙放行TCP 5901端口或直接禁用防火墙
systemctl stop firewalld
systemctl disable firewalld
---------------------------------------------结束-----------------------------------------

# 在本地电脑上下载并安装vnc viewer(client)，下载地址如下
https://www.tightvnc.com/download.html
 
# 输入ip:port 连接服务器
例:192.168.122.128:5901
例:192.168.122.128:5902
 
# 调整分辨率 Applications>System Tools>Settings>Devices>Displays>Desolution
# 禁用黑屏 Applications>System Tools>Settings>Power>Blank screen
```

