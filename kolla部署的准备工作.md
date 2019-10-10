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

对docker进行配置

```bash
mkdir /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/kolla.conf <<-'EOF'
[Service]
MountFlags=shared
```

如果安装zun组件，需要对docker进行进一步配置

```bash
vim /usr/lib/systemd/system/docker.service
```

