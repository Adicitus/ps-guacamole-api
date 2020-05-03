function Remove-GuacamoleAPISharingProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject,
        [Parameter(Mandatory=$true)]
        [string]$Identifier
    )

    $uri = "{0}/api/session/data/{1}/sharingProfiles/{2}" -f $AuthObject.BaseURI, $AuthObject.DataSource, $Identifier

    Invoke-GuacamoleAPIRequest -AuthObject $AuthObject -method delete -Endpoint $uri

}