Connect-OMServer -Server {{IP}} -User admin 
Get-OMAlert -Status Active -Criticality Critical -Impact Health
Get-OMAlertType
Get-OMAlertDefinition -Type 'Network Alerts' -SubType configuration
Get-OMAlert -Name 'Less than three*' | format-list
Get-OMAlertDefinition -resourcekind 'VirtualMachine'
$alert = Get-OMAlert -Resource bwhanaapp3 -Impact Health -Status Active
$alert | fl
$alert = Set-OMAlert $alert -TakeOwnership -Confirm
$alert = Set-OMAlert $alert -SuspendMinutes 60
$alert | fl

Get-OMRecommendation -Alert $alert | fl
$vmresource = $alert.resource
$vmresource.ExtensionData.GetResourceProperties().property | Wherer name -like '*parent*'
Connect-VIServer -server msbu-vc-east
$vm = get-vm $vmresource
$vm | fl

(Get-OMResource SLES11002).ExtensionData
(Get-OMResource SLES11002).ExtensionData.badges
$global:DefaultOMServers[0] | fl
$vrops = $global:DefaultOMServers[0]
$vrops.extensionData | gm
($vrops.extensionData.getResources())[0].resource | gm
$resource = Get-OMResource SLES11002
$resource | fl
$resource.ExtensionData | gm
$resource.ExtensionData.addproperties

$contentprops = New-Object VMware.VimAutomation.VROps.Views.PropertyContents
$contentprops | gm
$contentprop = New-Object VMware.VimAutomation.VROps.Views.PropertyContent
$contentprop | gm

$contentprop.StatKey = "custom|testproperty"
$contentprop.Values = @("Created by PowerCLI!")
$contentprop.Timestamps = [double]::Parse((Get-Date -UFormat %s))
$contentprop | fl

$contentprops.Propertycontent = @($contentprop)
$contentprops | fl

$resource.ExtensionData.getresourceproperties().property
$resource.ExtensionData.AddProperties($contentprops)
$resource.ExtensionData.getresourceproperties().property

$contentprop.StatKey = "custom|testproperty"
$contentprop.Values = @("UPDATED by PowerCLI!")
$contentprop.Timestamps = [double]::Parse((Get-Date -UFormat %s))

$resource.ExtensionData.getresourceproperties().property
$resource.ExtensionData.AddProperties($contentprops)
$resource.ExtensionData.getresourceproperties().property
