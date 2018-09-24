#!/usr/bin/python3
#Version: 0.0.3

import csv, os, sys, smtplib
from  library import helper as hl
from datetime import *

import time
##########
ENV = os.getenv("ENV", "cloud")
tagKey = "env"
tagvalue = "production"
if ENV == "eng":
    tagvalue = "staging"
timegap =  4 ##In Hours
email_notify_address=["robert.young@oronetworks.com"]
#email_notify_address=["robert.young@oronetworks.com","sanjay.gandotra@oronetworks.com","kuan.ho@oronetworks.com","jrai@lunera.com"]
##########
FROM = "jenkins@lunera.com"
currentTime = datetime.utcnow()
previousTime = (datetime.utcnow() - timedelta(seconds=timegap*60*60))

########
def main():
    sqsHtmlReport = ''
    rdsHtmlReport = ''
    instanceHtmlReport = ''
    sqsHtmlReport = getSqsReport()
    rdsHtmlReport = getRdsReport(currentTime,previousTime)

    instanceHtmlReport = getInstanceReport(tagKey,tagvalue,currentTime,previousTime)

    htmlMsg = '<!DOCTYPE html><html><head><style>table, th , td{border: 1px solid black;}</style></head><body><table>\n' \
                '<h3><font color="blue">LUNERA | ENV: '+ ENV.upper() +'| INSTANCES REPORT:</font></h3>\n'\
                '<table>'+instanceHtmlReport+'</table>\n'\
                '<h3><font color="blue">LUNERA | ENV: '+ ENV.upper() +' | RDS REPORT:</font></h3>\n'\
                '<table>'+rdsHtmlReport+'</table>\n'\
                '<font color="blue"><h3>LUNERA | ENV: '+ ENV.upper() +' | SQS REPORT :</h3></font>\n'\
                '<table>'+sqsHtmlReport+'</table>\n'\
                '</table></body></html>\n'

    # print(htmlMsg)
    send__mail(htmlMsg,email_notify_address)


def send__mail(htmlMsg,email_notify_address):
    SUBJECT = ENV.upper() + " Lunera Server Usage Report | Region : Ohio\nContent-Type: text/html"

    message = """From: %s\nTo: %s\nSubject: %s\n\n%s
    """ % (FROM, ", ".join(email_notify_address), SUBJECT, htmlMsg)
    server=smtplib.SMTP("smtp.office365.com", 587)
    server.starttls()
    password = "Lun@2017!"
    server.login(FROM, password)
    server.sendmail(FROM, email_notify_address, message)

def getInstanceReport(tagKey,tagvalue,currentTime,previousTime):
    instanceHtmlReport = ''
    headerHtml = ''
    dataHtml = ''
    heading1 = ['SERVERNAME','CPU ','(%)','MEMORY','(%)','DISK','(%)',]
    heading2= ['','Current','Previous','Current','Previous','Current','Previous' ]
    headings =[heading1,heading2]
    for heading in headings:
        headerHtml = headerHtml+'<tr>'
        for header in heading:
            headerHtml = headerHtml+'<th>'+header+'</th>'
        headerHtml = headerHtml+'</tr>\n'

    instanceIdsList = hl.GetInstanceIds(tagKey,tagvalue)

    instance_name_to_id = {}

    for instanceId in instanceIdsList:
        awsName = hl.GetAwsNameTag(instanceId).split(" ", 1)[-1]
        index = 1
        # handle multiple instances with the same Name tag
        while awsName in instance_name_to_id:
            index += 1
            new_name = awsName + "[index]"
            if not awsName in instance_name_to_id:
                awsName = new_name
        instance_name_to_id[awsName] = instanceId

    for name in sorted(instance_name_to_id):
        print( name )
        instance_id = instance_name_to_id[name]
        cpu = hl.CPUUtilization(instance_id,currentTime)
        cpuP = hl.CPUUtilization(instance_id,previousTime)
        memory = hl.MemoryUtilization(instance_id,currentTime)
        memoryP = hl.MemoryUtilization(instance_id,previousTime)
        disk = hl.DiskUtilization(instance_id,currentTime)
        diskP = hl.DiskUtilization(instance_id,previousTime)

        dataHtml = dataHtml+'<tr>'+'<td>'+name+'</td>' \
                            + formatCell(cpu,"") + formatCell(cpuP,"") \
                            + formatCell(memory,"") + formatCell(memoryP,"") \
                            + formatCell(disk,"disk") + formatCell(diskP,"disk") \
                            +'</tr>\n'

    instanceHtmlReport = headerHtml+dataHtml
    return instanceHtmlReport


