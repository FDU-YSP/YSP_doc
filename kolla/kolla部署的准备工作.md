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

配置Docker的私有仓库 (queens版以后kolla不提供，只能自己拉 所有的包上传到本地仓库)

限于国内网络环境的问题，如果直接在线安装很容易失败，所以我们非常有必要建立一个本地仓 库。建立本地仓库所需要的OpenStack的各个组件的镜像，既可以通过 Kolla 进行 build ，也可 以直接下载官网制作好的镜像。   运行 Registry 服务的容器，由于 5000 端口与 keystone 端口号冲突，所以我们需要修改其映射 到本地 4000 端口上:

```bash
docker run -d -v /opt/registry:/var/lib/registry -p 4000:5000 --restart=always --name registry registry:2

# 查看是否成功启动
docker ps
```

运行以上命令后，会自动在线拉取 registry:2 的镜像，如果因为网络环境不能够正常下载，也可 以在一个网络状况比较好的机器上先下载好，然后导出为 .tar 包，再在相应的机器上导入:

```bash
# 在网络好的机器上执行
docker pull registry:2
docker images
docker save -o registry_v2.tar registry:2

# 在目标机器上执行如下命令，再执行上面的命令块，将registry服务用容器跑起来
docker load -i ./registry_v2.tar 
docker image

```

在浏览器中输入：[SERVICE_IP]:4000/v2/_catalog，如果能够进入，则说明已经成功安装了本地仓 库。



安装Kolla­ansible部署工具

此过程只需要在部署机上面执行，kolla­ansible既可以使用 pip 来安装，也可以通过 git 源码安装，本次通过源码安装：   下载源码包，一定要下载对应的版本，部署的是Q版，所以下载Q版的kolla­ansible

```bash
cd /opt
git clone http://git.trystack.cn/openstack/kolla-ansible -b stable/rocky
```

安装kolla­-ansible：

```bash
cd  kolla-ansible
pip install ./     (或者python setup.py develop)
```

复制配置文件和inventory文件：

```bash
cd /opt/kolla-ansible/
cp -r etc/kolla /etc/kolla
cp -r ansible/inventory /home/inventory/
```

如果是在虚拟机里装kolla，希望可以启动再启动虚拟机，那么你需要把virt_type=qemu，默认是 kvm：

```bash
mkdir -p /etc/kolla/config/nova
cat << EOF > /etc/kolla/config/nova-compute.conf
[libvirt]
virt_type=qume
cpu_mode=none
EOF
```

生成密码文件：

```bash
kolla-genpwd
```

修改登录dashboard的admin用户的登录密码：

```bash
vim /etc/kolla/passwords.yml
# 修改下面的字段
keystone_admin_password: admin
```

如果安装zun组件，必须安装etcd和kuryr. 安装etcd过程中，kolla­ansible会出现etcd起不来的现 象，此时需要修改kolla­ansible文件

```bash
vim /usr/share/kolla-ansible/ansible/roles/etcd/defaults/main.yml
把
ETCD_LISTEN_CLIENT_URLS: "{{ internal_protocol }}://{{ api_interface_address }}:{{ etcd_client_port }}"
修改为
ETCD_LISTEN_CLIENT_URLS: "{{ internal_protocol }}://0.0.0.0:{{ etcd_client_port }}"
```

开始部署
由于我们采用的是多节点物理机部署，在部署之前，我们需要修改 globals.yml 和 multinode 两个配置文件（单节点的话修改的是allinone.yml的配置文件）。

```bash
vim /etc/kolla/globals.yml
```

