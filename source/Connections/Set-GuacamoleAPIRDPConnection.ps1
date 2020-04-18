function Set-GuacamoleAPIRDPConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject,
        [Parameter(Mandatory=$true)]
        [string]$Identifier,
        [Parameter(Mandatory=$false)]
        [string]$Username,
        [Parameter(Mandatory=$false)]
        [SecureString]$Password,
        [Parameter(Mandatory=$false)]
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

    $endpoint = "{0}/api/session/data/{1}/connections/{2}" -f $AuthObject.BaseURI, $AuthObject.DataSource, $Identifier

    $headers = @{
        "Content-Type" = "application/json"
    }

    $curCon = Get-GuacamoleAPIConnection -AuthObject $AuthObject -Identifier $Identifier | % Connection
    $curConParams = Get-GuacamoleAPIConnectionParameters -AuthObject $AuthObject -Identifier $Identifier | % Parameters

    $body = @{
        parameters = @{ }
        attributes = @{ }
    }

    $CurCon | gm -MemberType NoteProperty | % {
        $n = $_.Name

        if ($n -in "attributes", "lastActive", "activeConnections") { return }

        $body.$n = $curCon.$n
    }

    $curCon.attributes | gm -MemberType NoteProperty | % {
        $n = $_.Name
        $body.attributes.$n = $curCon.attributes.$n
    }

    $curConParams | gm -MemberType NoteProperty | % {
        $n = $_.Name
        $body.parameters.$n = $curConParams.$n
    }


    $mapping = @{
        Security        = { param($v) $body.parameters.security = $v }
        Hostname        = { param($v) $body.parameters.hostname = $v }
        Username        = { param($v) $body.parameters.username = $v }
        Password        = { param($v) $body.parameters.password = Unlock-SecureString $v }
        Domain          = { param($v) $body.parameters.domain = $v }
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
        EnableFullwindowDrag        = { param($v) $body.parameters."enable-full-window-drag" = $v }
        EnableDesktopComposition    = { param($v) $body.parameters."enable-desktop-composition" = $v }
        EnableMenuAnimations        = { param($v) $body.parameters."enable-menu-animations" = $v }
        MaxConnections              = { param($v) $body.attributes."max-connections" = $v }
        MaxConnectionsPerUser       = { param($v) $body.attributes."max-connections-per-user" = $v }
        ParentIdentifier            = { param($v) $body.parentIdentifier = $v }
    }

    $mapping.keys | ? { $PSBoundParameters.ContainsKey($_) } | % { . $mapping[$_] $PSBoundParameters.$_ }

    if ($body.parameters.Count -eq 0) { $body.Remove("parameters") }
    if ($body.attributes.Count -eq 0) { $body.Remove("attributes") }

    $jsonBody =  $body | ConvertTo-Json -Depth 3 | ConvertTo-UnicodeEscapedString

    $r = Invoke-GuacamoleAPIRequest -AuthObject $AuthObject -Endpoint $endpoint -Method put -Body $jsonBody -Headers $headers

    switch ($r.statusCode) {
        200 {
            $r | Add-Member -MemberType noteproperty -Name Connection -Value $r.Content -PassThru
        }

        default {
            $r
        }
    }

}