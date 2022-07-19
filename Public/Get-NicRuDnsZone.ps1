<#
    .SYNOPSIS
        Get DNS Zone on selected DNS-hosting service or anywhere
    .DESCRIPTION
        Получение списка всех доменных зон
    .PARAMETER Service
        DNS hosting service name
   .PARAMETER ZoneName
        Search for zone name
    .PARAMETER AccessToken
        Access token to use
    .LINK
        https://www.nic.ru/help/upload/file/API_DNS-hosting.pdf
#>
function Get-NicRuDnsZone {
    [CmdletBinding()]
    param(
        [string]$Service = '',
        [string]$ZoneName,
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
    $uri_add = if ($Service) { "/services/$Service" } else { "" }
    $requestParams = @{
        Uri = "https://api.nic.ru/dns-master{0}/zones" -f $uri_add
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Method = 'GET'
    }
    Write-Verbose $requestParams.Uri
    $r = Invoke-RestMethod @requestParams @GMNicRuProxySettings
    if ($r -and $r.response) {
        if ($r.response.status -eq 'success') {
            $r.response.data.zone |
            Where-Object { -not $ZoneName -or ($ZoneName -eq $_.name -or $ZoneName -eq $_.'idn-name') } |
            Select-Object id, name, idn-name, enable, service, has-changes, has-primary, admin, payer
        }
        else {
            Write-Error $r.response.errors
        }
    }
}