﻿<#
    .SYNOPSIS
        Request refresh and access tokens from nic.ru api
        Need to register own api app on https://www.nic.ru/manager/oauth.cgi?step=oauth.app_list
    .DESCRIPTION
        Запрос на получение токена по логину и паролю или по предыдущему refresh-токену
        Требуется регистрация собственного "приложения" https://www.nic.ru/manager/oauth.cgi?step=oauth.app_list
    .PARAMETER Client_Id
        Application client_id
    .PARAMETER Client_Secret
        Application client_secret in SecureString form
    .PARAMETER Client_Credential
        Application client_id+client_secret in PSCredential form
    .PARAMETER Scope
        Access scope (for examples see Notes)
        scope это список в формате <method>:<url путь> <method>:<url путь> <method>:<url путь>.
            Элементы списка разделены пробелами.
            Методы (<method>), определяющие права доступа к заданной области и <url путь>, определяющий область доступа, разделены двоеточием.
            Параметр <method> может принимать следующие значения:
                GET – доступ к чтению (получению) данных; 
                PUT – доступ к размещению данных; 
                POST – доступ к изменению данных; 
                DELETE – доступ к удалению размещенных данных
                или может быть задан регулярным выражением, например:
                GET|POST – доступ к чтению и изменению данных;
                GET|PUT – доступ к чтению и размещению данных; 
                GET|PUT|DELETE – доступ к чтению, размещению и удалению размещенных данных;
                GET|POST|DELETE – доступ к чтению, изменению и удалению размещенных данных;
                .+ – полный доступ                
            Параметр <url путь> задается регулярным выражением с ограничением на использование символов ^ и $ и без указания домена и протокола (https://api.nic.ru).
                Для DNS-хостинга всегда начинается с /dns-master/:
                /dns-master/.+ для разрешения доступа ко всем услугам DNS-хостинга; 
                /dns-master/zones/<zone>(/.+)? для разрешения доступа к конкретной зоне <zone>;
                /dns-master/services/<service>(/.+)? для разрешения доступа к конкретной услуге <service>; 
                /dns-master/services/<service>/zones/<zone>(/.+)? для разрешения доступа к конкретной зоне <zone> на конкретной услуге <service> 
    .PARAMETER Username
        Client username in xxx/NIC-D form
    .PARAMETER Password
        Client password (may be administrative or technical)
    .PARAMETER Credential
        Client username+password in PSCredential form (may be administrative or technical)
    .PARAMETER RefreshToken
        Refresh token (for refresh access token)
    .OUTPUTS
        Object with refresh_token/access_token to use
        The last received access token is stored in the module for future use
    .EXAMPLE
        $username = '12345/NIC-D'
        $password = 'Pa$sw0rd' | ConvertTo-SecureString -AsPlainText
        $t = Request-NicRuToken -Client_id cid23424234 -Client_Secret cis2342423 -Username $username -Password $password
        Get-NicRuDnsService -AccessToken $t.access_token
    .EXAMPLE
        # Ask for user/password
        $cred = Get-Credential '12345/NIC-D'
        # Ask for client_id/client_secret
        $cli_cred = Get-Credetial 'cid23424234'
        # Request access to zone test.ru
        Request-NicRuToken -Client_Credential $cli_cred -Credential $cred -Scope '/dns-master/zones/org.ru(/.+)?'
        # Get entry using last received access token stored internally after Request-NicRuToken
        Get-NicRuDnsRecord -Service 'PRST-ORG-RU' -ZoneName 'org.ru' -RecordName 'test'
    .EXAMPLE
        $t = Request-NicRuToken -Client_id cid23424234 -Client_Secret cis2342423 -RefreshToken ($t.refresh_token | ConvertTo-SecureString -AsPlainText)
        # The last received access token is stored inside the module for future use, so Access token not required
        Get-NicRuDnsService
    .LINK
        https://www.nic.ru/manager/oauth.cgi?step=oauth.app_list
    .LINK
        https://www.nic.ru/help/oauth-server_3642.html
        https://www.nic.ru/help/upload/file/API_DNS-hosting.pdf
    .NOTES
        Scopes:
            • scope=GET:/dns-master/.+
                ограничение только на чтение данных по всем услугам DNS-хостинга на договоре; 
            • scope=POST:/dns-master/.+ 
                доступ на изменение данных ко всем услугам DNS-хостинга на договоре; 
            • scope=(GET|PUT):/dns-master/services/<service>/.+ 
                доступ на чтение и размещение данных к конкретной услуге <service>; 
            • scope=PUT:/dns-master/services/<service>/zones/<zone1>(/.+)? POST:/dns-master/services/<service>/zones/<zone2>(/.+)? 
                доступ на размещение данных к зоне <zone1> и на редактирование к зоне <zone2>, находящихся на услуге <service>. Элементы
                списка в параметре scope (PUT:/dns-master/services/<service>/zones/<zone1>(/.+)? и POST:/dnsmaster/services/<service>/zones/<zone2>(/.+)?) разделены пробелом;
            • scope=(GET|POST|DELETE):/dns-master/services/<service>/zones/<zone>(/.+)?
                доступ на чтение, изменение и удаление данных к зоне <zone>, находящейся на услуге <service>;
            • scope=GET:/dns-master/services/<service>/.+
                ограничение только на чтение к услуге <service>; 
            • scope=GET:/dns-master/services/<service1>/zones/<zone1>(/.+)? PUT:/dns-master/services/<service2>/zones/<zone2>(/.+)? 
                (POST|DELETE):/dns-master/services/<service3>/zones/<zone3>(/.+)? 
                доступ на чтение к зоне <zone1>, находящейся на услуге <service1>, разрешения доступа на добавление данных к зоне <zone2>, 
                находящейся на услуге <service2>, и разрешения доступа на редактирование и удаление данных к зоне <zone3>, находящейся на
                услуге <service3>. Элементы списка в параметре scope (GET:/dns-master/services/<service1>/zones/<zone1>(/.+)?,
                PUT:/dns-master/services/<service2>/zones/<zone2>(/.+)? и (POST|DELETE):/dnsmaster/services/<service2>/zones/<zone2>(/.+)?) разделены пробелами; 
            • scope=POST:.+/zones/<zone>(/.+)?
                доступ на редактирование к зоне <zone>; 
            • PUT:/dns-master/services/service/.+
                доступ на добавление данных к конкретной услуге <service>; 
            • scope=.+:/dns-master/.+
                полный доступ ко всем услугам DNS-хостинга на договоре. 
#>
function Request-NicRuToken {
[CmdletBinding()]
param(
    [Parameter(Mandatory, ParameterSetName='iu')]
    [Parameter(Mandatory, ParameterSetName='ic')]
    [Parameter(Mandatory, ParameterSetName='ir')]
    [string]$Client_Id,
    [Parameter(Mandatory, ParameterSetName='iu')]
    [Parameter(Mandatory, ParameterSetName='ic')]
    [Parameter(Mandatory, ParameterSetName='ir')]
    [securestring]$Client_Secret,
    [Parameter(Mandatory, ParameterSetName='cu')]
    [Parameter(Mandatory, ParameterSetName='cc')]
    [Parameter(Mandatory, ParameterSetName='cr')]
    [pscredential]$Client_Credential,
    [string]$Scope = '.+',
    [Parameter(Mandatory, ParameterSetName='iu')]
    [Parameter(Mandatory, ParameterSetName='cu')]
    [string]$Username,
    [Parameter(Mandatory, ParameterSetName='iu')]
    [Parameter(Mandatory, ParameterSetName='cu')]
    [securestring]$Password,
    [Parameter(Mandatory, ParameterSetName='ic')]
    [Parameter(Mandatory, ParameterSetName='cc')]
    [pscredential]$Credential,
    [Parameter(Mandatory, ParameterSetName='ir')]
    [Parameter(Mandatory, ParameterSetName='cr')]
    [securestring]$RefreshToken
)
    if ($PSCmdlet.ParameterSetName -in 'iu', 'ic', 'ir') {
        $credentials = New-Object System.Management.Automation.PSCredential $Client_Id, $Client_Secret
    }
    else {
        $credentials = $Client_Credential
    }
    if ($PSCmdlet.ParameterSetName -in 'ir', 'cr') {
        $c = New-Object System.Management.Automation.PSCredential @('t', $RefreshToken)
        $body = @{
            grant_type = 'refresh_token'
            refresh_token = $c.GetNetworkCredential().Password
        }
    }
    else {
        if ($PSCmdlet.ParameterSetName -in 'ic', 'cc') {
            $Password = $Credential.Password
            $Username = $Credential.UserName
        }
        $c = New-Object System.Management.Automation.PSCredential @('t', $Password)
        $body = @{
            offline = 1
            grant_type = 'password'
            scope = $Scope
            username = $Username
            password = $c.GetNetworkCredential().Password
        }
    }
    $requestParams = @{
        Uri = "https://api.nic.ru/oauth/token"
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Body = $body
        UseBasicParsing = $true
    }
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        # legacy powershell authorization workaround
        $requestParams.Headers = @{
            Authorization = 'Basic ' + [Convert]::ToBase64String([System.Text.Encoding]::Utf8.GetBytes($credentials.UserName + ':' + $credentials.GetNetworkCredential().Password))
        }
        $requestParams.Use
    }
    else {
        $requestParams.Authentication = 'Basic'
        $requestParams.Credential = $credentials
    }
    Write-Verbose $requestParams.Uri
    Invoke-RestMethod -Method Post @requestParams @GMNicRuProxySettings | Tee-Object -Variable token
    #save default
    $GMNicRuDefaultToken.refresh_token = $token.refresh_token
    $GMNicRuDefaultToken.expires_in    = $token.expires_in
    $GMNicRuDefaultToken.access_token  = $token.access_token
    $GMNicRuDefaultToken.token_type    = $token.token_type    
}
