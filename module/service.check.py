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
    VcaDefLocation = None
    appDict = None


    def __init__(self, version, cloudId, appName):
        # Get host and port info from ciom.json
        self.VcaDefLocation = os.path.join(os.environ.get("CIOM_VCA_HOME"), version, 'pre', cloudId,
                                                          appName)
        self.appDict = json.loads(open(os.path.join(self.VcaDefLocation, 'ciom.json')).read())

    
    def GetappDict(self):
        return self.appDict



if __name__ == '__main__':
    imapi_eureka = Eureka(EurekaHost["dev"], port="7000")
    imapi = SpringbootService('v0.3', 'dev', 'imapi')
    # Get
    print imapi_eureka.GetInstanceList("imapi")
    print imapi.GetappDict()["deploy"]["hosts"]
    
