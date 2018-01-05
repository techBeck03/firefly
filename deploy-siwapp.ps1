[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True,Position=1)]
	[string]$vc,
	[Parameter(Mandatory=$True)]
	[string]$user,
	[Parameter(Mandatory=$True)]
    [string]$pwd,
    [Parameter(Mandatory=$True)]
    [string]$csv,
    [Parameter(Mandatory=$True)]
    [string]$rootPassword,
    [Parameter(Mandatory=$True)]
    [string]$pod
)

# Global Variables
$FILE_SERVER = "https://raw.githubusercontent.com/techBeck03/firefly/master"
$APP_TIERS = @{}
$APP_TIERS."HAPROXY-APP" = "siwapp-haproxy-app.sh"
$APP_TIERS."APP" = "siwapp-app.sh"
$APP_TIERS."HAPROXY-DB" = "siwapp-haproxy-db.sh"
$APP_TIERS."DB" = "siwapp-db.sh"
$APP_TIERS."LOAD-SIM" = "siwapp-load-sim.sh"

Import-Csv $csv | where {$_.POD -eq $pod} | % {
    $target = $_
    
    $deployScript = $APP_TIERS[$target."APP_TIER".ToLower()]
    Try
    {
        $output = (Invoke-VMScript -Vm $target["VMNAME"] -ScriptText "export FILE_SERVER=$FILE_SERVER;export POD=$($target["POD"]);curl -o /tmp/$deployScript ${FILE_SERVER}/$deployScript" -GuestUser "root" -GuestPassword $rootPassword -ErrorAction Stop).ScriptOutput
    }
    Catch
    {
        Write-Host "Caught Exception"			
    }
}