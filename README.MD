# Модуль nic.ru/DNS api

Модуль PowerShell для работы с [DNS Api от nic.ru](https://www.nic.ru/help/api-dns-hostinga_3643.html)
( Помощь | Услуги | Сервисы | API ), [Документация](https://www.nic.ru/help/upload/file/API_DNS-hosting.pdf)

- Поддерживает всё апи на 19.07.2022
- Не тестировались ревизии зон.

## Схема работы

- Регистрируем своё api приложение по адресу [https://www.nic.ru/manager/oauth.cgi?step=oauth.app_list](https://www.nic.ru/manager/oauth.cgi?step=oauth.app_list)
- Записываем `client_id`, `client_secret`
- Получаем токены доступа (не автоматизируя этот момент, вручную, пример ниже)
- Сохраняем `refresh_token` в файл для последующего использования вместе с `client_id`, `client_secret`, по возможности секурно
- Используем `access_token` по необходимости
- Для автоматизации или последующего использования восстанавливаем параметры доступа из файла
- Получаем новый `access_token` и используем

## Пример сохранения токенов в файле и работы с этим всем вручную

Для относительно безопасного сохранения используем SecureString.
Не то чтобы совсем круто, но хотя бы привязано к компу и пользователю

``` powershell
function New-NicCredential($client_id, $client_secret, $refresh_token) {
    [PSCustomObject]@{
        client_id = $client_id
        client_secret = $client_secret | ConvertTo-SecureString -AsPlainText -Force
        refresh_token = $refresh_token | ConvertTo-SecureString -AsPlainText -Force
    }
}
function Save-NicCredential($path, $credential) {
    Set-Content -Path $path -Value $credential.client_id,
        ($credential.client_secret | ConvertFrom-SecureString),
        ($credential.refresh_token | ConvertFrom-SecureString)
}

# Логины-пароли
$nic_username = '12345/NIC-D'
$nic_password = 'PaS$w0rd' | ConvertTo-SecureString -AsPlainText -Force
$nic_api_client_id = 'api_clid_78678678968686876'
$nic_api_client_secret = 'api_secret_34534534534534'
# Доступы:
# Вообще везде
$scope = '.+'
# На определённом сервисе
$scope = '.+:/dns-master/services/prst-svc-test-ru/.+'
# На определённом сервисе в определённой зоне.
# Для автоматизации предпочтительно именно так
$scope = '.+:/dns-master/services/prst-svc-test-ru/zones/test.ru(/.+)?'

# Первичное получение токена
$t = Request-NicRuToken -Client_Id $nic_api_client_id -Client_Secret ($nic_api_client_secret | ConvertTo-SecureString -AsPlainText -Force) -Scope $Scope -Username $nic_username -Password $nic_password

# Создание объекта с параметрами доступа
$cred = New-NicCredential $nic_api_client_id $nic_api_client_secret $t.refresh_token
# Сохранение параметров в файл
Save-NicCredential -Path d:\nic_credentials.txt -Credential $cred

# Можно попользоваться чтобы что-то посмотреть
Get-NicRuDnsZone -Service prst-test-ru
```

## Пример использования сохраненных токенов в файлике и работы с этим всем автоматически

Предполагается, что первоначально токены уже созданы вручную и записаны в файл с помощью описанной выше процедуры через
`New-NicCredential` / `Save-NicCredential`

Никаких проверок на ошибки

``` powershell
function Save-NicCredential($path, $credential) {
    Set-Content -Path $path -Value $credential.client_id,
        ($credential.client_secret | ConvertFrom-SecureString),
        ($credential.refresh_token | ConvertFrom-SecureString)
}
function Restore-NicCredential($path) {
    $data = Get-Content $path
    [PSCustomObject]@{
        client_id = $data[0]
        client_secret = $data[1] | ConvertTo-SecureString
        refresh_token = $data[2] | ConvertTo-SecureString
    }
}
# Восстанавливаем параметры доступа из файла
$credentials = Restore-NicCredential -Path d:\nic_credentials.txt

# Получаем свежий токен
$t = Request-NicRuToken -Client_Id $credentials.client_id -Client_Secret $credentials.client_secret -RefreshToken $credentials.refresh_token

# Тут же сохраняем обратно, потому что при получении access_token, refresh_token тоже сразу меняется
$credentials.refresh_token = $t.refresh_token | ConvertTo-SecureString -AsPlainText -Force
# Тут стоило бы добавить проверку, что ошибки не было, а то затрём рабочий токен
Save-NicCredential -Path d:\nic_credentials.txt -Credential $credentials

# Используем уже автоматом, например, для создания записи под LetsEncrypt
Add-NicRuDnsRecord -Service prst-svc-test-ru -ZoneName test.ru -Record @{name='_acme-challenge'; type='txt'; text='h694hd58934256hf8346s583645s'} | Tee-Object -Variable acme
Complete-NicRuDnsZoneChange -Service prst-svc-test-ru -ZoneName test.ru

# Естественно, для LE её потом надо будет удалить за собой
Remove-NicRuDnsRecord -Service prst-svc-test-ru -ZoneName test.ru -Id $acme.Id
Complete-NicRuDnsZoneChange -Service prst-svc-test-ru -ZoneName test.ru
```

Пайплайн в общем-то не нужен и поддерживается для одного единственного коммандлета _Remove-NicRuDnsRecord_, для одного единственного параметра _Id_, остальное симулируется через splatting

``` powershell
$params = @{
    Service = 'prst-svc-test-ru'
    ZoneName = 'test.ru'
}
Get-NicRuDnsRecord @params -RecordName "_acme-challenge" | Remove-NicRuDnsRecord @params
```

Забытые токены всегда можно посмотреть на страничке
[Управление приложением](https://www.nic.ru/manager/oauth.cgi?step=oauth.app_list)

Там же и удалить лишнее
