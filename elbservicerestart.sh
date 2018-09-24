arn=$(aws elbv2 describe-target-groups --names "internal-data-api" --query TargetGroups[].TargetGroupArn --output text)
instances=($(aws elbv2 describe-target-health  --target-group-arn "${arn}" --query TargetHealthDescriptions[].Target.Id --output text))

instanceid=${instances[0]}
for instanceid in "${instances[@]}"; do
    instanceip=$(aws ec2 describe-instances --instance-ids ${instanceid} --query Reservations[].Instances[].PrivateIpAddress --output text)
    instancename=$(aws ec2 describe-tags --filters Name=resource-id,Values=${instanceid} Name=key,Values=Name --query Tags[].Value --output text)

    echo "Removing ${instancename} from Target Group"
    aws elbv2 deregister-targets --target-group-arn "${arn}" --targets Id=${instanceid}

    echo "Waiting for traffic to drain"
    sleep 30

	# ssh command is written for running within the VPC (from ssh jump host)
	# if running from local machine, need ssh through ssh jump host
    echo "Restarting data-api-server on ${instancename}"
    ssh -A ubuntu@${instanceip} sudo systemctl restart data-api-server

    echo "Adding ${instancename} back to Target Group"
    aws elbv2 register-targets --target-group-arn "${arn}" --targets Id=${instanceid}

    echo "Waiting for ${instancename} healthy status"
    aws elbv2 wait target-in-service --target-group-arn "${arn}" --targets Id=${instanceid}

    echo "Done with ${instancename}"
done

echo "All done"
