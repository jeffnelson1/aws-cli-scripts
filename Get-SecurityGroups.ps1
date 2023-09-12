$data = Import-Csv ./servers.csv

$obj = New-Object -TypeName psobject

foreach ($object in $data) {

$serverName = $object.server
$sgName = $serverName + "-" + "sg"
$group = aws ec2 describe-security-groups --filters Name=group-name,Values=$sgName | ConvertFrom-Json
$groupName = $group.SecurityGroups.GroupName
$groupId = $group.SecurityGroups.GroupId

$obj = New-Object PSObject -Property @{
    Server = $serverName
    SG_Name = $groupName
    SG_ID = $groupId
}
   
$obj | Select-Object Server, SG_Name, SG_ID
$obj | Select-Object Server, SG_Name, SG_ID | export-CSV '.\SGs.csv' -Append

}