$data = Get-Content -path "./serverNames.txt"

foreach ($object in $data) {

    ## Define variables
    $serverName = $object

    $instances = (aws ec2 describe-instances | ConvertFrom-Json).Reservations.Instances    
    $instance = $instances | Where-Object { $_.Tags -like "*$serverName*" -and $_.State.Name -eq "running"}
    $instanceId = $instance.InstanceId

    Write-Output "Enabling terminiation protection on $serverName..."
    aws ec2 modify-instance-attribute --disable-api-termination --instance-id $instanceId

}