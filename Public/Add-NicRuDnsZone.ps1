<#
    .SYNOPSIS
        Add new zone
    .DESCRIPTION
        Создание зоны на услуге
    .PARAMETER Service
        DNS hosting service name
    .PARAMETER ZoneName
        DNS Zone name
    .PARAMETER ZoneData
        DNS Zone file
    .PARAMETER AccessToken
        Access token to use
    .LINK
        https://www.nic.ru/help/upload/file/API_DNS-hosting.pdf
#>
function Add-NicRuDnsZone {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Service,
        [Parameter(Mandatory)]
        [string]$ZoneName,
        [string]$ZoneData,
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
        Uri = "https://api.nic.ru/dns-master/services/$Service/zones/$(Get-Punycode $ZoneName)"
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Method = 'PUT'
    }
    if ($ZoneData) {
        $requestParams.Body = $ZoneData
    }
    Write-Verbose $requestParams.Uri
    $r = Invoke-RestMethod @requestParams @GMNicRuProxySettings
    if ($r -and $r.response) {
        if ($r.response.status -eq 'success') {
            $r.response.data.zone | Select-Object id, name, idn-name, enable, service, has-changes, has-primary, admin, payer
        }
        else {
            Write-Error $r.response.errors
        }
    }
}
