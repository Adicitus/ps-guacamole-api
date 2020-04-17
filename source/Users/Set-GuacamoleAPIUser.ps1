function Set-GuacamoleAPIUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]    
        [PSCustomObject]$authObject,
        [Parameter(Mandatory=$true)]
        [String]$Username,
        [Parameter(Mandatory=$false)]
        [SecureString]$Password,
        [Parameter(Mandatory=$false)]
        [bool]$Disabled=$false,
        [Parameter(Mandatory=$false, HelpMessage="Date from which this account is active. The time part of the datetime is ignored.")]
        [datetime]$ValidFrom,
        [Parameter(Mandatory=$false, HelpMessage="Date when this account is deactive. The time part of the datetime is ignored.")]
        [datetime]$ValidUntil,
        [Parameter(Mandatory=$false, HelpMessage="Time zone name as specified at 'https://en.wikipedia.org/wiki/List_of_tz_database_time_zones'. Default: 'Europe/Stockholm'")]
        [String]$TimeZone
    )

    $endpoint = "{0}api/session/data/{1}/users" -f $authObject.BaseURI, $authObject.DataSource, $Username

    $headers = @{
        "Content-Type"="application/json"
    }

    $body = @{
        username = $Username
    }

    if ($PSBoundParameters.ContainsKey("Password")) {
        $body.password = Unlock-SecureString $Password
    }

    if ($PSBoundParameters.ContainsKey("Disabled")) {
        if (!$body.attributes) { $body.attributes = @{} }
        $body.attributes.disabled = $Disabled
    }

    if ($PSBoundParameters.ContainsKey("ValidFrom")) {
        if (!$body.attributes) { $body.attributes = @{} }
        $body.attributes."valid-from" = "{0:yyyy-MM-dd}" -f $ValidFrom
    }

    if ($PSBoundParameters.ContainsKey("ValidUntil")) {
        if (!$body.attributes) { $body.attributes = @{} }
        $body.attributes."valid-until" = "{0:yyyy-MM-dd}" -f $ValidUntil
    }

    if ($PSBoundParameters.ContainsKey("TimeZone")) {
        if (!$body.attributes) { $body.attributes = @{} }
        $body.attributes.timezone = $TimeZone
    }

    $jsonBody = $body | ConvertTo-Json | ConvertTo-UnicodeEscapedString

    write-Debug $jsonBody

    $r = Invoke-GuacamoleAPIRequest -AuthObject $authObject -Method patch -Endpoint $endpoint -Body $jsonBody -Headers $headers

    switch ($r.StatusCode) {
        200 {
            $r | Add-Member -MemberType NoteProperty -Name User -Value $r.Content -PassThru
        }

        default {
            $r
        }
    }


}