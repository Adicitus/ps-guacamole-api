# Found specification of how to update permissions here:
#    https://stackoverflow.com/questions/60651115/how-can-i-connect-user-with-a-connection-by-using-guacamole-rest-api
# JSON Patch specification:
#    https://tools.ietf.org/html/rfc6902#section-4.1

function Set-GuacamoleAPIUserPermissions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$AuthObject,
        [Parameter(Mandatory=$true)]
        [String]$Username,
        [ValidateSet("add", "remove")]
        [Parameter(Mandatory=$true)]
        [string]$Operation,
        [validateSet(
            "connectionPermissions",
            "connectionGroupPermissions",
            "userPermissions",
            "userGroupPermissions",
            "sharingProfilePermissions",
            "activeConnectionPermissions"
        )]
        [Parameter(Mandatory=$true)]
        [string]$Type,
        [Parameter(Mandatory=$true)]
        [string]$Identifier,
        [ValidateSet("READ", "WRITE")]
        [Parameter(Mandatory=$true)]
        [string]$Permission
    )

    $endPoint = "{0}api/session/data/{1}/users/{2}/permissions" -f $authObject.BaseURI, $authObject.DataSource, $Username

    $headers = @{
        "Content-Type" = "application/json"
    }

    $body = @( @{
        op = $Operation
        path = "/{0}/{1}" -f $Type, $Identifier
        value = $Permission
    } )

    $jsonBody = ConvertTo-json $body | ConvertTo-UnicodeEscapedString


    $r = Invoke-GuacamoleAPIRequest -AuthObject $AuthObject -Method Patch -EndPoint $endpoint -Body $jsonBody -Headers $headers

    switch ($r.StatusCode.value__) {
        200 {
            $r | Add-Member -MemberType noteproperty -Name Permissions -Value $r.Content -PassThru
        }

        default {
            $r
        }
    }
}