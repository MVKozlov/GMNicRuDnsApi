<#
    .SYNOPSIS
        Save access tokens and updates obtained from external sources for future internal use.
        It is used if you do not want to append the AccessToken parameter for other commands each time.
    .DESCRIPTION
        Сохранить токены доступа и обновления, полученные из внешних источников, для будущего использования.
        Используется, если не хочется каждый раз дописывать параметр AccessToken для остальных команд
    .PARAMETER Client_Id
        Application client_id
#>
function Register-NicRuToken {
    [CmdletBinding(DefaultParameterSetName='s')]
    param(
        [Parameter(Mandatory, Position=0, ParameterSetName='s')]
        [securestring]$RefreshToken,
        [Parameter(Mandatory, Position=1, ParameterSetName='s')]
        [securestring]$AccessToken,
        [Parameter(Mandatory, Position=0, ParameterSetName='t')]
        [string]$RefreshTokenText,
        [Parameter(Mandatory, Position=1, ParameterSetName='t')]
        [string]$AccessTokenText
    )
    if ($PSCmdlet.ParameterSetName -eq 's') {
        $c = New-Object System.Management.Automation.PSCredential @('t', $RefreshToken)
        $GMNicRuDefaultToken.refresh_token = $c.GetNetworkCredential().Password
        $c = New-Object System.Management.Automation.PSCredential @('t', $AccessToken)
        $GMNicRuDefaultToken.access_token  = $c.GetNetworkCredential().Password
    }
    else {
        $GMNicRuDefaultToken.refresh_token = $RefreshTokenText
        $GMNicRuDefaultToken.access_token  = $AccessTokenText
    }
}
