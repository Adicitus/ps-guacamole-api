function New-GuacamoleAPIRDPConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject,
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$Username,
        [Parameter(Mandatory=$true)]
        [SecureString]$Password,
        [Parameter(Mandatory=$true)]
        [string]$Hostname,
        [Parameter(Mandatory=$false)]
        [string]$Domain,
        [ValidateRange(1, 65535)]
        [Parameter(Mandatory=$false)]
        [int]$Port,
        [ValidateSet("nla", "rdp", "tls")]
        [Parameter(Mandatory=$false)]
        [string]$Security="nla",
        [Parameter(Mandatory=$false)]
        [String]$GatewayHostname,
        [Parameter(Mandatory=$false)]
        [String]$GatewayUsername,
        [Parameter(Mandatory=$false)]
        [SecureString]$GatewayPassword,
        [Parameter(Mandatory=$false)]
        [String]$GatewayDomain,
        [ValidateRange(1, 65535)]
        [Parameter(Mandatory=$false)]
        [int]$GatewayPort,
        [ValidateSet("display-update", "reconnect")]
        [Parameter(Mandatory=$false)]
        [string]$ResizeMethod="display-update",
        [Parameter(Mandatory=$false)]
        [bool]$IgnoreCertificate=$false,
        [Parameter(Mandatory=$false)]
        [bool]$EnableWallpaper,
        [Parameter(Mandatory=$false)]
        [bool]$DisableAudio,
        [Parameter(Mandatory=$false)]
        [bool]$EnableFontSmoothing,
        [Parameter(Mandatory=$false)]
        [bool]$EnablePrinting,
        [Parameter(Mandatory=$false)]
        [bool]$EnableTheming,
        [Parameter(Mandatory=$false)]
        [bool]$EnableFullWindowDrag,
        [Parameter(Mandatory=$false)]
        [bool]$EnableDesktopComposition,
        [Parameter(Mandatory=$false)]
        [bool]$EnableMenuAnimations,
        [Parameter(Mandatory=$false)]
        [int]$MaxConnections=1,
        [Parameter(Mandatory=$false)]
        [int]$MaxConnectionsPerUser=1,
        [Parameter(Mandatory=$false)]
        [string]$ParentIdentifier = "ROOT"
    )

    $endpoint = "{0}/api/session/data/{1}/connections" -f $AuthObject.BaseURI, $AuthObject.DataSource

    $headers = @{
        "Content-Type" = "application/json"
    }

    $body = @{
        name = $Name
        protocol = "rdp"
        parentIdentifier = $ParentIdentifier
        parameters = @{
            username = $Username
            password = Unlock-SecureString $Password
            hostname = $Hostname
            security = $Security
        }
        attributes = @{
            "max-connections" = $MaxConnections
            "max-connections-per-user" = $MaxConnectionsPerUser
        }
    }

    $mapping = @{
        Domain          = { param($v) $body.parameters.domain = $Domain }
        Port            = { param($v) $body.parameters.port = $v }
        GatewayHostname = { param($v) $body.parameters."gateway-hostname" = $v }
        GatewayUsername = { param($v) $body.parameters."gateway-username" = $v }
        GatewayPassword = { param($v) $body.parameters."gateway-password" = Unlock-SecureString $v }
        GatewayDomain   = { param($v) $body.parameters."gateway-domain" = $v }
        GatewayPort     = { param($v) $body.parameters."gateway-port" = $v }
        ResizeMethod    = { param($v) $body.parameters."resize-method" = $v }
        IgnoreCertificate = { param($v) $body.parameters."ignore-cert" = $v }
        EnableWallpaper = { param($v) $body.parameters."enable-wallpaper" = $v }
        DisableAudio    = { param($v) $body.parameters."disable-audio" = $v }
        EnableFontSmoothing = { param($v) $body.parameters."enable-font-smoothing" = $v }
        EnablePrinting  = { param($v) $body.parameters."enable-printing" = $v }
        EnableTheming   = { param($v) $body.parameters."enable-theming" = $v }
        EnableFullwindowDrag = { param($v) $body.parameters."enable-full-window-drag" = $v }
        EnableDesktopComposition = { param($v) $body.parameters."enable-desktop-composition" = $v }
        EnableMenuAnimations = { param($v) $body.parameters."enable-menu-animations" = $v }
    }

    $mapping.keys | ? { $PSBoundParameters.ContainsKey($_) } | % { . $mapping[$_] $PSBoundParameters.$_ }

    $jsonBody =  $body | ConvertTo-Json -Depth 3 | ConvertTo-UnicodeEscapedString

    $r = Invoke-GuacamoleAPIRequest -AuthObject $AuthObject -Endpoint $endpoint -Method Post -Body $jsonBody -Headers $headers

    switch ($r.statusCode.value__) {
        200 {
            $r | Add-Member -MemberType noteproperty -Name Connection -Value $r.Content -PassThru
        }

        default {
            $r
        }
    }

}