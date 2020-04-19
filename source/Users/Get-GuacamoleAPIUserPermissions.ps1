function Get-GuacamoleAPIUserPermissions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject,
        [Parameter(Mandatory=$true)]
        [String]$Username
    )

    $endPoint = "{0}api/session/data/{1}/users/{2}/permissions" -f $authObject.BaseURI, $authObject.DataSource, $Username

    $r = Invoke-GuacamoleAPIRequest -AuthObject $AuthObject -Method Get -EndPoint $endpoint

    switch ($r.StatusCode.value__) {
        200 {
            $r | Add-Member -MemberType noteproperty -Name Permissions -Value $r.Content -PassThru
        }

        default {
            $r
        }
    }
}