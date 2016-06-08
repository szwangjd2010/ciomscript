#!/bin/bash

# 这个脚本在目标机器上执行可以将 starfish-ws 这个项目部署到 /opt/mos/codebase 这个目录
appName=$1
set -x

cd /opt/mos/codebase

# clone 代码
git clone git@git.getstarfish.com:sf/starfish-ws-apollo.git starfish-ws-apollo-${appName} > /dev/null 2>&1

# 如果之前 clone 过，则更新代码
cd starfish-ws-apollo-${appName}
git pull

# 建立 daemontools 监控脚本
cd /service

ln -s /opt/mos/codebase/starfish-ws-apollo-${appName}/scripts/clean-model-cache-prd-${appName}-run/ . > /dev/null 2>&1
ln -s /opt/mos/codebase/starfish-ws-apollo-${appName}/scripts/ensure-index-exists-prd-${appName}-run/ . > /dev/null 2>&1
ln -s /opt/mos/codebase/starfish-ws-apollo-${appName}/scripts/index-worker-prd-${appName}-run/ . > /dev/null 2>&1
ln -s /opt/mos/codebase/starfish-ws-apollo-${appName}/scripts/starfish-ws-apollo-inner-prd-${appName}-run/ . > /dev/null 2>&1
ln -s /opt/mos/codebase/starfish-ws-apollo-${appName}/scripts/starfish-ws-apollo-msg-prd-${appName}-run/ . > /dev/null 2>&1
ln -s /opt/mos/codebase/starfish-ws-apollo-${appName}/scripts/starfish-ws-apollo-org-prd-${appName}-run/ . > /dev/null 2>&1

# 切换 python virtual-env
. /opt/mos/python-env/bin/activate

# 更新 python 依赖
pip3 install -r /opt/mos/codebase/starfish-ws-apollo-${appName}/requirements.txt

# 重启程序
sudo svc -h /service/*${appName}*
