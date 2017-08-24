#!/bin/env python
# -*- coding: utf-8 -*- 

import hashlib,hmac,time
import urllib2,urllib
import math
import json
import sys
import os,commands

ewsOpenApiBase = 'http://open-ews.cloud.tmall.com/api/v1/'
ciomRepoBase = 'http://devinner.yunxuetang.com.cn/ciomrepo/'
ciomRoot = '/data/ciom'
signdataBasic = {
    'accesskey':'k45ukt9h4eh8rwxp',
    'secretkey':'06536107458c462fb9034ad074d643c7'
}

ciomdata={}
nodes=[]
targetHosts=[]
failNodes=[]


def initCiomData():
    ciomdata['version'] = sys.argv[1]
    ciomdata['cloudid'] = sys.argv[2]
    ciomdata['appname'] = sys.argv[3]
    jsonPath = '{}/{}/pre/{}/{}/ciom.json'.format(os.environ["CIOM_VCA_HOME"],ciomdata['version'],ciomdata['cloudid'],ciomdata['appname'])
    ciomdata.update(json.load(file(jsonPath)))

def getSign(data,popKey='secretkey'):
    dList=[]
    getStr=''
    for k in data:
        if k != popKey:
            mergeStr=k+data.get(k)
            dList.append(mergeStr)
    sdList=sorted(dList)
    for i in sdList:
        getStr+=i
    getStr= data.get('secretkey') + getStr + data.get('secretkey')
    #print getStr
    return hmac.new(data.get('secretkey'), getStr.encode('utf-8')).hexdigest().upper()

def executeGet(suburl):
    signdata = {}
    signdata['timestamp'] = str(int(time.time()*1000))
    signdata.update(signdataBasic)
    sign = getSign(signdata)
    url = ewsOpenApiBase + suburl
    urldata = {}
    urldata.update(signdata)
    urldata.pop('secretkey')
    urldata = urllib.urlencode(urldata)
    url= url + urldata
    request = urllib2.Request(url)
    request.add_header('Authorization',sign)
    response = urllib2.urlopen(request)
    #print '[OPENAPI:GET] <'+url+'>' 
    rsp = response.read().replace(':true,',':True,').replace(':false,',':False,')
    print rsp
    return eval(rsp)

def executePost(suburl,paras):
    signdata = {}
    signdata['timestamp'] = str(int(time.time()*1000))
    signdata.update(signdataBasic)
    signdata.update(paras)
    sign = getSign(signdata)
    url = ewsOpenApiBase + suburl
    urldata = {}
    urldata.update(signdata)
    urldata.pop('secretkey')
    urldata = urllib.urlencode(urldata)
    request = urllib2.Request(url,urldata)
    request.add_header('Authorization',sign)
    response = urllib2.urlopen(request)
    #print '[OPENAPI:POST] <'+url+'>' 
    return eval(response.read())

def serviceExisted(serviceId):
    rsp = executeGet('service/{}?'.format(serviceId))
    if str(rsp['message']) == 'success':
        return True
    else:
        return False

def getServiceNodeContainersInfo(serviceId):
    getSvcRsp = executeGet('service/{}?'.format(serviceId))
    nodesInfoInRsp = getSvcRsp['data']['nodes']
    for itemNode in nodesInfoInRsp:
        nodeDetail = {}
        nodeDetail['nodeId'] = itemNode['id']
        itemContainers = itemNode['containers']
        containers = []
        for itemContainer in itemContainers:
            containerDetail = {}
            containerDetail['containerId'] = itemContainer['id']
            # hostid = itemContainer['hostId']
            # getHostRsp = executeGet('host/{}?'.format(hostid))
            # hostIpInRsp = getHostRsp['data']['internetIp']
            # containerDetail['hostIp'] = hostIpInRsp
            containers.append(containerDetail)
        nodeDetail['containers'] = containers
        nodes.append(nodeDetail)

def updateNodesInfoWithCommandId(nodeId,commandId):
    for item in nodes:
        if item['nodeId'] == nodeId:
            item['commandId'] = commandId

def startContainer(containerId):
    executePost('container/{}/start'.format(containerId))
    time.sleep(2)
    for i in range(20):
        containerStatus = getContainerStatus(containerId)
        print containerStatus
        if containerStatus == 'RUNNING':
            return
        time.sleep(3)
        i=i+1

def stopContainer(containerId):
    executePost('container/{}/stop'.format(containerId))
    time.sleep(2)
    for i in range(20):
        containerStatus = getContainerStatus(containerId)
        print containerStatus
        if containerStatus == 'STOPPED':
            return
        time.sleep(3)
        i=i+1

def getContainerStatus(containerId):
    rsp = executeGet('container/{}?'.format(containerId))
    return rsp['data']['status']

