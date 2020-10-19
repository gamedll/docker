#!/bin/bash
# docker install shell
# history 2020/10/05 00:59 sh update check docker&docker-compose
# history 2020/10/05 00:59 sh update pip3
# history 2020/10/03 20:35 sh create
PATH=/bin:/sbin:/usr/bin:/usr/sbin/:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
sudo yum install -y yum-utils deltarpm  
yum-config-manager \
    --add-repo \
https://download.docker.com/linux/centos/docker-ce.repo
echo "初始化docker安装环境，开始安装===>......"
yum install  -y docker-ce
echo "docker安装完成,开始启动......"
systemctl start docker
echo "docker设置为随系统启动......"
systemctl enable docker.service
echo "docker设置为随系统启动......完成，准备安装docker-compose"
yum -y install epel-release
echo "开始安装docker-compose......"
yum install -y python3-pip  python3-dev libffi-dev openssl-dev gcc libc-dev make
echo "更换国内pip地址......"
mkdir ~/.pip/
sudo tee ~/.pip/pip.conf <<-'EOF'
[global]
index-url = http://pypi.douban.com/simple
[install]
trusted-host=pypi.douban.com
EOF
pip3 install -U --force-reinstall pip
pip3 uninstall pyrsistent -y
pip3 install --ignore-installed requests setuptools pyrsistent==0.16.0 pyinstaller
pip3 install docker-compose
echo "docker-compose安装完成......"
echo "开始进行配置docker>daemon.json......,文件位置:/etc/docker/daemon.json"
echo "采用etcd-master:2379作为后端存储,请输入etcd-master地址,默认为etcd-master，可安装完成后编辑主机hosts对应地址"
echo "默认注册的私有镜像库地址hub.cictec.cn:20000,并采用阿里云镜像库加速"
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://mirror.aliyuncs.com"],
  "cluster-store": "etcd://etcd-master:2379"
}
EOF
echo "重新加载docker配置........"
sudo systemctl daemon-reload
sudo systemctl restart docker
echo "配置docker daemon.json完成......."
echo =====..
echo "开始检测安装结果......"
dv=`docker -v`
dcv=`docker-compose --version`
if [[ $dv == *1*  && -d "/var/lib/docker" ]];
then
    echo "docker已安装....."
    echo $dv
else
    echo "docker未安装成功...."
fi
if [[ $dcv == *1*  && -f "/usr/local/bin/docker-compose" ]];
then
    echo "docker-compose已安装....."
    echo $dcv
else
    echo "docker-compose未安装成功...."
fi
