#!/bin/bash

# 这个脚本在目标机器上执行可以将 bfs-v2 这个项目部署到 /opt/mos/codebase 这个目录
set -x

cd /opt/mos/codebase

# clone 代码
git clone git@git.getstarfish.com:sf/bfs-v2.git > /dev/null 2>&1

# 如果之前 clone 过，则更新代码
cd bfs-v2
git pull

# 建立 daemontools 监控脚本
cd /service && ln -s /opt/mos/codebase/bfs-v2/scripts/bfs-prd-run/ . > /dev/null 2>&1

# 切换 python virtual-env
. /opt/mos/python-env/bin/activate

# 更新 python 依赖
pip3 install -r /opt/mos/codebase/bfs-v2/requirements.txt

# 重启程序
sudo svc -h /service/bfs-prd-run
