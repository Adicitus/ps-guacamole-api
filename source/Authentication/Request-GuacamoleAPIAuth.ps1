function Request-GuacamoleAPIAuth {
    [CmdletBinding()]
    param(
        [string]$Hostname,
        [String]$GuacamolePath="/",
        [pscredential]$Credential,
        [ValidateSet("https", "http")]
        [string]$Protocol="https"
    )

    $endpoint = if ($GuacamolePath -ne "/") {
        "{0}://{1}/{2}/api/tokens" -f $Protocol, $Hostname, $GuacamolePath
    } else {
        "{0}://{1}/api/tokens" -f $Protocol, $Hostname
    }
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
                Token = ConvertTo-SecureString -String $r.Content.authToken -AsPlainText -Force
                DataSource = $r.Content.DataSource
                Credential = $Credential
            }
        }

        default {
            $r
        }
    }

}