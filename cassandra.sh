###########################################################################################
#Author :@Abhishek Ranjan                                                                ##
#Email: abhishek.ranjan@oronetworks.com                                                  ##
#Description: Script to get list of all files/folders from path /lunera/code/*/current   ##
#Last Modified : 27-08-2018                                                              ##
###########################################################################################


#Set the PATH and TERM because piping a script to sshpass via STDIN does not initialize a terminal
export PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin
export TERM=xterm

#!/bin/bash

#DELETE THE DIFFF Folder
rm -f diff1.html diff.html Eng-PublicApi01 Eng-PublicApi01. Prod-PublicApi01 Prod-PublicApi02
#THIS  CALLS THE VERSION-DIFF SCRIPTS RESIDING ON DIFFERENT folderss

sh /home/ubuntu/ranjan/scripts/FINAL/version-list.sh

echo "This  represent difference in  files of respective services encountered in the servers starting from ENG Region.    Heirarchy of Comparison : ENG-->ENG , PROD-->PROD , ENG-->PROD   !!!" >>  diff1.html

printf " NOTE:-RED color indicates changes in the contents of file\n" >>diff1.html

echo -e "################ASSETTRACKING#####################"

Eng_Server=172.16.1.108,172.16.0.65
Prod_Server=172.17.2.44,172.17.1.245
a=1;
for server in $(echo $Eng_Server |sed "s/,/ /g")
    do
        echo "############$server ENG ASSETTRACKING  COLLECTING FILES ###########"
            ssh -i /home/scripts/LuneraDev.pem -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@$server 'find /lunera/code/AssetTracking/current/ -type f -follow -print -exec ls -lR -1 {} \;| awk '"'"'{print$5"\t\t"$9}'"'"'|sort -n|awk 'NF'' > Eng-AssetTracking0$a
                let "a++"
    done

a=1;
#SSH into CLOUD ASSET Tracking

for server in $(echo $Prod_Server |sed "s/,/ /g")
    do
        echo -e "#############$server PROD ASSETTRACKING COLLECTING FILES "
            ssh -TAtt ubuntu@18.221.144.194 ssh -A ubuntu@$server sh /home/ubuntu/file-diff.sh > Prod-AssetTracking0$a
                let "a++"
    done
# Comparison between ENG Asset Tracking
if [[ ($(diff Eng-AssetTracking01 Eng-AssetTracking02)) ]];then
    vimdiff Eng-AssetTracking01 Eng-AssetTracking02 -c TOhtml -c 'w! >> diff1.html' -c 'qa!'
        else
            echo "NO CHANGE"
fi

if [[ ($( diff Prod-AssetTracking01 Prod-AssetTracking02)) ]];then
    vimdiff Prod-AssetTracking01 Prod-AssetTracking02 -c TOhtml -c 'w! >> diff1.html' -c 'qa!'
        else
            echo "NO CHANGE"
fi

#if [[ ($( diff Prod-AssetTracking01 Eng-AssetTracking01)) ]];then
#    vimdiff Prod-AssetTracking01 Eng-AssetTracking01 -c TOhtml -c 'w! >> diff1.html' -c 'qa!'
#        else
#            echo -e "ASSETTRACKING NO_CHANGE" >>diff.txt
#                awk 'BEGIN { print "<table border=2>" }; { printf( "<tr><td>%s</td><td>%s</td></tr>\n", $1 ,$2) } #END { print "</table></ br ></ br></ br>" }' diff.txt >>diff.html
#fi

echo -e "#####################DATA-API SERVER####################"

EngDataApi=172.16.1.108,172.16.0.65
ProdDataApi=172.17.11.81,172.17.12.188,172.17.13.226

a=1;

for server in $(echo $EngDataApi |sed "s/,/ /g")
    do
        echo "##############$server ENG DATA-API COLLECTING FILES#################"
            ssh -i /home/scripts/LuneraDev.pem -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@$server 'find /lunera/code/data-api-server/current/ -type f -follow -print -exec ls -lR -1 {} \;| awk '"'"'{print$5"\t\t"$9}'"'"'|sort -n|awk 'NF'' > Eng-DataApi0$a
                let "a++"
    done

a=1;
for server in $(echo $ProdDataApi |sed "s/,/ /g")
    do
        echo "##############$server PROD DATA-API COLLECTING FILES###############"
            ssh -TAtt ubuntu@18.221.144.194 ssh -A ubuntu@$server sh /home/ubuntu/scripts/file-diff.sh > Prod-DataApi0$a
                let "a++"
    done

