<#
    MIT License

    Copyright (c) 2017 Oliver Lohmann

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>

<#
    .SYNOPSIS  
        Create a managed image from a given VHD OSDisk and optionally multiple data disks.
    .EXAMPLE  
        .\Create-AzureRmManagedImageFromVhd.ps1 -Location 'WestEurope' -ResourceGroupName 'my-rg' -ImageUri 'https://....blob.core.windows.net/images/myOsDiskImg.vhd' -OsType 'Windows' -ImageName 'MyImage'
#>

Param(
    [Parameter(Mandatory = $true, HelpMessage = "The destination location for the import.")]
    [string]$Location,
    
    [Parameter(Mandatory = $true, HelpMessage = "The destination resource group name for the import (will be created if not exists).")]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true, HelpMessage = "The URI to the source VHD image (requires storage account location in the same subscription).")]
    [string]$ImageUri,

    [Parameter(Mandatory = $false, HelpMessage = "The URIs to the source data Disk Images (requires storage account location in the same subscription).")]
    [string[]]$DataDiskUris,
    
    [Parameter(Mandatory = $true, HelpMessage = "The OS Type of the source image.")]
    [ValidateSet("Linux", "Windows")]
    [string]$OsType,

    [Parameter(Mandatory = $true, HelpMessage = "The name of the managed image in the destination resource group.")]
    [string]$ImageName
)

# Create the managed image which will source new VMs in this subscription
$imageConfig = New-AzureRmImageConfig -Location $Location 
$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType $OsType -OsState Generalized -BlobUri $ImageUri
$i = 0
foreach ($dataDiskUri in $DataDiskUris) {
    $imageConfig = Add-AzureRmImageDataDisk -Image $imageConfig -Lun $i -BlobUri $dataDiskUri 
    $i++
}

$image = New-AzureRmImage -ImageName $ImageName -ResourceGroupName $ResourceGroupName -Image $imageConfig 

Write-Host "Created new managed disk image: $($image.Id)"