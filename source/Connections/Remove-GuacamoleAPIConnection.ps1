function Remove-GuacamoleAPIConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject,
        [Parameter(Mandatory=$true)]
        [String]$Identifier
    )

    $endpoint = "{0}/api/session/data/{1}/connections/{2}" -f $AuthObject.BaseURI, $AuthObject.DataSource, $Identifier

    $r = Invoke-GuacamoleAPIRequest -AuthObject $AuthObject -Method delete -Endpoint $endpoint

    $r

}