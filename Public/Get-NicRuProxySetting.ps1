<#
.SYNOPSIS
    Set Proxy Settings for use in NicRu functions
.DESCRIPTION
    Получение текущих настроек прокси для использования модулем NicRu
.OUTPUTS
    Proxy settings as PSObject
.NOTES
    Author: Max Kozlov
.LINK
    Set-NicRuProxySetting
#>
function Get-NicRuProxySetting {
[CmdletBinding()]
param(
)
    [PSCustomObject]@{
        Proxy = if ($GMNicRuProxySettings.Proxy) { $GMNicRuProxySettings.Proxy } else { $null }
        ProxyCredential = if ($GMNicRuProxySettings.ProxyCredential) { $GMNicRuProxySettings.ProxyCredential } else { $null }
        ProxyUseDefaultCredentials = if ($GMNicRuProxySettings.ProxyUseDefaultCredentials) { $GMNicRuProxySettings.ProxyUseDefaultCredentials } else { $null }
    }
}
