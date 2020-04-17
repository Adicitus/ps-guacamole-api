function Restore-GuacamoleAPIAuth {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$path
    )

    $c = Get-Content $path
    $p = $c | ConvertTo-SecureString | Unlock-SecureString | ConvertFrom-Json

    [PSCustomObject]@{
        Credential  = New-PSCredential -Username $p.Username -SecurePassword ($p.Password | ConvertTo-SecureString)
        DataSource  = $p.DataSource
        Token       = $p.Token | ConvertTo-SecureString
        Hostname    = $p.Hostname
        Path        = $p.Path
        Protocol    = $p.Protocol
        BaseURI     = $p.BaseURI
    }

}