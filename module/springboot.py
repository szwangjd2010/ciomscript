from fabric.api import *
from time import sleep

jvmRefs = {
    'JVMOPT_1G' :'-Xms128m -Xmx1024m -Xss512k'
}

@task
def hello():
    run("echo hello")

def alive(port):
    output = run("pgrep -f 'server.port={}'| wc -l".format(port), warn_only=True)
    return int(output) > 1

@task
def deploy(location, appName, jvmopt, svcport):
    #for port in svcports.split('-'):
    shutdown(appName, svcport)
    sleep(2)
    start(location, appName, jvmopt, svcport)
    #sleep(2)
    #print run('curl localhost:{}/{}/v1/health'.format(port, appName),warn_only=True)

def start(location, appName, jvmopt, port):
    jvmOption = jvmRefs.get(jvmopt)
    run('nohup java {} -jar {}/{}/{}.jar --server.port={} >/dev/null &'.format(jvmOption, location, appName, appName, port), pty=False)  

def shutdown(appName, port):
    if alive(port):
        run('curl -X POST localhost:{}/shutdown'.format(port), warn_only=True)
    print('Application {} was stopped on port {}!!!'.format(appName, port))
