param(
    [ValidateSet("appliance", "vm", "disk", "summary", "host")]
    [string]$op = "appliance",
    $clusterName = "Strider-CICD",
    $vms = $null,
    [switch]
    $raw
)
#$vms = get-vm -location $clusterName
if (!$vms) {
    $vms = Get-Cluster $clusterName | Get-VM
} else {
    $vms = Get-VM $vms
}

$diskinfo = $vms | ForEach-Object {
    $vm = $_
    # get the owner from notes if we can find it.
    if ($vm.notes -match "DeployFor: (\w+)") { $Owner = $matches[1] } else { $Owner = "" }

    # we have run into the case where 2 vms with the same name are in the same cluster but different
    # folders - we need to differentiate them.
    $VMName = $vm.Name
    if (($vms | Where-Object Name -eq $vm.name).count -gt 1) { $VMName = $vm.Name+"/"+$vm.Folder }

    #write-host -fore cyan $_.name
    $vm | Get-HardDisk | ForEach-Object {
        [PSCustomObject]@{
            VMName = $vmName
            #Folder = $vm.Folder
            DiskName = $_.Name
            #PowerState = $vm.PowerState
            Datastore = $_.FileName.Split(']')[0].TrimStart('[')
            Capacity = [math]::Round($_.CapacityGB, 2)
            StorageFormat = $_.StorageFormat
            CreateDate = $vm.CreateDate
            Owner = $Owner
        }
    }
} 

$vminfo = $diskinfo | Group-Object VMName, Folder, Datastore | ForEach-Object {
    $vmDatastoreDisks = $_.Group
    $firstStorageFormat = $vmDatastoreDisks[0].StorageFormat
    $storageFormats = $vmDatastoreDisks | Select-Object -ExpandProperty StorageFormat -Unique

    [PSCustomObject]@{
        VMName = $vmDatastoreDisks[0].VMName
        Datastore = $vmDatastoreDisks[0].Datastore
        Capacity = [math]::Round(($vmDatastoreDisks | Measure-Object -Property Capacity -Sum).Sum, 2)
        StorageFormat = if ($storageFormats.Count -gt 1) { "$firstStorageFormat*" } else { $firstStorageFormat }
        CreateDate = $_.CreateDate
        Owner = $vmDatastoreDisks[0].Owner
    }
}

$applianceinfo = $diskinfo | ForEach-Object {
    $applianceName = if ($_.VMName -match '^(.*)-\d{2}$') { $Matches[1] } else { $_.VMName }

    [PSCustomObject]@{
        ApplianceName = $applianceName
        VMName = $_.VMName
        Capacity = $_.Capacity
        Datastore = $_.Datastore
        StorageFormat = $_.StorageFormat
        CreateDate = $_.CreateDate
        Owner = $_.Owner
    }
} | Group-Object ApplianceName | ForEach-Object {
    $applianceDatastoreDisks = $_.Group
    $firstStorageFormat = $applianceDatastoreDisks[0].StorageFormat
    $storageFormats = $applianceDatastoreDisks | Select-Object -ExpandProperty StorageFormat -Unique
    $datastorelist = $applianceDatastoreDisks.Datastore 
    $firstDatastore = $applianceDatastoreDisks[0].Datastore
    $Owner = $applianceDatastoreDisks[0].Owner

    [PSCustomObject]@{
        ApplianceName = $applianceDatastoreDisks[0].ApplianceName
        Capacity = [math]::Round(($applianceDatastoreDisks | Measure-Object -Property Capacity -Sum).Sum, 2)
        VMCount = ($applianceDatastoreDisks | Select-Object -ExpandProperty VMName -Unique).Count
        Datastore = if ($datastorelist.Count -gt 1) { "$firstDatastore*" } else { $firstDatastore }
        StorageFormat = if ($storageFormats.Count -gt 1) { "$firstStorageFormat*" } else { $firstStorageFormat }
        CreateDate = $applianceDatastoreDisks[0].CreateDate
        Owner = $Owner
    }
}

function get-hostinfo()
{
    foreach ($vm in (Get-Vmhost -Location $clusterName))
    {
        $cpuTotal = $vm.CpuTotalMhz
        $cpuUsage = $vm.CpuUsageMhz
        $MemoryTotal = $vm.MemoryTotalGB
        $MemoryUsage = $vm.MemoryUsageGB
        $MemoryFree = $MemoryTotal - $MemoryUsage
        $cpuFree = $cpuTotal - $cpuUsage

        [PSCustomObject]@{
          VMHost = $vm.name
          CpuTotal = $cpuTotal
          cpuFree = $cpuFree
          CpuUsedPct = [string][int](($cpuTotal - $cpuUsage) / $cpuTotal * 100) + "%"
          MemoryTotal = [int]$MemoryTotal
          MemoryFree = [int]$MemoryFree
          MemoryUsedPct = [string][int](($MemoryTotal - $MemoryUsage) / $MemoryTotal * 100) + "%"
        }
    }

}

switch ($op) {
    "appliance" {
        if ($raw) { $applianceinfo } 
        else 
        { $applianceinfo | Sort-Object Capacity, Datastore, ApplianceName | Format-Table -AutoSize }
    }
    "vm" {
        if ($raw) { $vminfo } 
        else 
        { $vminfo | Sort-Object Capacity, Datastore, VMName | Format-Table -AutoSize }
    }
    "disk" {
        if ($raw) { $diskinfo } 
        else 
        { $diskinfo | Sort-Object Datastore, VMName, DiskName | Format-Table -AutoSize }
    }
    "summary" {
        # datastores stores in the cluster
        Get-Datastore -Location (Get-DatastoreCluster "ps-Shared-$clustername")
    }
    "host" {
        get-hostinfo
    }
}


# datastore clusters
#Get-DatastoreCluster
