$ec2instances = aws ec2 describe-instances --region us-west-1 | ConvertFrom-Json
$instances = $ec2instances.Reservations.Instances

foreach ($instance in $instances) {

    Write-output("Creating alarm for $($instance.InstanceId)")
    aws cloudwatch put-metric-alarm --alarm-name cpu-mon-$($instance.InstanceId) --alarm-description "Alarm when CPU is greater than or equal to 80%" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 80 --comparison-operator GreaterThanOrEqualToThreshold --dimensions  Name=InstanceId,Value=$($instance.InstanceId) --evaluation-periods 2 --alarm-actions arn:aws:sns:us-west-2:11111111:CPUutilizationTopic --unit Percent --region us-west-1
    
}
