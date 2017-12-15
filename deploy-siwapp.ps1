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
    [string]$rootPassword
)

# Global Variables
$FILE_SERVER = "https://something.com"
$APP_TIERS = @{}
$APP_TIERS."HAPROXY_APP" = "siwapp-haproxy-app.sh"
$APP_TIERS."APP" = "siwapp-app.sh"
$APP_TIERS."HAPROXY_DB" = "siwapp-haproxy-db.sh"
$APP_TIERS."DB" = "siwapp-db.sh"
$APP_TIERS."LOAD_SIM" = "siwapp-load-sim.sh"

Import-Csv $csv | % {
    $target = $_
    $deployScript = $APPTIERS[$target."APP_TIER".ToUpper()]
    Try
    {
        $output = (Invoke-VMScript -Vm $target["VMNAME"] -ScriptText "export FILE_SERVER=$FILE_SERVER;export POD=$($target["POD"]);curl -o /tmp/$deployScript ${FILE_SERVER}/$deployScript" -GuestUser "root" -GuestPassword $rootPassword -ErrorAction Stop).ScriptOutput
    }
    Catch
    {
        Write-Host "Caught Exception"			
    }
}