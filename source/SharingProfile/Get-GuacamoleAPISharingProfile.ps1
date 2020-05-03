function Get-GuacamoleAPISharingProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject,
        [Parameter(Mandatory=$false)]
        [string]$Identifier
    )

    $uri = "{0}/api/session/data/{1}/sharingProfiles" -f $AuthObject.BaseURI, $AuthObject.DataSource

    if ($PSBoundParameters.ContainsKey("Identifier")) {
        $uri = $uri + "/" + $Identifier
    }

    $r = Invoke-GuacamoleAPIRequest -AuthObject $AuthObject -method get -Endpoint $uri

    switch ($r.StatusCode.value__) {
        200 {
            if ($PSBoundParameters.ContainsKey("Identifier")) {
                $r | Add-Member -MemberType NoteProperty -Name SharingProfile -Value $r.Content
            } else {
                $sharingProfiles = @{}

                $r.Content | Get-Member -MemberType NoteProperty | % {
                    $n = $_.name
                    $sharingProfiles[$n] = $r.Content.$n
                }

                $r | Add-Member -MemberType NoteProperty -Name SharingProfiles -Value $sharingProfiles
            }

            $r
        }

        default {
            $r
        }
    }

}