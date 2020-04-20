function Save-GuacamoleAPIAuth {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$path,
        [parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject,
        [parameter(Mandatory=$false)]
        [switch]$UseKey,
        [parameter(Mandatory=$false)]
        [string]$Key
    )

    $encryptArgs = @{}

    if ($UseKey) {
        $encryptArgs.Key = if ($PSBoundParameters.ContainsKey("Key")) {
            $Key
        } else {
            $r = [System.Random]::new()
            [byte[]]( 0..31 | % { $r.next(0, 255) } )
        }
    }

    $p = @{
        Username    = $AuthObject.Credential.Username
        Password    = $AuthObject.Credential.Password | ConvertFrom-SecureString @encryptArgs
        Token       = $AuthObject.Token | ConvertFrom-SecureString  @encryptArgs
        DataSource  = $AuthObject.DataSource
        Hostname    = $AuthObject.Hostname
        Path        = $AuthObject.Path
        Protocol    = $AuthObject.Protocol
        BaseURI     = $AuthObject.BaseURI
        Expires     = $AuthObject.Expires
    }

    $p | ConvertTo-Json | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString  @encryptArgs > $path

    if ($UseKey) {
        return [System.Convert]::ToBase64String($encryptArgs.Key)
    }

}