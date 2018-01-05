[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True,Position=1)]
	[string]$vc,
	[Parameter(Mandatory=$True)]
	[string]$user,
	[Parameter(Mandatory=$True)]
    [string]$password,
    [Parameter(Mandatory=$True)]
    [string]$rootPassword
)

# Example Usage for pod 1 (passwords are changed)
# copy disable-selinux.ps1 to jumphost
# .\disable-selinux.ps1 -vc 192.168.11.113 -user Student1\administrator -pwd vcPassword -rootPassword vmRootPassword

# Connect to vCenter
Connect-VIServer $vc -User $user -Password $password

Get-VM | % {
    $vm = $_
    $output = (Invoke-VMScript -Vm $vm -ScriptText "sed -i 's/enforcing/permissive/g' /etc/selinux/config /etc/selinux/config" -GuestUser "root" -GuestPassword $rootPassword -ErrorAction Stop -ScriptType bash).ScriptOutput
    $vm | Shutdown-VMGuest -Confirm:$False
}
Disconnect-VIServer -Confirm:$False

<# Creating Snapshots for all VMs with powercli
Connect-VIServer
$vms = Get-VM
$vms | Get-Snapshot | Remove-Snapshot -confirm:$false
$vms | New-Snapshot -Name "Lab Restore Point"
#>