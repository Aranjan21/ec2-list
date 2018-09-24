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

import json
from urlparse import urlparse

api='https://api.eng.lunera.com'
username="jrai"
password="Pizza4dinner!"

def login(api,username,password):

	url = api + '/v1/login'

	payload = {"username":username,"password":password} 
	headers = {'Content-type': 'application/json', 'Accept': 'application/json'}

	data = requests.post(url, data=json.dumps(payload), headers=headers)

	binary = data.content	
	Parsed_data = json.loads(binary)
	#print Parsed_data
	return Parsed_data['token']

def getSerialNumber(api,token, lampId):

	url = api + '/v1/' + lampId 
	headers = {'authorization' : 'Bearer ' + token }

	data = requests.get(url, headers=headers)
	binary = data.content	
	Parsed_data = json.loads(binary)
        return Parsed_data['serialNumber']

def getFloorDetails(api,token, floorId):

	url = api + '/v1/' + floorId + '/lamps?inline=floor'
	headers = {'authorization' : 'Bearer ' + token }

	data = requests.get(url, headers=headers)
	binary = data.content	
	lamps_data = json.loads(binary)
	print ("Number of lamps {0} \n".format(len(lamps_data['lamps'])))
	print "------------------ LAMPS -----------------------------\n" 
        return lamps_data['lamps']

def getBuildingDetails(api,token, buildingId):

	url = api + '/v1/' + buildingId + '/floors?inline=floor'
	headers = {'authorization' : 'Bearer ' + token }

	data = requests.get(url, headers=headers)
	binary = data.content	
	building = json.loads(binary)
	#print "Hello World"
	print ("Number of floors {0} \n".format(len(building)))
	numFloors = len(building)
        for i in range(0, numFloors):
		print "------------------ ADDRESS -----------------------------" 
        	print  building['floors'][i]['address']

        return building['floors']

def getfacilitydetails(api,token):

	url = api + '/v1/facilities?inline=facility'
	headers = {'authorization' : 'Bearer ' + token }

	data = requests.get(url, headers=headers)

	binary = data.content	
	Parsed_data = json.loads(binary)
        facility = Parsed_data['facilities']	

	numFacilities = len(facility)
	print ("Number of facilities {0} \n".format(numFacilities))


        for i in range(0, numFacilities):
		print ("Facility ID : {0}".format(facility[i]['id']))

		floors = getBuildingDetails(api,token, facility[i]['id'])

		numFloors = len(floors)
	        for j in range(0, numFloors):
			lamps_floor = getFloorDetails(api,token, floors[j]['id'])			
		
			numLamps = len(lamps_floor)
	        	for k in range(0, numLamps):
				#print lamps_floor[k]
				serialNumber  = getSerialNumber(api,token, lamps_floor[k])			
	
				print ("{0}".format(serialNumber)) 
		



token = login(api,username,password)
getfacilitydetails(api,token)
