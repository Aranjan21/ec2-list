version=$1
names=$2

if [ $# != 2 ];  then
    echo "Usage in gitbash on windows : sh deploy-safe-dashboard.sh <version> <elb-target-group-name>"
    exit 0
fi

arn=$(aws elbv2 describe-target-groups --names "${names}" --query TargetGroups[].TargetGroupArn --output text)
instances=($(aws elbv2 describe-target-health  --target-group-arn "${arn}" --query TargetHealthDescriptions[].Target.Id --output text))

echo "Deploying for version ${version}"

instanceid=${instances[0]}

ip=$(ipconfig | grep -A 1 'IPv4 Address' -m1 | grep -E '172.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d ':' -f 2)

echo Instance Private IP Address is: ${ip}

for instanceid in "${instances[@]}"; do

    instanceip=$(aws ec2 describe-instances --instance-ids ${instanceid} --query Reservations[].Instances[].PrivateIpAddress --output text)
    instancename=$(aws ec2 describe-tags --filters Name=resource-id,Values=${instanceid} Name=key,Values=Name --query Tags[].Value --output text)

    if [ $instanceip == $ip ]
    then
        echo "Found ${instancename} with IP ${ip}"
        echo "Removing ${instancename} from Target Group"

        aws elbv2 deregister-targets --target-group-arn "${arn}" --targets Id=${instanceid}
        echo "Waiting for traffic to drain. wait 60 seconds"
        sleep 60

        ./deploy_dashboard.bat ${version}

        echo "Adding ${instancename} back to Target Group"
        aws elbv2 register-targets --target-group-arn "${arn}" --targets Id=${instanceid}

    fi
done

echo "All done"
