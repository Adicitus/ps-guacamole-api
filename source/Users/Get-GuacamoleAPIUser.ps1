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

    switch ($r.StatusCode.value__) {
        200 {

            if ($PSBoundParameters.ContainsKey("Identifier")) {
                $r | Add-Member -MemberType NoteProperty -Name User -Value $r.Content
            } else {
                $users = @{}

                $r.Content | Get-Member -MemberType NoteProperty | % {
                    $n = $_.name
                    $users[$n] = $r.Content.$n
                }

                $r | Add-Member -MemberType NoteProperty -Name Users -Value $users
            }

            $r

        }

        default {
            $r
        }
    }
}