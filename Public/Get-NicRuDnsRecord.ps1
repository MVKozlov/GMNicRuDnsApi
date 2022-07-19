<#
    .SYNOPSIS
        Get DNS resource record list on selected DNS zone
    .DESCRIPTION
        Получение списка записей в зоне
    .PARAMETER Service
        DNS hosting service name
    .PARAMETER ZoneName
        DNS Zone name
    .PARAMETER RecordName
        Search for record with selected name
    .PARAMETER RecordType
        Search for record with selected type
    .PARAMETER AccessToken
        Access token to use
    .LINK
        https://www.nic.ru/help/upload/file/API_DNS-hosting.pdf
#>
function Get-NicRuDnsRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Service,
        [Parameter(Mandatory)]
        [string]$ZoneName,
        [string]$RecordName,
        [string]$RecordType,
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
        Uri = "https://api.nic.ru/dns-master/services/$Service/zones/$(Get-Punycode $ZoneName)/records"
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Method = 'GET'
    }
    Write-Verbose $requestParams.Uri
    $r = Invoke-RestMethod @requestParams @GMNicRuProxySettings
    if ($r -and $r.response) {
        if ($r.response.status -eq 'success') {
            $r.response.data.zone.rr | Where-Object {
                if ($RecordName -and $RecordType) {
                    $RecordName -eq $_.name -and $RecordType -eq $_.type
                }
                else {
                    (-not ($RecordName -or $RecordType)) -or
                    ($RecordName -and ($RecordName -eq $_.name -or $RecordName -eq $_.'idn-name')) -or
                    ($RecordType -and $RecordType -eq $_.type)
                }
            }
        }
        else {
            Write-Error $r.response.errors
        }
    }
}
