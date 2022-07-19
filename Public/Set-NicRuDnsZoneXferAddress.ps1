<#
    .SYNOPSIS
        Get current DNS zone XFER addresses
    .DESCRIPTION
        Изменение списка адресов, с которых разрешен XFER зоны
    .PARAMETER Service
        DNS hosting service name
    .PARAMETER ZoneName
        DNS Zone name
    .PARAMETER XferAddress
        Allowed Xfer Address list
        can have 'any' value
        if not set, address list cleared
    .PARAMETER AccessToken
        Access token to use
    .LINK
        https://www.nic.ru/help/upload/file/API_DNS-hosting.pdf
#>
function Set-NicRuDnsZoneXferAddress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Service,
        [Parameter(Mandatory)]
        [string]$ZoneName,
        [string[]]$XferAddress,
        [string]$AccessToken
    )
    if (-not $AccessToken) {
        $AccessToken = if ($GMNicRuDefaultToken) { $GMNicRuDefaultToken.access_token } else { $null }
    }
    if (-not $AccessToken) {
        throw "AccessToken required"
    }
    $Headers = @{
        "Authorization" = "Bearer $AccessToken"
    }
    $requestParams = @{
        Uri = "https://api.nic.ru/dns-master/services/$Service/zones/$(Get-Punycode $ZoneName)/xfer"
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Method = 'POST'
        Body = "<?xml version=`"1.0`" encoding=`"UTF-8`" ?>
        <request>
         <address>$($XferAddress -join '</address><address>')</address>
        </request>"
    }
    if (-not $XferAddress) { #clear address list
        $requestParams.Body = '<?xml version="1.0" encoding="UTF-8" ?><request></request>'
    }
    Write-Verbose $requestParams.Uri
    $r = Invoke-RestMethod @requestParams @GMNicRuProxySettings
    if ($r -and $r.response) {
        if ($r.response.status -eq 'success') {
        }
        else {
            Write-Error $r.response.errors
        }
    }
}
