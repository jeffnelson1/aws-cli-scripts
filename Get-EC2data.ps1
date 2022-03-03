$ec2Names = Import-Csv -Path "C:\Temp\instances.csv"
$envs = @("production","dev","staging","test")
$obj = New-Object -TypeName psobject

foreach ($_ in $ec2Names) {

    foreach ($env in $envs) {
        
        $ec2Name = $_.instance
        $ec2Object = (aws ec2 describe-instances --filters Name=tag-value,Values=$ec2Name Name=tag-key,Values=Name Name=tag-value,Values=$env Name=tag-key,Values=Env | ConvertFrom-Json).Reservations.Instances

        if ($null -ne $ec2Object) {
        
        $instanceId = $ec2Object.InstanceId
        $ipAddress = $ec2Object.PrivateIpAddress 
        $availabilityZone = $ec2Object.Placement.AvailabilityZone

        $obj = New-Object PSObject -Property @{
            Name              = $ec2Name
            Instance_ID       = $instanceId
            IP_Address        = $ipAddress
            Environment       = $env
            Availability_Zone = $availabilityZone
        }

        $obj | Select-Object Name, Instance_ID, IP_Address, Environment, Availability_Zone
        $obj | Select-Object Name, Instance_ID, IP_Address, Environment, Availability_Zone | export-CSV 'C:\Temp\Output.csv' -Append
    }
    else {
        Write-Output "$ec2Name not found in $env..."
    }
    }

}

