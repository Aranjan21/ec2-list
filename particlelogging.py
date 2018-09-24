import os
import sys
import re
import time
import smtplib,datetime,random
from datetime import datetime
from pytz import timezone
import pytz
import socket
import cStringIO

result = " "
FROM = "jenkins@lunera.com"
email_notify_address=[$1]

def send_email(result):
    hostname = (socket.gethostname())
    date_format='%m%d%Y_%H%M%S'
    date = datetime.now(tz=pytz.utc)
    date = date.astimezone(timezone('US/Pacific'))
    timestamp = date.strftime(date_format)

    SUBJECT = "Particle Log Report"
    TEXT    =  result

    # Prepare actual message
    message = """From: %s\nTo: %s\nSubject: %s\n\n%s
    """ % (FROM, ", ".join(email_notify_address), SUBJECT, TEXT)
    server=smtplib.SMTP("smtp.office365.com", 587)
    server.starttls()
    password = "Lun@2017!"
    server.login(FROM, password)
    server.sendmail(FROM, email_notify_address, message)


while 1:

    date_format='%m%d%Y_%H%M%S'
    date = datetime.now(tz=pytz.utc)
    date = date.astimezone(timezone('US/Pacific'))
    timestamp = date.strftime(date_format)

    result = "BEGIN PARTICLE LOG : " + timestamp + " \n\n"

    particle_log_file = "particle_" + timestamp + ".log"
    print particle_log_file

    with open(particle_log_file,"a") as log_file:

       API = "curl -m 14400 https://api.particle.io/v1/devices/events?access_token=9ec5cc3c1c2f593c7edb10b93ac8e5b407da6af4"  + " > " + particle_log_file
       os.popen(API)

       log_file.close()
       
    API = "grep -c "  + "\"event:\" " + particle_log_file
    print API
    numOfRecords = os.popen(API).read()

    result += "NUM OF EVENTS : " + numOfRecords + " \n"

    API = "grep -c "  + "\"assetTracker\" " + particle_log_file
    print API
    numOfAssetTrackerEvents = os.popen(API).read()
    
    result += "NUM ASSET TRACKER EVENTS : " + numOfAssetTrackerEvents + " \n"

    API = "grep -c "  + "\"error\" " + particle_log_file
    print API
    numOfErrors = os.popen(API).read()
    
    result += "NUM ERRORS : " + numOfErrors + " \n"

    API = "grep -c "  + "\"rate limit\" " + particle_log_file
    print API
    numOfRateLimit = os.popen(API).read()
    
    result += "NUM RATE LIMIT ERRORS: " + numOfRateLimit + " \n"

    API = "gzip "  +    particle_log_file
    print API
    os.popen(API)

    API = "aws s3 cp " + particle_log_file + ".gz s3://lunera-logs/"
    print API
    os.popen(API)
    
    result += "PARTICLE LOG : s3://lunera-logs/" + particle_log_file + ".gz \n \n"

    date = datetime.now(tz=pytz.utc)
    date = date.astimezone(timezone('US/Pacific'))
    timestamp = date.strftime(date_format)

    result += "END TIMESTAMP : " + timestamp + " \n"

    print result

    send_email(result)

    API = "rm -f " + particle_log_file + ".gz" 
    print API
    os.popen(API)
