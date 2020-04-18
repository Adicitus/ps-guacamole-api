function Get-GuacamoleAPIConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject,
        [Parameter(Mandatory=$false)]
        [String]$Identifier
    )

    $endpoint = "{0}/api/session/data/{1}/connections" -f $AuthObject.BaseURI, $AuthObject.DataSource

    if ($PSBoundParameters.ContainsKey("Identifier")) {
        $endpoint += "/{0}" -f $Identifier
    }

    $r = Invoke-GuacamoleAPIRequest -AuthObject $AuthObject -Method get -Endpoint $endpoint

    switch ($r.StatusCode) {
        200 {
            if ($PSBoundParameters.ContainsKey("Identifier")) {
                $r | Add-Member -MemberType NoteProperty -Name Connection -Value $r.Content
            } else {
                $connections = @{}

                $r.Content | Get-Member -MemberType NoteProperty | % {
                    $n = $_.name
                    $connections[$n] = $r.Content.$n
                }

                $r | Add-Member -MemberType NoteProperty -Name Connections -Value $connections
            }

            $r
        }

        default {
            $r
        }
    }

}