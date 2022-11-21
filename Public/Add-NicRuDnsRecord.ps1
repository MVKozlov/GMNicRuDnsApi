<#
    .SYNOPSIS
        Add new resource record
    .DESCRIPTION
        Добавление ресурсной записи
    .PARAMETER Service
        DNS hosting service name
    .PARAMETER ZoneName
        DNS Zone name
    .PARAMETER Record
        Array of objects/hashes with record data:

        Данные, присутствующие в каждой записи
            name - Имя записи (для некоторых типов есть синонимы)
            type - Тип записи.
            ttl - Время жизни (не обязательно)

        Данные по типам описаны в заметках

    .PARAMETER AccessToken
        Access token to use

    .OUTPUTS
        RR object
    .EXAMPLE
        # add A record, use selected token
        Add-NicRuDnsRecord -AccessToken $t.access_token -Service prst-svc-org-ru -ZoneName org.ru -Record @{name='samplea'; type='a'; ip='8.8.8.8'}
    .EXAMPLE
        # add AAAA record,  use default(last requested) token
        Add-NicRuDnsRecord -Service prst-svc-org-ru -ZoneName org.ru -Record @{name='sss'; type ='aaaa'; ipv6='222:10:2521:1:210:4bff:fe10:d24'}
    .EXAMPLE
        # add TXT records, two entries at a time, multi-line
        Add-NicRuDnsRecord -Service prst-svc-org-ru -ZoneName org.ru -Record @{name='txt1'; type='txt'; text='textval1', 'testval2'}, @{name='txt3'; type='txt'; text='testval3'}
    .EXAMPLE
        # add SOA record
        Add-NicRuDnsRecord -Service prst-svc-org-ru -ZoneName org.ru -Record @{name='ssss'; type='soa'; 'ns-name' = 'aaa'; mail='mail.test.ru'; 'serial' = 10; retry=10; expire=10; minimum = 10; refresh=10}
    .EXAMPLE
        # add CNAME record
        Add-NicRuDnsRecord -Service prst-svc-org-ru -ZoneName org.ru -Record @{name='sssc'; type ='cname'; canonical='sss'}
    .EXAMPLE
        # add NS record
        Add-NicRuDnsRecord -Service prst-svc-org-ru -ZoneName org.ru -Record @{name='sssns'; type ='ns'; ns='sss'}
    .EXAMPLE
        # add MX record
        Add-NicRuDnsRecord -Service prst-svc-org-ru -ZoneName org.ru -Record @{name='sssmx'; type ='mx'; priority=10; 'mail-relay'='sss'}
    .EXAMPLE
        # add SRV record
        Add-NicRuDnsRecord -Service prst-svc-org-ru -ZoneName org.ru -Record @{name='_sip._tcp.test.ru.'; type ='srv'; priority=10; weight = 10; port=1000; target='sipserver.test.ru.'}
    .EXAMPLE
        # add PTR record
        Add-NicRuDnsRecord -Service prst-svc-org-ru -ZoneName org.ru -Record @{name='ssss'; type='ptr'; 'host-name'='test.ru.'}
    .EXAMPLE
        # add DNAME record
        Add-NicRuDnsRecord -Service prst-svc-org-ru -ZoneName org.ru -Record @{name='sss'; type='dname'; target='test.ru.'}
    .EXAMPLE
        # add HINFO record
        Add-NicRuDnsRecord -Service prst-svc-org-ru -ZoneName org.ru -Record @{name='sss'; type='hinfo'; os='linux'; cpu='atom'}
    .EXAMPLE
        # add NAPTR record
        Add-NicRuDnsRecord -Service prst-svc-org-ru -ZoneName org.ru -Record  @{name='sss'; type='naptr'; order=10; preference=10; flags=0; service='http'; regexp='sip._tcp.test.ru'; replacement='.'}
    .EXAMPLE
        # add RP record
        Add-NicRuDnsRecord -Service prst-svc-org-ru -ZoneName org.ru -Record @{name='sss'; type='rp'; 'mbox-dname'='root.example.test.ru.'; 'txt-dname'='ops.cs.umd.ru.'}
    .LINK
        https://www.nic.ru/help/upload/file/API_DNS-hosting.pdf
    .NOTES
        RR data by type:

        SOA - (Start of Authority) или начальная запись зоны указывает, на каком сервере хранится эталонная информация о данном домене, содержит контактную информацию лица, ответственного за данную зону, параметры времени кеширования зонной информации и взаимодействие DNS-серверов.

            name – имя зоны;
            ns-name – имя первичного DNS-сервера зоны;
            mail – контактный адрес лица, ответственного за администрирование зоны;
            serial - серийный номер файла зоны;
            refresh - показывает, как часто вторичные серверы должны запрашивать первичный сервер для согласования описания зоны;
            retry - показывает, как долго вторичный сервер имен должен ждать перед тем, как повторить попытку запроса первичного сервера на 
            предмет согласования описания зоны, если предыдущая попытка оказалась неудачной;
            expire - указывает верхнее ограничение по времени, в течение которого вторичный сервер может использовать ранее полученные данные о зоне до того, как они потеряют силу из-за отсутствия обновления;
            minimum - минимальное время актуальности отрицательных ответов на запросы о ресурсах, не существующих в DNS.
        
        A - (address record) или запись адреса — связывает имя хоста с IP-адресом.

            name - доменное имя, к которому привязана или которому принадлежит данная ресурсная запись;
            ip – IP-адрес

        AAAA - адрес в формате IPv6.

            name - доменное имя, к которому привязана или которому принадлежит данная ресурсная запись;
            ipv6 – IPv6-адрес

        CNAME - (Canonical name) — каноническое имя для псевдонима, используется для перенаправления на другое имя (одноуровневая переадресация)

            name/alias — псевдоним; 
            canonical - каноническое имя

        NS - (name server) — адрес узла, отвечающего за доменную зону.

            name – доменное имя, к которому привязана или которому принадлежит данная ресурсная запись; 
            ns-name – имя DNS-сервера, который является авторитативным для данной зоны. 

        MX - (mail exchange) или почтовый обменник — указывает сервер(ы) обмена почтой для данного домена.

            name — доменное имя, к которому привязана или которому принадлежит данная ресурсная запись; 
            priority — приоритет (чем число больше, тем ниже приоритет); 
            mail-relay — адрес почтового шлюза для домена

        SRV - (Server selection) — указывает на местоположение серверов для различных сервисов, а также на протокол, по которому эта служба работает.

            name/service-proto — имя сервиса и имя протокола. Сервис записывается как _имя сервиса, обычно используются протоколы _tcp или _udp;
            priority — приоритет (чем число больше, тем ниже приоритет);
            weight — вес записи. Используется для записей с одинаковым приоритетом;
            port — порт на сервере;
            target — каноническое имя сервера, предоставляющего сервис.

        PTR - (Domain name pointer) или запись указателя — служит для обратного отображения IP-адреса в имя хоста.

            name — доменное имя, к которому привязана или которому принадлежит данная ресурсная запись; 
            host-name — абсолютное имя хоста (с точкой в конце имени).

        TXT - (Text string) запись содержит общую текстовую информацию, например, указывает месторасположение хоста.

            name — доменное имя, к которому привязана или которому принадлежит данная ресурсная запись;
            text — запись произвольных двоичных данных, до 255 байт в размере; одно и более повторений (массив)

        DNAME - (Domain Name) — псевдоним для домена. Обеспечивает перенаправление имени нетерминального домена. DNAME вызывает переименование корня и всех потомков в поддереве пространства имен домена, дает возможность переименовать часть пространства имен домена, соединить два пространства имен.

            name — доменное имя, к которому привязана или которому принадлежит данная ресурсная запись; 
            target — доменное имя, на которое происходит перенаправление.

        HINFO - (Host Information) — определяет тип оборудования и операционную систему хоста.

            name — имя узла, аппаратное и программное обеспечение которого описано в разделе данных этой записи; 
            cpu — аппаратное обеспечение, используемое узлом; 
            os — операционная система, под управлением которой работает узел. 

        NAPTR - (Naming authority pointer) — определяет правило подстановки, основанное на регулярном выражении, применяемое для существующего значения, которое произведет новое обозначение домена или единообразный идентификатор ресурса (URI).
                Результирующее обозначение домена или URI может использоваться в последовательных запросах NAPTR-записи или как вывод целого процесса, для которого эта система используется.

            name — имя домена, на которое ссылается эта ресурсная запись; 
            order — 16-разрядное целое число без знака, точно определяющее порядок, в котором должны быть обработаны записи NAPTR, чтобы 
                    гарантировать правильное упорядочение результата; 
            preference — 16-разрядное целое число без знака, которое определяет очередность, в которой меньшие значения должны быть обработаны 
                    раньше больших значений. Если перечислено в наборе записей NAPTR несколько записей, имеющих одинаковый Order, то нужно 
                    использовать значение Preference, чтобы решить какую из записей выбрать; 
            flags — используются для управления аспектами перезаписи и интерпретации полей в записи. В настоящее время определены только 
                    четыре флажка: "S", "A", "U" и "P";
            service — определяет сервисы, доступные при перезаписи пути. Может также определять конкретный частный протокол, который 
                    используется для обмена сообщениями с сервисом; 
            regexp — выражение подстановки; 
            replacement — для неконечных записей NAPTR указывает следующее доменное имя для поиска. 

        RP - (Responsible person) содержит адрес электронной почты (в котором знак @ заменен точкой) лица, ответственного за машину или домен,
                и псевдоимя записи ТХТ, которым можно пользоваться для получения дополнительной информации (например, номера телефона или полного имени).

            name — доменное имя, к которому привязана или которому принадлежит данная ресурсная запись; 
            mbox-dname — определяет адрес электронной почты; 
            txt-dname — доменное имя, для которого существует запись TXT

