function New-GuacamoleAPISharingProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject,
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$ConnectionIdentifier
    )

    $uri = "{0}/api/session/data/{1}/sharingProfiles/" -f $AuthObject.BaseURI, $AuthObject.DataSource

    $headers = @{
        "Content-Type" = "application/json"
    }

    $body = @{
        name = $Name
        primaryConnectionIdentifier = $ConnectionIdentifier
    } | ConvertTo-Json | ConvertTo-UnicodeEscapedString


    $r = Invoke-GuacamoleAPIRequest -Method post -Endpoint $uri -Body $body -Headers $headers -AuthObject $AuthObject

    switch ($r.StatusCode.value__) {
        200 {
            $r | Add-Member -MemberType NoteProperty -Name SharingProfile -Value $r.Content -PassThru
        }

        default {
            $r
        }
    }
}