#!/bin/bash
version=$1
names=$2

if [ $# != 2 ];  then
    echo "Usage : sh deploy-service-ops.sh <version> <elb-target-group-name>"
    exit 0
fi


arn=$(aws elbv2 describe-target-groups --names "${names}" --query TargetGroups[].TargetGroupArn --profile elb --region us-east-2 --output text)
instances=$(aws elbv2 describe-target-health  --target-group-arn "${arn}" --query TargetHealthDescriptions[].Target.Id --profile elb --region us-east-2 --output text)


ip=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep -E '172.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

echo Instance Private IP Address is: ${ip}


for instanceid in $instances; do

    instanceip=$(aws ec2 describe-instances --instance-ids ${instanceid} --query Reservations[].Instances[].PrivateIpAddress --profile elb --region us-east-2 --output text)
    instancename=$(aws ec2 describe-tags --filters Name=resource-id,Values="${instanceid}" Name=key,Values=Name --query Tags[].Value --profile elb --region us-east-2 --output text)

    if [ $instanceip = $ip ]
    then
        echo "Found ${instancename} with IP ${ip}"
        echo "Removing ${instancename} from Target Group"

        aws elbv2 deregister-targets --target-group-arn "${arn}" --targets Id=${instanceid} --profile elb --region us-east-2
        echo "Waiting for traffic to drain. wait 60 seconds"
        sleep 60

        echo "Deploy Started"
        sudo su lundaemons -c "mkdir -p /lunera/data/opsgenie"
        sudo su lundaemons -c "mkdir -p /lunera/code/opsgenie"

        cd /lunera/code/opsgenie
        sudo su lundaemons -c "rm -rf opsgenie-${version}.tgz"
        sudo su lundaemons -c "wget https://s3.us-east-2.amazonaws.com/lunera-images/opsgenie-${version}.tgz"
        sudo su lundaemons -c "pm2 stop current/opsgenie-service.json"
        sudo su lundaemons -c "pm2 delete server"
        sudo su lundaemons -c "rm -rf ${version}"
        sudo su lundaemons -c "tar xf opsgenie-${version}.tgz"
        sudo su lundaemons -c "rm -f current"
        sudo su lundaemons -c "ln -s ${version} current"

        cd current
        sudo su lundaemons -c "echo $version > version.txt"
        echo "starting opsgenie service"
        sudo su lundaemons -c "pm2 start opsgenie-service.json"
        sudo su lundaemons -c "pm2 stop server"
        sudo su lundaemons -c "pm2 start server"

        echo "Deploy Ended"
        echo "Adding ${instancename} back to Target Group"
        aws elbv2 register-targets --target-group-arn "${arn}" --targets Id=${instanceid} --profile elb --region us-east-2

    fi
done

echo "All done"