#>
function Add-NicRuDnsRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Service,
        [Parameter(Mandatory)]
        [string]$ZoneName,
        [Parameter(Mandatory)]
        [array]$Record,
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
    $sb = New-Object System.Text.StringBuilder '<?xml version="1.0" encoding="UTF-8" ?><request><rr-list>'
    $counter = 0
    foreach ($r in $Record) {
        # Side effect: set name on CNAME or SRV, type.ToUpper()
        if (-not (Test-DNSRecordParameter $r)) {
            continue
        }
        Write-Verbose "Try to add record '$($r.name)' of type '$($r.type)'"
        $counter++
        $txt = "<rr>
        <name>$($r.name)</name>
        <ttl>$($r.ttl)</ttl>
        <type>$($r.type)</type>
        {0}
        </rr>
        "
        switch ($r.type) {
            'A' {
                $txt = $txt -f "<a>$($r.ip)</a>"
            }
            'AAAA' {
                $txt = $txt -f "<aaaa>$($r.ipv6)</aaaa>"
            }
            'CNAME'{
                $txt = $txt -f "
                    <cname>
                        <name>$($r.canonical)</name>
                    </cname>"
            }
            'NS' {
                $txt = $txt -f "
                    <ns>
                        <name>$($r.'ns-name')</name>
                    </ns>"                    
            }
            'MX' {
                $txt = $txt -f "
                <mx>
                    <preference>$($r.priority)</preference>
                    <exchange>
                        <name>$($r.'mail-relay')</name>
                    </exchange> 
                </mx>"
             }
            'SOA' {
                $txt = $txt -f "
                <soa>
                    <mname>
                        <name>$($r.'ns-name')</name>
                    </mname>
                    <rname>
                        <name>$($r.mail)</name>
                    </rname>
                    <serial>$($r.serial)</serial>
                    <refresh>$($r.refresh)</refresh>
                    <retry>$($r.retry)</retry>
                    <expire>$($r.expire)</expire>
                    <minimum>$($r.minimum)</minimum>
                </soa>"
            }
            'SRV' {
                $txt = $txt -f "
                <srv>
                    <priority>$($r.priority)</priority>
                    <weight>$($r.weight)</weight>
                    <port>$($r.port)</port>
                    <target>
                        <name>$($r.target)</name>
                    </target> 
                </srv>"
            }
            'PTR' {
                $txt = $txt -f "
                <ptr>
                    <name>$($r.'host-name')</name>
                </ptr>"
            }
            'TXT' {
                $txt = $txt -f "
                <txt>
                    <string>$($r.text -join '</string><string>')</string>
                </txt>"
            }
            'DNAME' {
                $txt = $txt -f "
                <dname>
                    <name>$($r.target)</name>
                </dname>"
            }
            'HINFO' {
                $txt = $txt -f "
                <hinfo>
                    <hardware>$($r.cpu)</hardware>
                    <os>$($r.os)</os>
                </hinfo>"
            }
            'NAPTR' {
                $txt = $txt -f "
                <naptr>
                    <order>$($r.order)</order>
                    <preference>$($r.preference)</preference>
                    <flags>$($r.flags)</flags>
                    <service>$($r.service)</service>
                    <regexp>$($r.regexp)</regexp>
                    <replacement>
                        <name>$($r.replacement)</name>
                    </replacement>
                </naptr>"
            }
            'RP' {
                $txt = $txt -f "
                <rp>
                    <mbox-dname>
                        <name>$($r.'mbox-dname')</name>
                    </mbox-dname>
                    <txt-dname>
                        <name>$($r.'txt-dname')</name>
                    </txt-dname>
                </rp>"
            }
            default: {
                throw "Unknown record type for " + $r
            }
        }
        [void]$sb.Append($txt)
    }
    [void]$sb.Append('</rr-list></request>')
    if (-not $counter) {
        Write-Error "No valid records can be added" -ErrorAction Stop
    }
    $requestParams = @{
        Uri = "https://api.nic.ru/dns-master/services/$Service/zones/$(Get-Punycode $ZoneName)/records"
        Headers = $Headers
        ContentType = "application/json; charset=utf-8"
        Method = 'PUT'
        Body = $sb.ToString()
    }
    Write-Verbose $requestParams.Uri
    $r = Invoke-RestMethod @requestParams @GMNicRuProxySettings
    if ($r -and $r.response) {
        if ($r.response.status -eq 'success') {
            $r.response.data.zone.rr
        }
        else {
            Write-Error $r.response.errors
        }
    }
}
