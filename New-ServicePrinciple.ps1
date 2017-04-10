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
        Create a new Service Principle via MSOL. 
        Should be followed by an ARM role assignment: 
        New-AzureRmRoleAssignment -ObjectId $principle.ObjectId -Scope '/subscriptions/$subscriptionId' -RoleDefinitionName 'Contributor'
    .EXAMPLE  
        .\New-ServicePrinciple.ps1 -TenantId 'a258...-...' -ServicePrincipalDisplayName 'Automation-SP'
#>

Param(
    [Parameter(Mandatory = $true, HelpMessage = "The TenantId of the Service Principle.")]
    [string]$TenantId,
    
    [Parameter(Mandatory = $true, HelpMessage = "The display name for the Service Principle.")]
    [string]$ServicePrincipalDisplayName
)

try {
    $domains = Get-MsolDomain -ErrorAction Stop
} catch {
    Write-Error "Login via Connect-MsolService first."
    break
}

# New Unique Service Principle Name
$servicePrincipalName = [guid]::NewGuid().ToString() 

# Auto-Generated Password
$password = [guid]::NewGuid().ToString()

# Create the principle (note: Addresses etc. are NOT required. A pure automation SP.)
$principle =  New-MsolServicePrincipal -TenantId $TenantId -ServicePrincipalNames $servicePrincipalName -DisplayName $ServicePrincipalDisplayName -Type password -Value $password

# Output
$output = New-Object -TypeName PSObject
$output | Add-Member -MemberType NoteProperty -Name ServicePrincipleName -Value $servicePrincipalName
$output | Add-Member -MemberType NoteProperty -Name ServicePrincipleDisplayName -Value $servicePrincipalDisplayName
$output | Add-Member -MemberType NoteProperty -Name ObjectId -Value $principle.ObjectId
$output | Add-Member -MemberType NoteProperty -Name AppPrincipalId -Value $principle.AppPrincipalId
$output | Add-Member -MemberType NoteProperty -Name TenantId -Value $tenantId
$output | Add-Member -MemberType NoteProperty -Name ARM_TENANT_ID -Value $tenantId
$output | Add-Member -MemberType NoteProperty -Name ARM_CLIENT_ID -Value $principle.AppPrincipalId
$output | Add-Member -MemberType NoteProperty -Name ARM_CLIENT_SECRET_ID -Value $password

return $output