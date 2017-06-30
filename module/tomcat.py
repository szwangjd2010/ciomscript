from fabric.api import *
from time import sleep

@task
def hello():
    run("echo hello")

def alive(location):
    output = run("pgrep -c -f '%s'" % location, warn_only=True)
    return int(output) == 1

@task
def stop(location):
    if alive(location):
        run("pkill -9 -f '%s'" % location, warn_only=True)
        sleep(2)
    print('tomcat stoped: %s' % location)


@task
def start(location):
    run('%s/bin/startup.sh' % location, pty=False)  
    print('tomcat started: %s' % location)

def detach(location, appName, asRoot, extract):
    cmd = 'rm -rf webapps/{{{},ROOT}}'.format(appName)
    if not extract:
        cmd += '.war'
    
    with cd(location):
        run(cmd)


def attach(location, appName, asRoot, extract):
    webappName = 'ROOT' if asRoot else appName
    with cd(location):
        if extract:
            run('unzip {}.war -d webapps/{}'.format(appName, webappName))
        else:
            run('cp {}.war webapps/{}.war'.format(appName, webappName))

@task
def deploy(location, appName, asRoot=False, extract=True):
    stop(location)
    detach(location, appName, asRoot, extract)
    attach(location, appName, asRoot, extract)
    start(location)