#Comparison between ENG DATA API SERVER
if [[ ($(diff Eng-DataApi01 Eng-DataApi02)) ]];then
    vimdiff Eng-DataApi01 Eng-DataApi02 -c TOhtml -c 'w! >> diff1.html' -c 'qa!'
        else
            echo "NO CHANGE"

fi

# Comparison between PROD DATA API SERVER
if [[ ($(diff3 Prod-DataApi01 Prod-DataApi02 Prod-DataApi03)) ]];then
    vimdiff Prod-DataApi01 Prod-DataApi02 Prod-DataApi03 -c TOhtml -c 'w! >> diff1.html' -c 'qa!'
        else
            echo "NO CHANGE"

fi

#CROSS COMPARISON between Eng and PROD
if [[ ($(diff Prod-DataApi01 Eng-DataApi01)) ]];then
    vimdiff Prod-DataApi01 Eng-DataApi01 -c TOhtml -c 'w! >> diff1.html' -c 'qa!'
        else
            echo -e "DATA-API-SERVER NO_CHANGE" >>diff.txt
                    awk 'BEGIN { print "<table border=2>" }; { printf( "<tr><td>%s</td><td>%s</td></tr>\n", $1 ,$2) } END { print "</table></ br ></ br></ br>" }' diff.txt >>diff.html
fi

echo -e "#####################DATA-DAEMON##########################"

Eng_Server=172.16.1.108,172.16.0.65
Prod_Server=172.17.11.171,172.17.12.40,172.17.13.176

a=1;

for server in $(echo $Eng_Server |sed "s/,/ /g")
    do
        echo -e "#################$server ENG DATA-DAEMON COLLECTING FILES#####################"
            ssh -i /home/scripts/LuneraDev.pem -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@$server 'find /lunera/code/data-*er/current/ -not -path "/lunera/code/data-api-server/*" -type f -follow -print -exec ls -lR -1 {} \;| awk '"'"'{print$5"\t\t"$9}'"'"'|sort -n|awk 'NF'' > Eng-DataDaemon0$a
                let "a++"
    done

#SSH into CLOUD DATA DAEMON

a=1;
for server in $(echo $Prod_Server |sed "s/,/ /g")
    do
        echo -e "###################$server PROD DATA_DAEMON COLLECTING FILES####################"
            ssh -TAtt ubuntu@18.221.144.194 ssh -A ubuntu@$server sh /home/ubuntu/scripts/file-diff.sh     >Prod-DataDaemon0$a
                let "a++"
    done

#Comparison between ENG DATA DAEMON

if [[ ($(diff Eng-DataDaemon01 Eng-DataDaemon02)) ]];then
    vimdiff Eng-DataDaemon01 Eng-DataDaemon02 -c TOhtml -c 'w! >> diff1.html' -c 'qa!'
        else
            echo "NO CHANGE"
fi

#Comparison between PROD DATA DAEMON

if [[ ($(diff3 Prod-DataDaemon01 Prod-DataDaemon02 Prod-DataDaemon03)) ]];then
    vimdiff Prod-DataDaemon01 Prod-DataDaemon02 Prod-DataDaemon03 -c TOhtml -c 'w! >>diff1.html' -c 'qa!'
        else
            echo "NO CHANGE"
fi

# CROSS COMPARISON BETWWEN ENG AND PROD

if [[ ($(diff Prod-DataDaemon01 Eng-DataDaemon01)) ]];then
    vimdiff Prod-DataDaemon01 Eng-DataDaemon01 -c TOhtml -c 'w! >> diff1.html' -c 'qa!'
        else
            echo -e "DATA-DAEMON-SERVER NO_CHANGE" >>diff.txt
                    awk 'BEGIN { print "<table border=2>" }; { printf( "<tr><td>%s</td><td>%s</td></tr>\n", $1 ,$2) } END { print "</table></ br ></ br></ br>" }' diff.txt >>diff.html
fi

echo -e "#####################PARTICLE-SQS##########################"

Eng_Server=172.16.1.108,172.16.0.65
Prod_Server=172.17.1.97,172.17.2.53

a=1;
for server in $(echo $Eng_Server |sed "s/,/ /g")
    do
          echo "##############$server ENG PARTICLE_SQS COLLECTING FILES#################"
            ssh -i /home/scripts/LuneraDev.pem -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@$server 'find /lunera/code/particle-sqs/current/ -type f -follow -print -exec ls -lR -1 {} \;| awk '"'"'{print$5"\t\t"$9}'"'"'|sort -n|awk 'NF'' > Eng-ParticleSqS0$a
                let "a++"
    done

#SSH into cloud PARTICLE_SQS

