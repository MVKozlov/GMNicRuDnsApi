$GMNicRuProxySettings = @{
}
$GMNicRuDefaultToken = [PSCustomObject]@{
    refresh_token = ""
    expires_in    = 14400
    access_token  = ""
    token_type    = "Bearer"
}
$GMNicRuIdn = New-Object System.Globalization.IdnMapping

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
