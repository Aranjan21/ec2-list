###########################################################################################
#Author :@Abhishek Ranjan					                                                      ###
#Email: abhishek.ranjan@oronetworks.com                                                 ###  
#Description : Display All the Asset types and UUIDs used                               ###
#Date: 15 Auguts 2018									                                                  ###                   
###########################################################################################

#Import all the modules which is required for python to run 
import sys
import Queue
import threading
import pycurl
import cStringIO
import json
import time
import urllib
import os
import requests

import smtplib,datetime,random
from datetime import datetime
from pytz import timezone
import pytz
import socket

import json
from urlparse import urlparse

api=sys.argv[1]
username=sys.argv[2]
password=sys.argv[3]


# Define main function to call others methods 
def main():
    global api
    token = login(api,username,password)
    getAssetTrackingStatus(api, token)
    getAllUUIDs(api, token)
    getAllAssetTypes(api, token)
    getAllAssets(api, token)
    getsubscription(api, token)

#Define login method for customer details and accepting credentials
def login(api,username,password):

        url = api + '/v1/login'
        global customerId

        payload = {"username":username,"password":password}
        headers = {'Content-type': 'application/json', 'Accept': 'application/json'}

        data = requests.post(url, data=json.dumps(payload), headers=headers)

        if data.status_code == requests.codes.ok:
            print '\n Hello Mr.'+ ' '+ username +  ' ! Your Details are as follows '
            binary = data.content
            Parsed_data = json.loads(binary)
            return Parsed_data['token']
        else:
            print 'Hello !! Your login Credential is INCORRECT'
            return None

#Define function to get the status of asset tracking 

def getAssetTrackingStatus(api, token):

    url = api + '/v1/assettracking/enabled'
    headers = {'authorization' : 'Bearer ' + token , 'content-type': 'application/json' }
   

    data = requests.get(url, headers=headers)
    if data.status_code == requests.codes.ok:
        binary = data.content
        Asset_status = json.loads(binary)
        print("\n**************AssetTracking Enabled/Disabled Status*********************")
        print("Asset_status = {0}".format(Asset_status))
        
    else:
        print ("{0} failed with code {1}".format(url, data.status_code)) 

#Define function to get all UUIDS listed 

def getAllUUIDs(api, token):

    url = api + '/v1/assettracking/uuids'
    headers = {'authorization' : 'Bearer ' + token,  'content-type': 'application/json' }

    data = requests.get(url,  headers=headers)
    if data.status_code == requests.codes.ok:
        binary = data.content
        Asset_UUids = json.loads(binary)
        print("\n************************LIST OF ALL UUIDs*****************************")
        #print("Asset_UUids = {0}".format(Asset_UUids))
        print json.dumps(Asset_UUids, sort_keys=True, indent=4, separators=(',', ': '))
        
    else:
        print ("{0} failed with code {1}".format(url, data.status_code))

#Define function to get all assettypes
def getAllAssetTypes(api, token):

    url = api + '/v1/assettracking/assettypes'
    headers = {'authorization': 'Bearer ' + token, 'content-type': 'application/json'}
    
    data = requests.get(url,  headers=headers)
    if data.status_code == requests.codes.ok:
        binary = data.content
        Asset_Types = json.loads(binary)
        print("\n**************************All ASSETS TYPES***************************")
        #print("Asset_Types = {0}".format(Asset_Types))
        print json.dumps(Asset_Types, sort_keys=True, indent=4, separators=(',', ': '))

     
    else:
        print ("{0} failed with code {1}".format(url, data.status_code))

#Define function to get all assets 
def getAllAssets(api, token):

    url = api + '/v1/assettracking/assets?inline=location'
    headers = {'authorization': 'Bearer ' + token, 'content-type': 'application/json'}
    
    data = requests.get(url,  headers=headers)
    if data.status_code == requests.codes.ok:
        binary = data.content
        All_Assets = json.loads(binary)
        #print("All_Assets = {0}".format(All_Assets))
        print("\n**********************All_ASSETS*************************************")        
        #print("All_Assets id = {0}".format(['id'])) 
        print json.dumps(All_Assets, sort_keys=True,indent=4, separators=(',', ': '))
    else:
        print ("{0} failed with code {1}".format(url, data.status_code))


def getsubscription(api, token):

    url = api + '/v1/assettracking/subscriptions'
    headers = {'authorization': 'Bearer ' + token, 'content-type': 'application/json'}
    
    data = requests.get(url,  headers=headers)
    if data.status_code == requests.codes.ok:
        binary = data.content
        subscription = json.loads(binary)
        #print("All_Assets = {0}".format(All_Assets))
        print("\n**********************Subscribe for Notification*********************************")        
        #print("All_Assets id = {0}".format(['id'])) 
        print json.dumps(subscription, sort_keys=True,indent=4, separators=(',', ': '))
    else:
        print ("{0} failed with code {1}".format(url, data.status_code))




if __name__ == "__main__":
        main()
