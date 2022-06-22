$MachineName = '$(vmName)'
$RGName = '$(resourceGroup)'
$storageAccName = '$(storageAccountName)'
$location = '$(rglocation)'

Write-Host "Step1"
$StorageAccount = Get-AzStorageAccount -Name $storageAccName -ResourceGroupName $RGName

$Context = $StorageAccount.Context
$Container = Get-AzStorageContainer -Context $Context

Write-Host "Step2"
# Retrieve storage account key
$StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $RGName -Name $storageAccName).Value[0]

# Retrieve storage blob endpoint
$ScriptBlobUrl = $StorageAccount.Context.BlobEndPoint
$containerName = $Container.Name

Write-Host "Step3"
$blobs = Get-AzStorageBlob -Container $containerName -Context $Context

$ScriptLocation = $ScriptBlobUrl + "$containerName/" + $blobs.Name
$CommandToExecute = "sh $($blobs.Name)"

Write-Host "Step4"
$Extensions = Get-AzVMExtensionImage -Location $location -PublisherName "Microsoft.Azure.Extensions" -Type "CustomScript"
$ExtensionVersion = $Extensions[0].Version[0..2] -join ""
$ScriptSettings = @{"fileUris" = @("$ScriptLocation")};
$ProtectedSettings = @{"storageAccountName" = $storageAccName; "storageAccountKey" = $StorageAccountKey; "commandToExecute" = $CommandToExecute};

Write-Host "Step5"
Set-AzVMExtension -ResourceGroupName $RGName -Location $location -VMName $MachineName -Name $Extensions[0].Type -Publisher $Extensions[0].PublisherName -ExtensionType $Extensions[0].Type -TypeHandlerVersion $ExtensionVersion -Settings $ScriptSettings -ProtectedSettings $ProtectedSettings