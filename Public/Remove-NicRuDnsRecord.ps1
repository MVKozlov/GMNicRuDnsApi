<#
    .SYNOPSIS
        Remove resource record
    .DESCRIPTION
        Удаление ресурсной записи
    .PARAMETER Service
        DNS hosting service name
    .PARAMETER ZoneName
        DNS Zone name
    .PARAMETER Id
        Record ID
    .PARAMETER AccessToken
        Access token to use
    .LINK
        https://www.nic.ru/help/upload/file/API_DNS-hosting.pdf
#>
function Remove-NicRuDnsRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Service,
        [Parameter(Mandatory)]
        [string]$ZoneName,
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Id,
        [string]$AccessToken
    )
    BEGIN {
        if (-not $AccessToken) {
            $AccessToken = if ($GMNicRuDefaultToken) { $GMNicRuDefaultToken.access_token } else { $null }
        }
        if (-not $AccessToken) {
            throw "AccessToken required"
        }
        $Headers = @{
            "Authorization" = "Bearer $AccessToken"
        }
    }
    PROCESS {
        $requestParams = @{
            Uri = "https://api.nic.ru/dns-master/services/$Service/zones/$(Get-Punycode $ZoneName)/records/$Id"
            Headers = $Headers
            ContentType = "application/json; charset=utf-8"
            Method = 'DELETE'
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
}
