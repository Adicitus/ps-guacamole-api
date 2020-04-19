function Invoke-GuacamoleAPIRequest {
    [CmdletBinding()]
    param(
        [ValidateSet("get","post","delete","patch","put")]
        [Parameter(Mandatory=$true)]
        [string]$Method,
        [Parameter(Mandatory=$true)]
        [string]$Endpoint,
        [parameter(Mandatory=$false)]
        [hashtable]$Parameters,
        [Parameter(Mandatory=$false)]
        [string]$Body,
        [Parameter(Mandatory=$false)]
        [hashtable]$Headers,
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$AuthObject
    )

    $reqArgs = @{
        Method = $Method
        Uri = $Endpoint
    }

    if ($PSBoundParameters.ContainsKey("Body")) {
        Write-Debug $Body
        $reqArgs.Body = $Body
    }
    
    if ($PSBoundParameters.ContainsKey("Headers")) {
        $reqArgs.Headers = $Headers.clone()
    }

    $params = if ($PSBoundParameters.ContainsKey("Parameters")) {
        $Parameters.Clone()
    } else {
        @{}
    }

    if ($PSBoundParameters.ContainsKey("AuthObject")) {
        $params.token = Unlock-SecureString $AuthObject.token
    }

    if ($params) {
        $queryString = ($params.GetEnumerator() | % { "{0}={1}" -f $_.key, $_.value }) -join "&"
        $reqArgs.Uri = "{0}?{1}" -f $Endpoint, $queryString
    } 

    Write-Debug $reqArgs.Uri

    $r = try {
        Invoke-WebRequest @reqArgs -UseBasicParsing
    } catch {
        $_
    }

    switch ($r.GetType().Name) {
        ErrorRecord {
            if ($r.Exception -is [System.Net.WebException]) {
                [PSCustomObject]@{
                    StatusCode = $r.Exception.Response.StatusCode
                    Exception = $r.Exception
                    Response  = $r.Exception.Response
                }
            } else {
                throw $r
            }
        }
        default {
            $t = @{
                Statuscode  = $r.statuscode
                Raw = $r
            }

            if ($r.Content) {
                $t.Content = ConvertFrom-UnicodeEscapedString $r.Content | ConvertFrom-Json
            }

            [PSCustomObject]$t
        }
    }


}