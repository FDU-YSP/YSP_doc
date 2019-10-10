## kolla部署openstack





配置免密登录

安装依赖包

```nash
yum -y install epel-release
yum -y install python-pip git
```

centos更换阿里云源

```bash
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
wget -O /etc/yum.repos.d/CentOS.repo http://mirrors.aliyun.com/repo/Centos-7.repo

pip install -U pip
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```



停止 libvirt 组件，否则后面安装会失败

```bash
systemctl stop libvirtd.service
systemctl disable libvirtd.service
```

拉取docker-ce.repo，然后才能安装上docker-ce

```bash
wget -O /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/repo/Centos-7.repo

yum -y install docker-ce
```

对docker进行配置，开启 Docker 的 shared mount 共享挂载功能

```bash
mkdir /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/kolla.conf <<-'EOF'
[Service]
MountFlags=shared
```

如果安装zun组件，需要对docker进行进一步配置

https://docs.openstack.org/kolla-ansible/latest/reference/compute/zun-guide.html  （容器计算）

https://docs.openstack.org/kolla-ansible/latest/reference/containers/kuryr-guide.html  (容器网络)

```bash
vim /usr/lib/systemd/system/docker.service
添加如下信息
ExecStart= -H tcp://172.16.1.13:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://172.16.1.13:2379 --cluster-advertise=172.16.1.13:2375
```

为 Docker 配置访问私有仓库，修改 ExecStart 字段：(如果从docker hub上拉镜像不需要进行此步骤)

```bash
vim /usr/lib/systemd/system/docker.service

修改如下内容,[controller]字符串替换成对应的控制节点的IP
ExecStart=/usr/bin/dockerd --insecure-registry [controller]:4000
```

重启docker服务

```bash
systemctl daemon-reload
systemctl restart docker
```

下载python的docker sdk并升级到最新版

```bash
pip install docker
pip install -U docker
```



