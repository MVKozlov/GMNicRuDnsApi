#requires -Module Microsoft.PowerShell.Security
#noqa PSAvoidUsingPlainTextForPassword
<#
    .SYNOPSIS
        NIC.RU DNS Validation script for WinAcme
        SecureString used for credentials
    .DESCRIPTION
        Скрипт валидации DNS записей NIC.RU для WinAcme

        Credentials для работы предварительно должны быть сохранены в файле вручную с помошью New-NicCredential/Save-NicCredential из README

        SecureString использутся для хранения credentials запроса. Если это кажется небезопасным, необходимо поправить
        функции сохранения и восстановления под себя.

        Параметры вызова стандартные для скрипта - {Action} {Identifier} {RecordName} {Token}

        Необходимо также предварительно поправить под себя константы:
        $CredentialPath = "nic_credentials.txt"
        $DnsService = 'PRST-TEST-RU'
        $ZoneName = 'test.ru'
        Если есть желание передавать эти значения через параметры вызова, надо, соответственно,
        иcпользовать правильные --dnscreatescriptarguments

        Так как WinACME проверяет DNS сразу после вызова, а nic.ru раскидывает зоны не спеша, необходимо "поспать" перед выходом
        Это время можно уменьшить/увеличить, поправив
        $SLEEP_AFTER_UPDATE = 180 

        Паралеллизм не поддерживается из-за того, что чтение/запись в файл не атомарные. Есть шанс попортить refresh_token.
    .LINK
        https://www.win-acme.com/reference/plugins/validation/dns/script
#>
[CmdletBinding()]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "CredentialPath")]
param(
    [string]$Action,
    [string]$Identifier,
    [string]$RecordName,
    [string]$Token,
    [string]$CredentialPath = "nic_credentials.txt",
    [string]$DnsService = 'PRST-TEST-RU',
    [string]$ZoneName = 'test.ru'
)
$SLEEP_AFTER_UPDATE = 180 # Секунд

function Save-NicCredential($path, $access_object) {
    Write-Verbose "Save credentials to $path"
    Set-Content -Path $path -Value $access_object.client_id,
        ($access_object.client_secret | ConvertFrom-SecureString),
        ($access_object.refresh_token | ConvertFrom-SecureString),
        ($access_object.access_token  | ConvertFrom-SecureString),
         $access_object.access_expires.ToFileTime() -ErrorAction Stop
}
function Restore-NicCredential($path) {
    Write-Verbose "Restore credentials from $path"
    $data = Get-Content -Path $path -ErrorAction Stop
    [PSCustomObject]@{
        client_id     = $data[0]
        client_secret = $data[1] | ConvertTo-SecureString
        refresh_token = $data[2] | ConvertTo-SecureString
        access_token  = if ($data[3]) { $data[3] | ConvertTo-SecureString } else { '' }
        access_expires = if ($data[4]) { [DateTime]::FromFileTime(([int64]$data[4])) } else { [DateTime]::MinValue }
    }
}

# Восстанавливаем параметры доступа из файла
$credentials = Restore-NicCredential -Path $CredentialPath
$TimeNow = Get-Date
if (-not ($credentials.client_id -and $credentials.client_secret -and $credentials.refresh_token)) {
    throw "Can't find valid credentials"
}
# Обновляем если надо
if ((-not $credentials.access_token) -or ($credentials.access_expires -le $TimeNow.AddSeconds(300))) {
    Write-Verbose "Request token"
    # Получаем свежий токен
    $t = Request-NicRuToken -Client_Id $credentials.client_id -Client_Secret $credentials.client_secret -RefreshToken $credentials.refresh_token
    if (-not $t) {
        throw "Can't refresh token"
    }
    # Тут же сохраняем обратно, потому что при получении access_token, refresh_token тоже сразу меняется
    $credentials.refresh_token = $t.refresh_token | ConvertTo-SecureString -AsPlainText -Force
    $credentials.access_token = $t.access_token | ConvertTo-SecureString -AsPlainText -Force
    $credentials.access_expires = (Get-Date).AddSeconds($t.expires_in)
    Save-NicCredential -Path $CredentialPath -Credential $credentials
}
else {
    Write-Verbose "Register saved token"
    Register-NicRuToken -RefreshToken $credentials.refresh_token -AccessToken $credentials.access_token
}

# Добавим финальную точку в запись, чтобы не заморачиваться с отрезанием зоны
$RecordName += '.'
# Работаем
if ($Action -eq 'create') {
    Write-Verbose "Action: Create"
    Add-NicRuDnsRecord -Service $DnsService -ZoneName $ZoneName -Record @{
        name = $RecordName
        type = 'TXT'
        text = $Token
        ttl  = 60
    } -ErrorAction Stop | Tee-Object -Variable acme
    Complete-NicRuDnsZoneChange -Service $DnsService -ZoneName $ZoneName -ErrorAction Stop
    # Подождать слегка пока DNS обновится, а то winacme очень гонит, nic.ru не успевает запись раскидать
    Start-Sleep -Seconds $SLEEP_AFTER_UPDATE
}
elseif ($Action -eq 'delete') {
    Write-Verbose "Action: Delete"
    $record = Get-NicRuDnsRecord -Service $DnsService -ZoneName $ZoneName -RecordType 'TXT'  -ErrorAction Stop | Where-Object {
        $RecordName.StartsWith($_.name) -and $_.txt.string -eq $Token
    }
    if (-not $record) {
        throw "Can't find dns record $RecordName"
    }
    Remove-NicRuDnsRecord -Service $DnsService -ZoneName $ZoneName -Id $record.Id  -ErrorAction Stop
    Complete-NicRuDnsZoneChange -Service $DnsService -ZoneName $ZoneName  -ErrorAction Stop
}
else {
    throw "Unknown action $Action"
}
