import sys
import json
import time
import urllib
import smtplib
import socket
from datetime import datetime
from pytz import timezone
import pytz
import os
import requests


def deployservice(jumphost, servername, indexes, service, version):
    print('Hello')
    print(indexes)  
    for index in indexes:
     
            cmd="ssh -TAtt ubuntu@"  + jumphost + " ssh -A ubuntu@" + servername + index + ".dev.lunera.com 'sh push/deploy-service.sh " + service + " " + version +"'" 
            print(cmd)
            os.popen(cmd).read()
            #print(status)
            
            cmd="ssh -TAtt ubuntu@"  + jumphost + " ssh -A ubuntu@" + servername + index + ".dev.lunera.com 'cat /lunera/code/" + service + "/current/version.txt'"
            print(cmd)
            version  = os.popen(cmd).read().rstrip()
            print(" deployed version {0} {1}".format(service,version))

def main():

    for index in range(1, len(sys.argv)):
            print(sys.argv[index])
            param = (sys.argv[index])
            paramname = param.split('=')[0]
            value = param.split('=')[1]

            if 'env' in paramname:
                env = value
            if 'server' ==  paramname:
                server = value 
            if 'service' in paramname: 
                service = value
            if 'version' in paramname:
                version =  value
            if 'numservers' ==  paramname:
                numservers =  int(value)
                print(numservers)

    print("env = {0} server = {1} numservers = {2}  service = {3} version = {4}".format(env, server, numservers,  service, version))

    jumphostcloud = '18.221.144.194'
    jumphosteng   = '13.59.242.61'

    if env == 'eng':
       jumphost = jumphosteng
    elif env == 'cloud':
       jumphost = jumphostcloud
    
    indexes = []
    indexstr = ['01', '02', '03', '04']

    for a in range(0,numservers):
        indexes.append(indexstr[a])    

    print(indexes)
    
    #sys.exit()

    deployservice(jumphost, server, indexes, service, version)

main()
