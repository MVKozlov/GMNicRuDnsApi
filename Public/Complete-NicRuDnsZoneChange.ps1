<#
    .SYNOPSIS
        Commit zone records change request
    .DESCRIPTION
        Фиксация версии зоны и выгрузка зоны на DNS-серверы
    .PARAMETER Service
        DNS hosting service name
    .PARAMETER ZoneName
        DNS Zone name
    .PARAMETER AccessToken
        Access token to use
    .LINK
        https://www.nic.ru/help/upload/file/API_DNS-hosting.pdf
#>
function Complete-NicRuDnsZoneChange {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Service,
        [Parameter(Mandatory)]
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
    $requestParams = @{
        Uri = "https://api.nic.ru/dns-master/services/$Service/zones/$(Get-Punycode $ZoneName)/commit"
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Method = 'POST'
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