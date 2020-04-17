function New-GuacamoleAPIUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]    
        [PSCustomObject]$authObject,
        [Parameter(Mandatory=$true)]
        [String]$Username,
        [Parameter(Mandatory=$true)]
        [SecureString]$Password,
        [Parameter(Mandatory=$false)]
        [bool]$Disabled=$false,
        [Parameter(Mandatory=$false, HelpMessage="Date from which this account is active. The time part of the datetime is ignored.")]
        [datetime]$ValidFrom,
        [Parameter(Mandatory=$false, HelpMessage="Date when this account is deactive. The time part of the datetime is ignored.")]
        [datetime]$ValidUntil,
        [Parameter(Mandatory=$false, HelpMessage="Time zone name as specified at 'https://en.wikipedia.org/wiki/List_of_tz_database_time_zones'. Default: 'Europe/Stockholm'")]
        [String]$TimeZone='Europe/Stockholm'
    )

    $endpoint = "{0}api/session/data/{1}/users" -f $authObject.BaseURI, $authObject.DataSource

    $headers = @{
        "Content-Type"="application/json"
    }

    $body = @{
        username = $Username
        password = Unlock-SecureString $Password
        attributes = @{
            timezone = $TimeZone
        }
    }

    if ($PSBoundParameters.ContainsKey("Disabled")) {
        $attributes.disabled = $Disabled
    }

    if ($PSBoundParameters.ContainsKey("ValidFrom")) {
        $attributes."valid-from" = "{0:yyyy-MM-dd}" -f $ValidFrom
    }

    if ($PSBoundParameters.ContainsKey("ValidUntil")) {
        $attributes."valid-until" = "{0:yyyy-MM-dd}" -f $ValidUntil
    }

    $jsonBody = $body | ConvertTo-Json | ConvertTo-UnicodeEscapedString

    write-Debug $jsonBody

    $r = Invoke-GuacamoleAPIRequest -AuthObject $authObject -Method post -Endpoint $endpoint -Body $jsonBody -Headers $headers

    switch ($r.StatusCode) {
        200 {
            $r | Add-Member -MemberType NoteProperty -Name User -Value $r.Content -PassThru
        }

        default {
            $r
        }
    }


}