a=1;
for server in $(echo $Prod_Server |sed "s/,/ /g")
    do
        echo "####################$server PROD PARTICLE_SQS COLLECTING FILES#################"
            ssh -TAtt ubuntu@18.221.144.194 ssh -A ubuntu@$server sh /home/ubuntu/scripts/file-diff.sh >Prod-ParticleSqS0$a
                let "a++"
    done

#COMPARISON BETWEEN ENG PARTICLE-SQS

if [[ ($(diff Eng-ParticleSqS01 Eng-ParticleSqS02)) ]];then
    vimdiff Eng-ParticleSqS01 Eng-ParticleSqS02 -c TOhtml -c 'w! >>diff1.html' -c 'qa!'
        else
            echo "NO CHANGE"
fi

#COMPARISON BETWEEN PROD PARTICLE_SQS

if [[ ($(diff Prod-ParticleSqS01 Prod-ParticleSqS02)) ]];then
    vimdiff Prod-ParticleSqS01 Prod-ParticleSqS02 -c TOhtml -c 'w! >>diff1.html' -c 'qa!'
        else
            echo "NO CHANGE"
fi

#CROSS COMPARISON BETWEEN EMG AND PROD
if [[ ($(diff Prod-ParticleSqS01 Eng-ParticleSqS01)) ]];then
    vimdiff Prod-ParticleSqS01 Eng-ParticleSqS01 -c TOhtml -c 'w! >>diff1.html' -c 'qa!'
        else
            echo -e "PARTICLE-SQS-SERVER NO_CHANGE" >>diff.txt
                    awk 'BEGIN { print "<table border=2>" }; { printf( "<tr><td>%s</td><td>%s</td></tr>\n", $1 ,$2) } END { print "</table></ br ></ br></ br>" }' diff.txt >>diff.html
fi

echo -e "###########################PUBLIC-API SERVER###########################"

Eng_Server=172.16.1.108,172.16.0.65
Prod_Server=172.17.1.146,172.17.2.178

a=1;
for server in $(echo $Eng_Server |sed "s/,/ /g")
    do
        echo -e "######################$server ENG PUBLIC_API COLLECTING FILES#########################"
            ssh -i /home/scripts/LuneraDev.pem -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no ubuntu@$server 'find /lunera/code/*/current/ -not -path "/lunera/code/AssetTracking/*" -not -path "/lunera/code/data-api-server/*" -not -path "/lunera/code/data-mapper/*" -not -path "/lunera/code/data-reducer/*" -not -path "/lunera/code/particle-sqs/*" -type f -follow -print -exec ls -lR -1 {} \;| awk '"'"'{print$5"\t\t"$9}'"'"'' >Eng-PublicApi0$a
                let "a++"
    done

# SSH INTO OPSGENIE SERVER

        ssh ubuntu@opsgenie01.dev.lunera.com 'find /lunera/code/opsgenie/current -type f -follow -print -exec ls -lR -1 {} \;| awk '"'"'{print$5"\t\t"$9}'"'"'' >> Eng-PublicApi01

                ssh ubuntu@opsgenie02.dev.lunera.com 'find /lunera/code/opsgenie/current -type f -follow -print -exec ls -lR -1 {} \;| awk '"'"'{print$5"\t\t"$9}'"'"'' >> Eng-PublicApi02

sort -n Eng-PublicApi01|awk 'NF' > Eng-PublicApi01.
sort -n Eng-PublicApi02|awk 'NF' > Eng-PublicApi02.
#SSH INTO PROD PUBLIC API

a=1;
for server in $(echo $Prod_Server |sed "s/,/ /g")
    do
        echo -e "##########################$server PROD PUBLIC_API COLLECTING FILES#####################"
            ssh -TAtt ubuntu@18.221.144.194 ssh -A ubuntu@$server sh /home/ubuntu/scripts/file-diff.sh >Prod-PublicApi0$a
                let a++
    done

#COMPARIOSN BETWEEN ENG PUBLIC API SERVER

if [[ ($(diff Eng-PublicApi01. Eng-PublicApi02.)) ]];then
    vimdiff Eng-PublicApi01. Eng-PublicApi02. -c TOhtml -c 'w! >>diff1.html' -c 'qa!'
        else
            echo "NO CHANGE"
fi

if [[ ($(diff Prod-PublicApi01 Prod-PublicApi02)) ]];then
    vimdiff Prod-PublicApi01 Prod-PublicApi02 -c TOhtml -c 'w! >>diff1.html' -c 'qa!'
        else
            echo "NO CHANGE"
fi

