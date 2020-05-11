function Request-GuacamoleAPIAuth {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="AuthObject", Position=1)]
        [PSCustomObject]$AuthObject,
        [Parameter(Mandatory=$true, ParameterSetName="Params", Position=1)]
        [string]$Hostname,
        [Parameter(Mandatory=$true, ParameterSetName="Params", Position=2)]
        [pscredential]$Credential,
        [Parameter(Mandatory=$false, ParameterSetName="Params", Position=3)]
        [String]$GuacamolePath="/",
        [Parameter(Mandatory=$false, ParameterSetName="Params", Position=4)]
        [ValidateSet("https", "http")]
        [string]$Protocol="https"
    )

    if ($PSCmdlet.ParameterSetName -eq "AuthObject") {
        $Hostname       = $AuthObject.Hostname
        $Credential     = $AuthObject.Credential
        $GuacamolePath  = $AuthObject.Path
        $Protocol       = $AuthObject.Protocol
    }

    $baseUri = if ($GuacamolePath -ne "/") {
        "{0}://{1}/{2}/" -f $Protocol, $Hostname, $GuacamolePath
    } else {
        "{0}://{1}/" -f $Protocol, $Hostname
    }

    $endPoint = "{0}api/tokens" -f $baseUri

    Write-Debug $endpoint

    $headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
    }

    # Encoding credentials as x-www-form-urlencoded.
    # See:
    # - https://stackoverflow.com/questions/60651115/how-can-i-connect-user-with-a-connection-by-using-guacamole-rest-api
    # - https://dev.to/sidthesloth92/understanding-html-form-encoding-url-encoded-and-multipart-forms-3lpa
    # - https://stackoverflow.com/questions/2678551/when-to-encode-space-to-plus-or-20
    $body = @{
        username = $Credential.UserName
        password = Unlock-SecureString $Credential.Password
    }.GetEnumerator() | % { "{0}={1}" -f $_.Key, [System.net.webUtility]::HtmlEncode($_.value) }
    $body = $body -join "&"

    $calltime = [datetime]::Now
    $r = Invoke-GuacamoleAPIRequest -Method Post -EndPoint $endpoint -Headers $headers -Body $body

    $r.Raw.Content | Write-Debug

    switch ($r.statusCode.value__) {
        200 {
            [PSCustomObject]@{
                Token       = ConvertTo-SecureString -String $r.Content.authToken -AsPlainText -Force
                DataSource  = $r.Content.DataSource
                Credential  = $Credential
                Hostname    = $Hostname
                Path        = $GuacamolePath
                Protocol    = $Protocol
                BaseURI     = $baseUri
                Expires     = $calltime.AddMinutes(60) # Default api session timeout: https://guacamole.apache.org/doc/gug/configuring-guacamole.html#initial-setup
            }
        }

        default {
            $r
        }
    }

}