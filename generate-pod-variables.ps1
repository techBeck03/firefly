[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$csv,
    [Parameter(Mandatory=$True,Position=1)]
    [int]$count
)

$appJson = @"
[
    {
        tier: "app",
        count: 3
    },
    {
        tier: "db",
        count: 3
    },
    {
        tier: "haproxy-app",
        count: 1
    },
    {
        tier: "haproxy-db",
        count: 1
    },
    {
        tier: "load-sim",
        count: 1
    }
]
"@
$app = $appJson | ConvertFrom-JSON
$csvDict = @()
(1 .. $count) | % {
    $pod = $_
    $hostCount = 0
    $app | % {
        $tier = $_
        (1 .. $tier.count) | % {
            $hostCount++
            $tierDict = new-object PSObject
            if ($tier.count -gt 1)
            {
                $tierDict | add-member -MemberType NoteProperty -Name "HOSTNAME" -Value "$($tier.tier)-$_-pod-$pod"
            }
            else {
                $tierDict | add-member -MemberType NoteProperty -Name "HOSTNAME" -Value "$($tier.tier)-pod-$pod"
            }
            $tierDict | add-member -MemberType NoteProperty -Name "IP" -Value "192.168.$(110 + $pod).$(200 + $hostCount)"
            $tierDict | add-member -MemberType NoteProperty -Name "POD" -Value $pod
            $tierDict | add-member -MemberType NoteProperty -Name "APP_TIER" -Value "$($tier.tier)"
            $csvDict += $tierDict
        }
    }
    $variableFile = "pod_$($pod)_variables.sh"
    "#!/bin/sh" | Out-File -Encoding "ASCII" $variableFile
    $target = $csvDict | where {$_.POD -eq $pod -and $_.APP_TIER -eq "haproxy-app" }
    "HAPROXY_APP_IP=`"$($target.IP)`"" | Add-Content  $variableFile
    $target = $csvDict | where {$_.POD -eq $pod -and $_.APP_TIER -eq "haproxy-db" }
    "HAPROXY_DB_IP=`"$($target.IP)`"" | Add-Content $variableFile
    $target = $csvDict | where {$_.POD -eq $pod -and $_.APP_TIER -eq "app" }
    $appNames = ""
    $appIPs = ""
    $target | % {
        $appNames += "$($_.HOSTNAME),"
        $appIPs += "$($_.IP),"
    }
    "APP_TIER_IPS=`"$($appIPs.Trim(','))`"" | Add-Content $variableFile
    "APP_TIER_HOSTNAMES=`"$($appNames.Trim(','))`"" | Add-Content $variableFile
    "APP_PORT=`"8081`"" | Add-Content $variableFile
    $target = $csvDict | where {$_.POD -eq $pod -and $_.APP_TIER -eq "db" }
    $dbNames = ""
    $dbIPs = ""
    $target | % {
        $dbNames += "$($_.HOSTNAME),"
        $dbIPs += "$($_.IP),"
    }
    "DB_TIER_IPS=`"$($dbIPs.Trim(','))`"" | Add-Content $variableFile
    "DB_TIER_HOSTNAMES=`"$($dbNames.Trim(','))`"" | Add-Content $variableFile
    "GALERA_DB_USER=`"siwapp`"" | Add-Content $variableFile
    "GALERA_DB_USER_PWD=`"siwapp`"" | Add-Content $variableFile
    "GALERA_DB_ROOT_PWD=`"siwapp`"" | Add-Content $variableFile
    "GALERA_CLUSTER_NAME=`"siwapp`"" | Add-Content $variableFile
}
$csvDict | Export-Csv -NoTypeInformation $csv
