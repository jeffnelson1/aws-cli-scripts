$data = Import-Csv ./servers.csv

$obj = New-Object -TypeName psobject

foreach ($object in $data) {

    $serverName = $object.server
    $instance = aws ec2 describe-instances --filters "Name=tag:Name,Values=$serverName" | ConvertFrom-json
    $ip = $instance.Reservations.Instances.NetworkInterfaces.PrivateIpAddress

$obj = New-Object PSObject -Property @{
    Server = $serverName
    Private_IP = $ip
}
   
$obj | Select-Object Server, Private_IP
$obj | Select-Object Server, Private_IP | export-CSV '.\IPs.csv' -Append

}