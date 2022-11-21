$GMNicRuProxySettings = @{
}
$GMNicRuDefaultToken = [PSCustomObject]@{
    refresh_token = ""
    expires_in    = 14400
    access_token  = ""
    token_type    = "Bearer"
}
$GMNicRuIdn = New-Object System.Globalization.IdnMapping

$GMNicRuZRParams = @{
    'A' = @{
        mandatory = 'ip'
        optional = 'ttl'
    }
    'AAAA' = @{
        mandatory = 'ipv6'
        optional = 'ttl'
    }
    'CNAME' = @{
        mandatory = 'canonical'
        optional = 'ttl', 'alias'
    }
    'NS' = @{
        mandatory = 'ns-name'
        optional = 'ttl'
    }
    'MX' = @{
        mandatory = 'mail-relay', 'priority'
        optional = 'ttl'
    }
    'SOA' = @{
        mandatory = 'ns-name', 'serial', 'refresh', 'retry', 'expire', 'minimum'
        optional = 'ttl', 'mail'
    }
    'SRV' = @{
        mandatory = 'priority', 'weight', 'port'
        optional = 'ttl', 'service-proto', 'target'
    }
    'PTR' = @{
        mandatory = 'host-name'
        optional = 'ttl'
    }
    'TXT' = @{
        mandatory = 'text'
        optional = 'ttl'
    }
    'DNAME' = @{
        mandatory = 'target'
        optional = 'ttl'
    }
    'HINFO' = @{
        mandatory = 'cpu', 'os'
        optional = 'ttl'
    }
    'NAPTR' = @{
        mandatory = 'order', 'preference', 'replacement'
        optional = 'ttl', 'flags', 'service', 'regexp'
    }
    'RP' = @{
        mandatory = @()
        optional = 'ttl', 'mbox-dname', 'txt-dname'
    }
}

#region Load Private Functions
Try {
    Get-ChildItem "$PSScriptRoot\Private\*.ps1" -Exclude *.tests.ps1, *profile.ps1 | ForEach-Object {
        #Write-Verbose $_.FullName
        . $_.FullName
    }
} Catch {
    Write-Warning ("{0}: {1}" -f $Function,$_.Exception.Message)
    Continue
}

#region Load Public Functions
Try {
    Get-ChildItem "$PSScriptRoot\Public\*.ps1" -Exclude *.tests.ps1, *profile.ps1 | ForEach-Object {
        #Write-Verbose $_.FullName
        . $_.FullName
    }
} Catch {
    Write-Warning ("{0}: {1}" -f $Function,$_.Exception.Message)
    Continue
}

<# TODO errors:
<response>
 <status>fail</satus>
 <errors>
 <error code="код">текст ошибки</error>
 </errors>
 <data/>
</response>
#>
