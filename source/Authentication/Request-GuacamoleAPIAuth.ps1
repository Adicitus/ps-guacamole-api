function Request-GuacamoleAPIAuth {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="AuthObject")]
        [PSCustomObject]$AuthObject,
        [Parameter(Mandatory=$true, ParameterSetName="Params")]
        [string]$Hostname,
        [Parameter(Mandatory=$true, ParameterSetName="Params")]
        [pscredential]$Credential,
        [Parameter(Mandatory=$false, ParameterSetName="Params")]
        [String]$GuacamolePath="/",
        [Parameter(Mandatory=$false, ParameterSetName="Params")]
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

    Write-host $endpoint

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
    }.GetEnumerator() | % { "{0}={1}" -f $_.Key, [System.web.httpUtility]::UrlEncode($_.value) }
    $body = $body -join "&"

    $r = Invoke-GuacamoleAPIRequest -Method Post -EndPoint $endpoint -Headers $headers -Body $body

    switch ($r.statusCode) {
        200 {
            [PSCustomObject]@{
                Token       = ConvertTo-SecureString -String $r.Content.authToken -AsPlainText -Force
                DataSource  = $r.Content.DataSource
                Credential  = $Credential
                Hostname    = $Hostname
                Path        = $GuacamolePath
                Protocol    = $Protocol
                BaseURI     = $baseUri
            }
        }

        default {
            $r
        }
    }

}