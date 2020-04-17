function Save-GuacamoleAPIAuth {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]$path,
        [parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject
    )

    $p = @{
        Username    = $AuthObject.Credential.Username
        Password    = $AuthObject.Credential.Password | ConvertFrom-SecureString
        Token       = $AuthObject.Token | ConvertFrom-SecureString
        DataSource  = $AuthObject.DataSource
        Hostname    = $AuthObject.Hostname
        Path        = $AuthObject.Path
        Protocol    = $AuthObject.Protocol
        BaseURI     = $AuthObject.BaseURI
    }

    $p | ConvertTo-Json | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString > $path

}