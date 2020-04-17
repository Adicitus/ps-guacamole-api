function Remove-GuacamoleAPIUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$authObject,
        [Parameter(Mandatory=$true)]
        [String]$Username
    )

    $endPoint = "{0}api/session/data/{1}/users/{2}" -f $authObject.BaseURI, $authObject.DataSource, $Username

    Invoke-GuacamoleAPIRequest -AuthObject $AuthObject -Method delete -EndPoint $endPoint
}