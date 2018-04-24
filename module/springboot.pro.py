from fabric.api import *
from time import sleep
from 
jvmRefs = {
    'OPT_S64M_X512M_SS512K' : '-Xms64m -Xmx512m -Xss512k',
    'OPT_S128M_X1024M_SS512K' : '-Xms128m -Xmx1024m -Xss512k'
}
EurekaHost = {"dev": "172.17.128.156"}


@task
def hello():
    run("echo hello")


def alive(host, port, appName):

    service = SpringbootService(host, port, appName)
    eureka = Eureka(EurekaHost["dev"])
    return (service.GetStatus() or (host in eureka.GetInstanceList(appName)))


def stop(host, port, appName):
    if alive(host, port, appName):
        run("pkill -9 -f 'server.port={}'".format(port), warn_only=True)
        sleep(10)
        if not alive(host, port, appName):
            # Report this incidence
    

@task
def deploy(location, appName, jvmopt, profile, svcport):
    #shutdown(appName, svcport)
    #sleep(2)
    start(location, appName, jvmopt, profile, svcport)
    #sleep(2)
    #print run('curl localhost:{}/{}/v1/health'.format(port, appName),warn_only=True)

def start(location, appName, jvmopt, profile, port):
    jvmOption = jvmRefs.get(jvmopt)
    run('nohup java {} -jar {}/{}/{}.jar --spring.profiles.active={} --server.port={} >/dev/null &'.format(jvmOption, location, appName, appName, profile, port), pty=False)
    #run('nohup java {} -jar {}/{}/{}.jar --spring.profiles.active={} --server.port={} >/data/logback/test &'.format(jvmOption, location, appName, appName, profile, port), pty=False)  

@task
def shutdown(host, port, appName):
    if alive(port):
        run('curl -X POST localhost:{}/act/shutdown'.format(port), warn_only=True)
        sleep(2)
        stop(port)
    print('Application {} was stopped on port {}!!!'.format(appName, port))

@task
def showRefs(location, appName, jvmopt, profile ,svcport):
    print profile
    print svcport
