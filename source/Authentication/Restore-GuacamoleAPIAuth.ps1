function Restore-GuacamoleAPIAuth {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$path,
        [parameter(Mandatory=$false)]
        [string]$Key
    )

    $decryptArgs = @{}

    if ($key) {
        $keyBytes = [System.Convert]::FromBase64String($key)
        $decryptArgs.Key = $keyBytes
    }

    $c = Get-Content $path
    $p = $c | ConvertTo-SecureString @decryptArgs | Unlock-SecureString | ConvertFrom-Json

    [PSCustomObject]@{
        Credential  = New-PSCredential -Username $p.Username -SecurePassword ($p.Password | ConvertTo-SecureString @decryptArgs)
        DataSource  = $p.DataSource
        Token       = $p.Token | ConvertTo-SecureString @decryptArgs
        Hostname    = $p.Hostname
        Path        = $p.Path
        Protocol    = $p.Protocol
        BaseURI     = $p.BaseURI
    }

}