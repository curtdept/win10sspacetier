#Variables
$StoragePoolName = "Pool"
$TieredSpaceName = "Tiered_Space"
$ResiliencySetting = "Simple"
$SSDTierName = "SSDTier"
$HDDTierName = "HDDTier"

#List all disks that can be pooled and output in table format (format-table)
Get-PhysicalDisk -CanPool $True | ft FriendlyName,OperationalStatus,Size,MediaType

#Store all physical disks that can be pooled into a variable, $PhysicalDisks
$PhysicalDisks = (Get-PhysicalDisk -CanPool $True | Where MediaType -NE UnSpecified | Where FriendlyName -NE "Samsung SSD 970 EVO 500GB")       

#Create a new Storage Pool using the disks in variable $PhysicalDisks with a name of My Storage Pool
$SubSysName = (Get-StorageSubSystem).FriendlyName
New-StoragePool -PhysicalDisks $PhysicalDisks -StorageSubSystemFriendlyName $SubSysName -FriendlyName $StoragePoolName

#View the disks in the Storage Pool just created
Get-StoragePool -FriendlyName $StoragePoolName | Get-PhysicalDisk | Select FriendlyName, MediaType

#Create two tiers in the Storage Pool created. One for SSD disks and one for HDD disks
$SSDTier = New-StorageTier -StoragePoolFriendlyName $StoragePoolName -FriendlyName $SSDTierName -MediaType SSD
$HDDTier = New-StorageTier -StoragePoolFriendlyName $StoragePoolName -FriendlyName $HDDTierName -MediaType HDD

#Identify tier sizes within this storage pool
#$SSDTierSizes = Get-StorageTierSupportedSize $SSDTierName -ResiliencySettingName Simple | select -ExpandProperty TierSizeMax
#$HDDTierSizes = Get-StorageTierSupportedSize $HDDTierName -ResiliencySettingName Simple | select -ExpandProperty TierSizeMax
#$SSDTiersize -= 50GB
#$HDDTiersize -= 200GB

#Create a new virtual disk in the pool with a name of TieredSpace using the SSD and HDD tiers
#New-VirtualDisk -StoragePoolFriendlyName $StoragePoolName -FriendlyName $TieredSpaceName -StorageTiers $SSDTier, $HDDTier -UseMaximum  -ResiliencySettingName $ResiliencySetting  -AutoWriteCacheSize -AutoNumberOfColumns

New-VirtualDisk -StoragePoolFriendlyName $StoragePoolName -FriendlyName $TieredSpaceName -StorageTiers @($SSDTier,$HDDTier) -StorageTierSizes @(220GB,3.6TB) -ResiliencySettingName $ResiliencySetting -WriteCacheSize 10GB -AutoNumberOfColumns