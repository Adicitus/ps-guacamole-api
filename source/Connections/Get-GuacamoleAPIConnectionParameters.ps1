function Get-GuacamoleAPIConnectionParameters {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject,
        [Parameter(Mandatory=$true)]
        [String]$Identifier
    )

    $endpoint = "{0}/api/session/data/{1}/connections/{2}/parameters" -f $AuthObject.BaseURI, $AuthObject.DataSource, $Identifier


    $r = Invoke-GuacamoleAPIRequest -AuthObject $AuthObject -Method get -Endpoint $endpoint

    switch ($r.StatusCode.value__) {
        200 {
            $r | Add-Member -MemberType NoteProperty -Name Parameters -Value $r.Content -PassThru
        }

        default {
            $r
        }
    }

}