def getCommandStatus(commandId):
    rsp = executeGet('command/{}?'.format(commandId))
    return rsp['data']

def getNodeStatus(nodeId):
    ret = {}
    rsp = executeGet('node/{}?'.format(nodeId))
    ret['id']=rsp['data']['id']
    ret['containers'] = []
    for item in rsp['data']['containers']:
        c={}
        c['id'] = item['id']
        c['status'] = item['status']
        ret['containers'].append(c)
    return ret

def deployWithNodeAPI(nodeid,packege):
    paras={}
    paras['url']='{}/{}/{}/{}/{}'.format(ciomRepoBase,ciomdata['version'],ciomdata['cloudid'],ciomdata['appname'],packege)
    paras['method']='PARALLEL'
    rsp = executePost('node/{}/uploadStart'.format(nodeid),paras)
    updateNodesInfoWithCommandId(nodeid,rsp['data']['commandId'])
    time.sleep(2)

def waitUploadStarted():
    for i in range(60):
        count = 0
        for item in nodes:
            cmdActivities = getCommandStatus(item['commandId'])['activitys']
            if len(cmdActivities) > 0:
                count = count + 1
        if count == len(nodes):
            print('[CIOM] upload started for all nodes')
            return
        time.sleep(1)
        i=i+1

def waitUploadFinished():
    for i in range(200):
        finishCount = 0
        for item in nodes:
            cmdRet = getCommandStatus(item['commandId'])
            if cmdRet['status'] == 'DONE':
                if cmdRet['resultMsg'] == '':
                    finishCount = finishCount + 1
                else: 
                    failNodes.append(item['nodeId'])      
        print('[CIOM] Nodes > Total:{} , finished:{}'.format(len(nodes),finishCount))
        if finishCount == len(nodes):
            print('[CIOM] Upload finished for all nodes')
            return
        time.sleep(3)
        i=i+1

def checkFailedNodes():
    if len(failNodes) == 0:
        print('[CIOM] Deployment for all nodes with uploadStart API finished successfully')
    else :
        print('[CIOM] UploadStart API Failed for node whose id is(are):')
        for item in failNodes:
            print(item)
        sys.exit(1)

def copyAppPackageToLocalTarget():
    ciomTarget = '{}/{}/{}/{}'.format(os.environ["CIOM_REPO_LOCAL"],ciomdata['version'],ciomdata['cloudid'],ciomdata['appname'])
    os.system('mkdir -p {}'.format(ciomTarget)) 
    if ciomdata['jst_apptype'] == 'iisapp':
        winBuildFolder = '{}/{}/{}/build/{}'.format(os.environ["CIOM_SLAVE_WIN_WORKSPACE"],ciomdata['version'],ciomdata['cloudid'],ciomdata['appname'])
        ciomTargetApp = '{}/{}.zip'.format(ciomTarget,ciomdata['appname'])
        os.system('cd {}; zip -r -q {} *'.format(winBuildFolder,ciomTargetApp))
    else: 
        if ciomdata['jst_apptype'] == 'tomcatapp':
            targetapp = '{}/{}/target/{}.war'.format(os.environ["WORKSPACE"],ciomdata['appname'],ciomdata['appname'])
        else:
            targetapp = '{}/{}.zip'.format(os.environ["WORKSPACE"],ciomdata['appname'])
        os.system('cp -r {} {}/'.format(targetapp,ciomTarget))

def deployForNode(nodeid):
    if ciomdata['jst_apptype'] == 'tomcatapp':
        deployWithNodeAPI(nodeid,'{}.war'.format(ciomdata['appname']))
    else: 
        deployWithNodeAPI(nodeid,'{}.zip'.format(ciomdata['appname']))

def verifyContainers():
    for itemNode in nodes:
        for item in itemNode['containers']:
            if(getContainerStatus(item['containerId']) != 'RUNNING'):
                print('[CIOM] Status of container <{}> is not correct'.format(item['containerId']))
                sys.exit(1)
            else:
                print('[CIOM] Container <{}> started successfully !!!'.format(item['containerId']))

def deployForNodes():
    for item in nodes:
        nId = item['nodeId']
        deployForNode(nId)

def deploy():
    copyAppPackageToLocalTarget()
    deployForNodes()
    print nodes
    waitUploadStarted()
    waitUploadFinished()
    checkFailedNodes()
    verifyContainers()

if __name__ == '__main__':
    if len(sys.argv) < 4 :
        print('[CIOM] Incorrect python call')
        sys.exit(1)
    initCiomData()
    if serviceExisted(ciomdata['jst_sid']):
        getServiceNodeContainersInfo(ciomdata['jst_sid'])
        deploy()
    else:
        print('[CIOM] Incorrect serviceid configured in ciom.json')
        sys.exit(1)
