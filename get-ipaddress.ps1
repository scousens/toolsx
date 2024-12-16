param(
[Parameter(mandatory=$true)]
$vmname,
$cluster
)
if ($cluster) { $location = Get-Cluster $cluster }
Get-VM $vmname -location $location | %{ 
    $network = $_ | Get-NetworkAdapter
    if (!$location) { $cluster = $_ | Get-Cluster } else { $cluster = $location }
    if ($_.guest.ipaddress) {
        $ip = $_.guest.ipaddress[0]
    } else {
        $ip = ""
    }
    [pscustomobject]@{
	"name"=$_.name
	"ipaddress"=$ip
	"network"=$network.NetworkName
	"cluster"=$cluster.name
	"host"=$_.vmhost
}}
