[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True,Position=1)]
	[string]$vc,
	[Parameter(Mandatory=$True)]
	[string]$user,
	[Parameter(Mandatory=$True)]
    [string]$password,
    [Parameter(Mandatory=$True)]
    [string]$csv,
    [Parameter(Mandatory=$True)]
    [string]$rootPassword,
    [Parameter(Mandatory=$True)]
    [string]$pod,
    [Parameter(Mandatory=$False)]
    [switch]$async
)

# Example Usage for pod 1 (passwords are changed)
# copy deploy-siwapp.ps1 and pod_assignments.csv to jumphost
# .\deploy-siwapp.ps1 -vc 192.168.11.113 -user Student1\administrator -pwd vcPassword -csv .\pod_assignments.csv -rootPassword vmRootPassword -pod 1

# Global Variables
$FILE_SERVER = "https://raw.githubusercontent.com/techBeck03/firefly/master"
$APP_TIERS = @{}
$APP_TIERS."HAPROXY-APP" = "siwapp-haproxy-app.sh"
$APP_TIERS."APP" = "siwapp-app.sh"
$APP_TIERS."HAPROXY-DB" = "siwapp-haproxy-db.sh"
$APP_TIERS."DB" = "siwapp-db.sh"
$APP_TIERS."LOAD-SIM" = "siwapp-load-sim.sh"

# Connect to vCenter
Connect-VIServer $vc -User $user -Password $password

# Get entries for specified pod from assignments csv
Import-Csv $csv | where {$_.POD -eq $pod} | % {
    $target = $_
    Write-Host "Starting deployment for $($target."HOSTNAME")"
    $deployScript = $APP_TIERS[$target."APP_TIER".ToLower()]
    Write-Host "Deploy script = $deployScript"
    Try
    {
        Write-Host "Finding VM: $($target."HOSTNAME")"
        $vm = Get-VM -Name $target."HOSTNAME"
        Write-Host "Found VM named $vm"
        if ($async)
        {
            $output = (Invoke-VMScript -Vm $vm -ScriptText "export FILE_SERVER=$FILE_SERVER;export POD=$($target."POD");curl -o /tmp/$deployScript ${FILE_SERVER}/$deployScript;/usr/bin/bash /tmp/$deployScript" -GuestUser "root" -GuestPassword $rootPassword -ErrorAction Stop -ScriptType bash -RunAsync).ScriptOutput
        }
        else
        {
            Invoke-VMScript -Vm $vm -ScriptText "export FILE_SERVER=$FILE_SERVER;export POD=$($target."POD");curl -o /tmp/$deployScript ${FILE_SERVER}/$deployScript;/usr/bin/bash /tmp/$deployScript" -GuestUser "root" -GuestPassword $rootPassword -ErrorAction Stop -ScriptType bash
        }
        Write-Host "Deployment complete for $($target."HOSTNAME")"
    }
    Catch
    {
        Write-Host "Caught Exception while configuring: $($target."HOSTNAME")"
    }
}
Disconnect-VIServer -Confirm:$False