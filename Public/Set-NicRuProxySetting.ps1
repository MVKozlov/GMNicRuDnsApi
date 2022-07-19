<#
.SYNOPSIS
    Set Proxy Settings for use in NicRu functions
.DESCRIPTION
    Установка настроек прокси для использования модулем NicRu
.EXAMPLE
    # Set Proxy
    Set-NicRuProxySettings -Proxy http://mycorpproxy.mydomain
.EXAMPLE
    # Remove Proxy
    Set-NicRuProxySettings -Proxy ''
.OUTPUTS
    None
.NOTES
    Author: Max Kozlov
.LINK
    Get-NicRuProxySetting
#>
function Set-NicRuProxySetting {
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(ValueFromPipelineByPropertyName)]
    [Uri]$Proxy,
    [Parameter(ValueFromPipelineByPropertyName)]
    [PSCredential]$ProxyCredential,
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]$ProxyUseDefaultCredentials
)
    BEGIN {
    }
    PROCESS {
    }
    END {
        if ($PSCmdlet.ShouldProcess("Set New Proxy settings")) {
            if ($Proxy -and $Proxy.IsAbsoluteUri) {
                $GMNicRuProxySettings.Proxy = $Proxy
            }
            else {
                if ($Proxy.OriginalString) {
                       Write-Error 'Invalid proxy URI, may be you forget http:// prefix ?'
                }
                else {
                    [void]$GMNicRuProxySettings.Remove('Proxy')
                }
            }
            if ($ProxyCredential) {
                $GMNicRuProxySettings.ProxyCredential = $ProxyCredential
            }
            else {
                [void]$GMNicRuProxySettings.Remove('ProxyCredential')
            }
            if ($ProxyUseDefaultCredentials) {
                $GMNicRuProxySettings.ProxyUseDefaultCredentials = $ProxyUseDefaultCredentials
            }
            else {
                [void]$GMNicRuProxySettings.Remove('ProxyUseDefaultCredentials')
            }
        }
    }
}
