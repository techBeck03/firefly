[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True,Position=1)]
	[string]$vc,
	[Parameter(Mandatory=$True)]
	[string]$user,
	[Parameter(Mandatory=$True)]
    [string]$password,
    [Parameter(Mandatory=$True)]
    [string]$rootPassword,
    [Parameter(Mandatory=$False)]
    [switch]$replaceSnapShot
)

# Connect to vCenter
Connect-VIServer $vc -User $user -Password $password

Get-VM | % {
    $vm = $_
    $output = (Invoke-VMScript -Vm $vm -ScriptText "sed -i 's/enforcing/permissive/g' /etc/selinux/config /etc/selinux/config" -GuestUser "root" -GuestPassword $rootPassword -ErrorAction Stop -ScriptType bash).ScriptOutput
    $vm | Shutdown-VMGuest -Confirm:$False
}
Disconnect-VIServer -Confirm:$False