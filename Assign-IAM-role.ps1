$data = Import-Csv ./servers.csv

foreach ($object in $data) {

    $serverName = $object.server
    $instance = aws ec2 describe-instances --filters "Name=tag:Name,Values=$serverName" | ConvertFrom-json
    $instanceId = $instance.Reservations.Instances.InstanceId

    Write-Output "Associating role on $serverName..."
    aws ec2 associate-iam-instance-profile --instance-id $instanceId --iam-instance-profile Name=CR-EC2-SSM

}


  