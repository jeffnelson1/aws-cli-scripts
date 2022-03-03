$parameters = Import-Csv -Path "C:\Temp\params.csv"
$prefix = "/config_service/TEST/application01"

foreach ($param in $parameters) {
    
    $name = $param.name
    $secret = $param.secret

    Write-Output "Adding parameter $prefix/$name"
    aws ssm put-parameter --name "$prefix/$name" --type "SecureString" --value $secret

}