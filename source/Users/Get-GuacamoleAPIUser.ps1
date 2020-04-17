function Get-GuacamoleAPIUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$authObject,
        [Parameter(Mandatory=$false)]
        [String]$Username
    )

    $endPoint = "{0}api/session/data/{1}/users" -f $authObject.BaseURI, $authObject.DataSource

    if ($PSBoundParameters.ContainsKey("Username")) {
        $endPoint += "/{0}" -f $Username
    }

    Write-Debug $endPoint

    $r = Invoke-GuacamoleAPIRequest -AuthObject $authObject -Method "Get" -Endpoint $endPoint 

    switch ($r.StatusCode) {
        200 {
            if ($PSBoundParameters.ContainsKey("Username")) {
                $r | Add-Member -MemberType NoteProperty -Name User -Value $r.Content -PassThru
            } else {
                $r | Add-Member -MemberType NoteProperty -Name Users -Value $r.Content -PassThru
            }
        }

        default {
            $r
        }
    }
}