#CROSS COMPARISON BETWWEN ENG AND PROD
if [[ ($(diff Prod-PublicApi01 Eng-PublicApi01.)) ]];then
    vimdiff Prod-PublicApi01 Eng-PublicApi01. -c TOhtml -c 'w! >>diff1.html' -c 'qa!'
        else
            echo -e "PUBLIC_API_SERVER NO_CHANGE" >>diff.txt
                    awk 'BEGIN { print "<table border=2>" }; { printf( "<tr><td>%s</td><td>%s</td></tr>\n", $1 ,$2) } END { print "</table></ br ></ br></ br>" }' diff.txt >>diff.html
fi

#DELETE ALL FILES TO MAKE WORKSPACE CLEAN

rm -f Eng-DataApi01 Eng-DataDaemon01 Eng-DataDaemon02 Eng-ParticleSqS01 Eng-ParticleSqS02  Prod-AssetTracking01 Prod-AssetTracking02 Prod-DataApi02 Prod-DataApi03 Prod-DataDaemon01 Prod-DataDaemon02 Prod-ParticleSqS01 Prod-ParticleSqS02



#     DETAILS OF SCHEMA DETAILS

echo -e "########################SCHEMA DIFF OF CASSANDRA SERVER###########################"

#Logging to ENG CASSANDRA

ssh -A ubuntu@cassandra0001.dev.lunera.com "bash schema.sh" > Eng-Cassandra.cql
ssh -A ubuntu@cassandra0002.dev.lunera.com "bash schema.sh" > Eng0002.cql
ssh -A ubuntu@cassandra0003.dev.lunera.com "bash schema.sh" > Eng0003.cql

#Logging to PROD CASSANDRA

ssh -TAtt ubuntu@18.221.144.194 ssh -A ubuntu@172.17.11.220 "bash schema.sh" > Prod-Cassandra.cql
ssh -TAtt ubuntu@18.221.144.194 ssh -A ubuntu@172.17.12.181 "bash schema.sh" > Prod0002.cql
ssh -TAtt ubuntu@18.221.144.194 ssh -A ubuntu@172.17.13.49  "bash schema.sh" > Prod0003.cql

############################SCHEMA DIFF OF RDS SERVER############################

#Logging to ENG RDS

python /home/ubuntu/ranjan/scripts/file-diff/sqlschema.py >Eng.sql

#Logging to PROD RDS
ssh -TAtt ubuntu@18.221.144.194 "python /home/scripts/schema.py" > Prod.sql

#Sorting of RDS SCHEMA DETAILS

sort Eng.sql >>  Eng-Rds.sql
sort Prod.sql >> Prod-Rds.sql

#COMPARISON OF CASSANDRA

if [[ $(diff Prod-Cassandra.cql Eng-Cassandra.cql) ]];then

        vimdiff Prod-Cassandra.cql Eng-Cassandra.cql -c TOhtml -c 'w! >> diff1.html' -c 'qa!'
    else
        echo -e "CASSANDRA NO_CHANGE" >>sch.txt
                awk 'BEGIN { print "<table border=2>" }; { printf( "<tr><td>%s</td><td>%s</td></tr>\n", $1 ,$2) } END { print "</table>" }' sch.txt >>diff.html
fi

#COMPARIOSN OF RDS

if [[ $(diff Prod-Rds.sql Eng-Rds.sql) ]];then

        vimdiff Prod-Rds.sql Eng-Rds.sql -c TOhtml -c 'w! >> diff1.html' -c 'qa!'

        else
                echo -e "RDS-SQL-SERVER NO_CHANGE" >>sch.txt
                awk 'BEGIN { print "<table border=2>" }; { printf( "<tr><td>%s</td><td>%s</td></tr>\n", $1 ,$2) } END { print "</table>" }' sch.txt >>diff.html
fi

#GIVE FILE PERMISSION TO EDIT

chmod +x diff1.html
    sleep 1
    cat diff1.html |grep -v 'lines' >>diff.html

rm -rf  Eng-Cassandra.cql Eng-Rds.sql Prod0003.cql  Eng.sql Prod-Cassandra.cql Prod-PublicApi02 Eng0002.cql  Prod-DataApi01 Prod-Rds.sql Eng0003.cql Eng-PublicApi02 Prod0002.cql Prod-DataDaemon03 Prod.sql Eng-AssetTracking01 Eng-AssetTracking02 Eng-DataApi02 Eng-PublicApi01 Eng-PublicApi01. Eng-PublicApi02. Prod-PublicApi01

cp /home/ubuntu/ranjan/scripts/FINAL/report.html /home/ubuntu/ranjan/scripts/file-diff/
#SEND THE MAIL
python mailsend_html.py
