import os
import sys
import json
import requests

EurekaHost={"dev": "172.17.128.156"}

class Eureka:
    """ Eureka server
    """
    host = None
    port = None
    s = requests.Session()
    s.headers.update({"Content-Type": "application/json", "Accept": "application/json"})


    def __init__(self,host='127.0.0.1', port="7000"):
        self.host = host
        self.port = port


    def GetInstanceList(self, app):
        """Get the instance list of specified application
        :Param app: the application name
        :Return: the ip address list of the running instances
        """
        resp = self.s.get("http://{}:{}/eureka/apps/{}".format(self.host, self.port, app))
        DictResp = json.loads(resp.content)

        rtr = []
        for each in DictResp["application"]["instance"]:
            rtr.append(each["ipAddr"])
        return rtr
       

class SpringbootService:
    host = None
    port = None
    appName = None
    s = requests.Session()


    def __init__(self, host, port, appName):
        # Get host and port info from ciom.json
        self.host = host
        self.port = port
        self.appName = appName
        
    
    def GetStatus(self, retry=0):
        if retry == 3:
            return False
        try:
            resp = self.s.get("http://{}:{}/serverstatus".format(self.host, self.port))
        except requests.exceptions.ConnectionError:
            if self.GetStatus(retry+1):
                return True
            else:
                return False
        
        if resp.status_code == 200:
            return True
        else:
            return False

