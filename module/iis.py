from fabric.api import *
from time import sleep

haoyaCmd="\"C:\\Program Files\\2345Soft\\HaoZip\\HaoZipC.exe\""
appCmd="C:\\Windows\\System32\\inetsrv\\appcmd.exe"
@task
def hello():
    run("echo hello")

def alive(location):
    output = run("pgrep -c -f '%s'" % location, warn_only=True)
    return int(output) == 1

def winrun(cmd):
    run(cmd, warn_only=True, shell=False, pty=False)

@task
def stop():
    print('stop iis...!')
    winrun("iisreset /stop")
    print('iis stoped!')

@task
def stopSite(sitename):
    print('stop site: {} ...'.format(sitename))
    winrun("{} stop site /site.name:{}".format(appCmd,sitename))
    print('site stoped!')

@task
def start():
    print('start iis...!')
    winrun("iisreset /start")
    print('iis started!')

@task
def startSite(sitename):
    print('start site: {} ...'.format(sitename))
    winrun("{} start site /site.name:{}".format(appCmd,sitename))

@task
def status():
    print('status iis...!')
    winrun("iisreset /status")

def clean(location,appName):
    winrun("powershell \"Get-Process explorer |Stop-Process\"")
    winrun("RD /S /Q {}\{}\{}".format(location,appName,appName))

def attach(location, appName):
    winrun("{} x {}\{}\{}.zip -aoa -o{}\{}".format(haoyaCmd,location,appName,appName,location,appName))

@task
def deploy(location, appName):
    #stop()
    clean(location, appName)
    attach(location, appName)
    #start()
