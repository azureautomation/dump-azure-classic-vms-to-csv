param(
    [string]$tenantId="", 
    [string]$file="Azure-Classic-VMs.csv"
) 

if ($tenantId -eq "") {
    Write-Host "No tenant specified."
    Add-AzureAccount
} else {
    add-azureaccount -Tenant $tenantId
}

$subs = Get-AzureSubscription 
$vmobjs = @()

foreach ($sub in $subs | where-object { ($_.TenantId -eq $tenantId) -or ($tenantId -eq "") } )
{
    Write-Host Processing subscription $sub.SubscriptionName

    try
    {
        Select-AzureSubscription -SubscriptionId $sub.SubscriptionId -ErrorAction Continue
    
        $vms = Get-AzureVm
        $svcs = Get-AzureService

        foreach ($vm in $vms)
        {
            $service = $svcs | where-object { $_.ServiceName -eq $vm.ServiceName }

            $vmInfo = [pscustomobject]@{
                'Subscription'=$sub.SubscriptionName
                'Mode'='Classic'
                'Name'=$vm.Name
                'ServiceName' = $vm.ServiceName
                'Location' = $service.Location
                'VMSize' = $vm.InstanceSize
                'Status' = $vm.Status
                'AvailabilitySet' = $vm.AvailabilitySetName}
        
            $vmobjs += $vmInfo

        }  
    }
    catch
    {
        Write-Host $error[0]
    }
}


$vmobjs | Export-Csv -Path $file
Write-Host "VM list written to $file"