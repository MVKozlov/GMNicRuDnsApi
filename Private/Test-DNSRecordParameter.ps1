function Test-DNSRecordParameter($parameter) {
    if ($parameter.type -eq 'CNAME' -and $parameter.alias ) {
        $parameter.name = $parameter.alias
    }
    elseif ($parameter.type -eq 'SRV' -and $parameter.'service-proto' ) {
        $parameter.name = $parameter.'service-proto'
    }
    if (-not $parameter.type -or -not $parameter.name) {
        Write-Error "'type' and 'name' is mandatory parameters for record" -Category InvalidArgument, InvalidData -TargetObject $parameter
        return $false
    }
    elseif (-not $GMNicRuZRParams.ContainsKey($parameter.type)) {
        Write-Error "Unsupported record type: $($parameter.type)" -Category InvalidArgument, InvalidData -TargetObject $parameter
        return $false
    }
    $parameter.type = $parameter.type.ToUpper()
    $validKeys = $GMNicRuZRParams[$parameter.type]
    if ($parameter.Keys -is [System.Collections.IEnumerable] -or
        $parameter.Keys -is [System.Collections.Generic.IEnumerable[string]]) {
        $curKeys = [string[]]$parameter.Keys
    }
    else {
        $curKeys = [string[]]((Get-Member -InputObject $parameter -MemberType NoteProperty).Name)
    }
    $mandatoryKeySet = New-Object 'System.Collections.Generic.HashSet[string]' @($curKeys, [System.StringComparer]::OrdinalIgnoreCase)
    $extraKeySet = New-Object 'System.Collections.Generic.HashSet[string]' @($curKeys, [System.StringComparer]::OrdinalIgnoreCase)
    $mandatoryKeySet.IntersectWith([string[]]$validKeys.mandatory)
    if ($mandatoryKeySet.Count -ne $validKeys.mandatory.Count) {
        Write-Error "Mandatory parameters for record type: $($parameter.type) expected: $($validKeys.mandatory -join ', ')" -Category InvalidArgument, InvalidData -TargetObject $parameter
        return $false
    }
    [string[]]$fullSet = [string[]]$validKeys.mandatory + $validKeys.optional + 'name' + 'type'
    $extraKeySet.ExceptWith($fullSet)
    if ($extraKeySet.Count) {
        Write-Warning "Unsupported properties used for $($parameter.type): $($extraKeySet -join ', ')"
    }
    $mandatoryKeySet = New-Object 'System.Collections.Generic.HashSet[string]' @($curKeys, [System.StringComparer]::OrdinalIgnoreCase)
    $mandatoryKeySet.ExceptWith($extraKeySet)
    Write-Verbose "Defined properties for $($parameter.type): $($mandatoryKeySet -join ', ')"
    $true
}
