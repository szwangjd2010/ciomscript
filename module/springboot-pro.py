from fabric.api import *
from time import sleep
from servicechek import *

jvmRefs = {
    'OPT_S64M_X512M_SS512K' : '-Xms64m -Xmx512m -Xss512k',
    'OPT_S128M_X1024M_SS512K' : '-Xms128m -Xmx1024m -Xss512k'
}
EurekaHost = {"dev": "172.17.128.156",
              "prod": "",
              "xjk": ""}


@task
def hello():
    run("echo hello")


def alive(port, appName):
    
    service = SpringbootService(env.host, port, appName)
    return service.GetStatus()


def stop(port, appName):
    if alive(port, appName):
       run("pkill -9 -f 'server.port={}'".format(port), warn_only=True)
    

@task
def deploy(location, appName, jvmopt, profile, svcport):
    #shutdown(appName, svcport)
    #sleep(2)
    start(location, appName, jvmopt, profile, svcport)
    #sleep(2)
    #print run('curl localhost:{}/{}/v1/health'.format(port, appName),warn_only=True)

def start(location, appName, jvmopt, profile, port):
    if alive(env.host, port, appName):
	print "Service up already"
    else:
    	jvmOption = jvmRefs.get(jvmopt)
    	run('nohup java {} -jar {}/{}/{}.jar --spring.profiles.active={} --server.port={} >/dev/null &'.format(jvmOption, location, appName, appName, profile, port), pty=False)
    	#run('nohup java {} -jar {}/{}/{}.jar --spring.profiles.active={} --server.port={} >/data/logback/test &'.format(jvmOption, location, appName, appName, profile, port), pty=False)  


@task
def waitAlive(port, appName):
    	print "Waiting for service up"
        count = 0
    	while not(alive(env.host,port,appName)) and count < 300:
		sleep(1)
                count+=1
        if count ==300:
            print "Start timed out"


@task
def shutdown(port, appName):
    if alive(env.host, port, appName):
	print alive(env.host, port, appName)
        run('curl -X POST localhost:{}/act/shutdown'.format(port), warn_only=True)
        sleep(2)
        stop(env.host, port, appName)
    print('Application {} was stopped on port {}!!!'.format(appName, port))

@task
def showRefs(location, appName, jvmopt, profile ,svcport):
    print profile
    print svcport
