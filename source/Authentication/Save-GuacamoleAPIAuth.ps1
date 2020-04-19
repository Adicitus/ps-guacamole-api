function Save-GuacamoleAPIAuth {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$path,
        [parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject,
        [parameter(Mandatory=$false)]
        [switch]$UseKey
    )

    $encryptArgs = @{}

    if ($UseKey) {
        $r = [System.Random]::new()
        $encryptArgs.Key = [byte[]]( 0..31 | % { $r.next(0, 255) } )
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
    }

    $p | ConvertTo-Json | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString  @encryptArgs > $path

    if ($UseKey) {
        return [System.Convert]::ToBase64String($encryptArgs.Key)
    }

}