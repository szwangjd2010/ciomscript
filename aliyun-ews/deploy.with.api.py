#!/bin/env python
# -*- coding: utf-8 -*- 

import hashlib,hmac,time
import urllib2,urllib
import math
import json
import sys
import os,commands

ewsOpenApiBase = 'http://open-ews.cloud.tmall.com/api/v1/'
ciomRoot = '/data/ciom'
calldata = {
    'accesskey':'k45ukt9h4eh8rwxp',
    'secretkey':'06536107458c462fb9034ad074d643c7'
}

ciomdata={}
containers=[]
targetHosts=[]

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
    calldata['timestamp'] = str(int(time.time()*1000))
    sign = getSign(calldata)
    url = ewsOpenApiBase + suburl
    urldata = {}
    urldata['accesskey'] = calldata['accesskey']
    urldata['timestamp'] = calldata['timestamp'] 
    urldata = urllib.urlencode(urldata)
    url= url + urldata
    request = urllib2.Request(url)
    request.add_header('Authorization',sign)
    response = urllib2.urlopen(request)
    #print '[OPENAPI:GET] <'+url+'>' 
    return eval(response.read().replace(':true,',':True,').replace(':false,',':False,'))


def executePost(suburl,paras):
    calldata['timestamp'] = str(int(time.time()*1000))
    calldata.update(paras)
    sign = getSign(calldata)
    #url='http://open-ews.cloud.tmall.com/api/v1/container/31537/start'
    url = ewsOpenApiBase + suburl
    urldata = {}
    urldata.update(calldata)
    urldata.pop('secretkey')
    print calldata
    print urldata
    #urldata = urllib.urlencode(urldata)
    #request = urllib2.Request(url,urldata)
    #request.add_header('Authorization',sign)
    #response = urllib2.urlopen(request)
    #print '[OPENAPI:POST] <'+url+'>' 
    #print eval(response.read())

def serviceExisted(serviceId):
    rsp = executeGet('service/{}?'.format(serviceId))
    if str(rsp['message']) == 'success':
        return True
    else:
        return False

def getServiceContainerInfo(serviceId):
    getSvcRsp = executeGet('service/{}?'.format(serviceId))
    containerInfoInRsp = getSvcRsp['data']['nodes'][0]['containers']
    for item in containerInfoInRsp:
        containerDetail = {}
        containerDetail['containerId'] = item['id']
        hostid = item['hostId']
        getHostRsp = executeGet('host/{}?'.format(hostid))
        hostIpInRsp = getHostRsp['data']['internetIp']
        containerDetail['hostIp'] = hostIpInRsp
        containers.append(containerDetail)

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

def deployWithHttp(nodeid):
    paras={}
    paras['url']='http://devinner.yunxuetang.com.cn/ciomrepo/v0/aliyun-jst/lecaih5mobile/lecaih5mobile.zip'
    paras['method']='PARALLEL'
    executePost('node/{}/uploadStart'.format(nodeid),paras)

def getContainerStatus(containerId):
    rsp = executeGet('container/{}?'.format(containerId))
    return rsp['data']['status']


def initCiomData():
    ciomdata['version'] = sys.argv[1]
    ciomdata['cloudid'] = sys.argv[2]
    ciomdata['appname'] = sys.argv[3]
    jsonPath = '{}/{}/pre/{}/{}/ciom.json'.format(os.environ["CIOM_VCA_HOME"],ciomdata['version'],ciomdata['cloudid'],ciomdata['appname'])
    ciomdata.update(json.load(file(jsonPath)))
    
def getTargetHosts():
    hosts = []
    for item in containers:
        hosts.append(item['hostIp'])
    targetHosts.extend(list(set(hosts)))

def copyAppPackageToTargetHosts(type):
    if type == 'tomcatapp':
        targetapp = '{}/{}/target/{}.war'.format(os.environ["WORKSPACE"],ciomdata['appname'],'lecaiapi')
    else:
        targetapp = '{}/{}.zip'.format(os.environ["WORKSPACE"],ciomdata['appname'])
    hostRepos = '{}/{}/'.format(ciomRoot,ciomdata['appname'])
    for ip in targetHosts:
        #print('[CIOM] copy war packege to {} ...'.format(ip))
        os.system('ssh root@{} "mkdir -p {}"'.format(ip,hostRepos))
        os.system('scp -r {} root@{}:{}'.format(targetapp,ip,hostRepos))

def deployTomcatApp4Containers():
    appPackage='{}/{}/{}.war'.format(ciomRoot,ciomdata['appname'],'lecaiapi')
    for item in containers:
        print('[CIOM] extract packege(war) for container{} on {}...'.format(item['containerId'],item['hostIp']))
        target = '/data/acs/{}/code/'.format(item['containerId'])
        stopContainer(item['containerId'])
        oldversion = commands.getstatusoutput('ssh root@{} "head -1 {}/WEB-INF/classes/version.txt"'.format(item['hostIp'],target))[1]
        os.system('ssh root@{} "cd {};tar -czf {}/{}/{}.tgz * --remove-files"'.format(item['hostIp'],target,ciomRoot,ciomdata['appname'],oldversion))
        os.system('ssh root@{} "unzip -q -o {} -d {}"'.format(item['hostIp'],appPackage,target))
        startContainer(item['containerId'])

def deployStaticApp4Containers():
    appPackage='{}/{}/{}.zip'.format(ciomRoot,ciomdata['appname'],ciomdata['appname'])
    print appPackage
    for item in containers:
        print('[CIOM] extract packege(zip) for container{} on {}...'.format(item['containerId'],item['hostIp']))
        target = '/data/acs/{}/code/'.format(item['containerId'])
        oldversion = commands.getstatusoutput('ssh root@{} "head -1 {}version.txt"'.format(item['hostIp'],target))[1]
        os.system('ssh root@{} "cd {};tar -czf {}/{}/{}.tgz * --remove-files"'.format(item['hostIp'],target,ciomRoot,ciomdata['appname'],oldversion))
        os.system('ssh root@{} "unzip -q -o {} -d {}"'.format(item['hostIp'],appPackage,target))
        print commands.getstatusoutput('ssh root@{} "ls {}"'.format(item['hostIp'],target))[1]
        #stopContainer(item['containerId'])
        #startContainer(item['containerId'])

def verifyContainers():
    for item in containers:
        if(getContainerStatus(item['containerId']) == 'STARTFAILED'):
            print('[CIOM] Container <{}> started failed, retry once ...'.format(item['containerId']))
            startContainer(item['containerId'])
        else:
            print('[CIOM] Container <{}> started successfully !!!'.format(item['containerId']))

def deploy4tomcatapp():
    copyAppPackageToTargetHosts('tomcatapp')
    deployTomcatApp4Containers()
    verifyContainers()

def deploy4staticapp():
    copyAppPackageToTargetHosts('staticapp')
    deployStaticApp4Containers()
    verifyContainers()

def deploy():
    if ciomdata['type'] == 'tomcatapp':
        deploy4tomcatapp()
    if ciomdata['type'] == 'staticapp':
        deploy4staticapp()

if __name__ == '__main__':
    #if len(sys.argv) < 4 :
    #    sys.exit()

    #if serviceExisted(globalServiceId):
    #    print getServiceContainerInfo(globalServiceId)
    #initCiomData()
    #getServiceContainerInfo(ciomdata['serviceid'])
    #print executeGet('service/19686?')
    #print executeGet('node/617940?')
    deployWithHttp('617940')
    #getTargetHosts()
    #print containers
    #deploy()
