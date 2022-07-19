<#
    .SYNOPSIS
        Get DNS-hosting service list
    .DESCRIPTION
        Получение списка услуг DNS-хостинга на договоре
    .PARAMETER Service
        Search for service name
    .PARAMETER AccessToken
        Access token to use
    .LINK
        https://www.nic.ru/help/upload/file/API_DNS-hosting.pdf
#>
function Get-NicRuDnsService {
    [CmdletBinding()]
    param(
        [string]$Service,
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
        Uri = "https://api.nic.ru/dns-master/services"
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Method = 'GET'
    }
    Write-Verbose $requestParams.Uri
    $r = Invoke-RestMethod @requestParams @GMNicRuProxySettings
    if ($r -and $r.response) {
        if ($r.response.status -eq 'success') {
            $r.response.data.service |
            Where-Object { -not $Service -or $Service -eq $_.name } |
            Select-Object name, enable, domains-limit, domains-num, has-primary, rr-limit, rr-num, admin, payer, tariff
        }
        else {
            Write-Error $r.response.errors
        }
    }
}
