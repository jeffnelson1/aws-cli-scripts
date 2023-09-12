$data = Get-Content -path "./serverNames.txt"

foreach ($object in $data) {

    ## Define variables
    $serverName = $object
    $securityGroupId = "sg-11111111"

    $instances = (aws ec2 describe-instances | ConvertFrom-Json).Reservations.Instances    
    $instance = $instances | Where-Object { $_.Tags -like "*$serverName*" -and $_.State.Name -eq "running"}
    $instanceId = $instance.InstanceId
    
    $sgs = aws ec2 describe-instances --instance-id $instanceId --query 'Reservations[*].Instances[*]' | ConvertFrom-Json
    [array]$allSGs = $sgs.SecurityGroups.GroupId

    Write-Output "`r`nCurrent SGs attached to $serverName are `r`n $allSGs"
    $allSGs += $securityGroupId
 
    aws ec2 modify-instance-attribute --instance-id $instanceId --groups $allSGs
    $newSgs = aws ec2 describe-instances --instance-id $instanceId --query 'Reservations[*].Instances[*]' | ConvertFrom-Json
    $allNewSGs = $newSgs.SecurityGroups.GroupId

    Write-Output "`r`nNew SGs attached to $instance are `r`n $allNewSGs"
    
}