def formatCell(data, type):
    # default values for cpu and memory
    threshold_yellow = 40
    threshold_red = 60
    if type == "disk":
        threshold_yellow = 40
        threshold_red = 80
    elif type == "sqs":
        threshold_yellow = 5
        threshold_red = 100
    elif type == "db":
        threshold_yellow = 50
        threshold_red = 80

    if data == "N/A":
        return '<td></td>'
    if not isinstance(data,int):
        return '<td>'+str(data)+'</td>'
    if int(data) > threshold_red:
        return '<td bgcolor=red>'+str(data)+'</td>'
    if int(data) > threshold_yellow:
        return '<td bgcolor=yellow>'+str(data)+'</td>'
    return '<td>'+str(data)+'</td>'

def getSqsReport():
    sqsHtmlReport = ''
    headerHtml = ''
    dataHtml = ''
    heading = ['Name','Message Available','Message In Flight','Message Delayed']
    for header in heading:
        headerHtml = headerHtml+'<th>'+header+'</th>'
    headerHtml = '<tr>'+headerHtml+'</tr>'
    sqsList = hl.getSqsList()
    for sqs in sqsList:
        name = sqs.split("/")[4]
        messageAvailableVisible = hl.sqsAttributes(sqs,'ApproximateNumberOfMessages')
        messageAvailableNotVisible = hl.sqsAttributes(sqs,'ApproximateNumberOfMessagesNotVisible')
        messageDelayed = hl.sqsAttributes(sqs,'ApproximateNumberOfMessagesDelayed')
        dataHtml = dataHtml+'<tr>'+'<td>'+name+'</td>' \
                           +formatCell(messageAvailableVisible,"sqs") \
                           +formatCell(messageAvailableNotVisible,"") \
                           +formatCell(messageDelayed,"")+'</tr>\n'
        # dataHtml = dataHtml+'<tr>'+'<td>'+name+'</td>'+'<td>'+messageAvailableVisible+'</td>' \
        #                                 +'<td>'+messageAvailableNotVisible+'</td>'+'<td>'+messageDelayed+'</td>'+'</tr>\n'
    sqsHtmlReport = headerHtml+dataHtml
    return sqsHtmlReport


def getRdsReport(currentTime,previousTime):
    rdsHtmlReport = ''
    headerHtml = ''
    dataHtml = ''
    heading1 = ['Rds Name','CPU','(%)','Storage Used','(%)','DB Connection','(Count)']
    heading2= ['','Current','Previous','Current','Previous','Current','Previous' ]
    headings =[heading1,heading2]
    for heading in headings:
        headerHtml = headerHtml+'<tr>'
        for header in heading:
            headerHtml = headerHtml+'<th>'+header+'</th>'
        headerHtml = headerHtml+'</tr>\n'

    rdsIdentifiersList = hl.getRdsIdentifiers()
    for rds in rdsIdentifiersList:
        storageSpace = hl.getRdsDbStorageSize(rds)

        cpu = hl.rdsMetrix(rds,'CPUUtilization',currentTime)
        storage = (hl.rdsMetrix(rds,'FreeStorageSpace',currentTime))/(1024**3)
        disk = round(((storageSpace - storage)/storageSpace)*100)
        dbcon = hl.rdsMetrix(rds,'DatabaseConnections',currentTime)
        cpuP = hl.rdsMetrix(rds,'CPUUtilization',previousTime)
        storageP = (hl.rdsMetrix(rds,'FreeStorageSpace',previousTime))/(1024**3)
        diskP = round(((storageSpace - storage)/storageSpace)*100)
        dbconP = hl.rdsMetrix(rds,'DatabaseConnections',previousTime)

        dataHtml = dataHtml+'<tr>'+'<td>'+rds+'</td>' \
                           + formatCell(cpu, "") + formatCell(cpuP,"") \
                           + formatCell(disk, "disk") + formatCell(diskP,"disk") \
                           + formatCell(dbcon, "db") + formatCell(dbconP,"db") + '</tr>\n'
    rdsHtmlReport = headerHtml+dataHtml
    return rdsHtmlReport


main()
