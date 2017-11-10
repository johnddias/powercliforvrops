#These examples are intended to be used in sequence - ideally within ISE
#Learn more in this blog series
#https://blogs.vmware.com/PowerCLI/2016/05/getting-started-with-powercli-for-vrealize-operations-vr-ops.html

# Connecting
$server = "10.140.46.11"
$vrops = Connect-OMServer -Server $server -User demouser -Password demoVMware1!

# Alerts
Get-OMAlert -Status Active -Criticality Critical -Impact Health -Subtype Performance
# When querying alerts, you may want the alert type parameter options
Get-OMAlertType
Get-OMAlertDefinition -Type 'Virtualization/Hypervisor Alerts' -SubType Compliance | Select name,id
Get-OMAlert -Name 'ESXi Host is violating VMware vSphere Hardening Guide' -Status Active

$alert = Get-OMAlert -Resource VIN-demo -Impact Health -Status Active
$alert | fl
$alert = Set-OMAlert $alert -TakeOwnership -Confirm
$alert = Set-OMAlert $alert -SuspendMinutes 60
$alert | fl

# Get the alert recommendations
Get-OMRecommendation -Alert $alert | fl

# Get Resource associated with the alert so you can apply recommendations
$vmresource = $alert.resource
$vmresource.ExtensionData.GetResourceProperties().property | Where name -like '*parent*'
Connect-VIServer -server msbu-vc-demo.mgmt.local
$vm = get-vm $vmresource
$vm | fl
$vm | Get-Snapshot | Remove-Snapshot

# Adding a resource property
# This is a good example of using ExtensionData to access the full API
# You can drill into this ExtensionData for more info
(Get-OMResource SLES11002).ExtensionData
(Get-OMResource SLES11002).ExtensionData.Badges

#Let's see how to access the full API, using the methods available in the vROps connection object
$global:DefaultOMServers[0] | fl
$vrops = $global:DefaultOMServers[0]
$vrops.extensionData | gm

# Specifically, you need methods related to resources for the property addition (see also API docs)
($vrops.extensionData.getResources())[0].resource | gm

# Grab a resource to work with
$resource = Get-OMResource SLES11002
$resource | fl
$resource.ExtensionData | gm
$resource.ExtensionData.GetResourceProperties().property
$resource.ExtensionData.addproperties

# The overload definitions show what is expected for the request payload
# In this case, PropertyContents need to be provided

# Building the property payload
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

# Adding the property and validating
$resource.ExtensionData.getresourceproperties().property
$resource.ExtensionData.AddProperties($contentprops)
# Might have to wait up to 5 minutes to see the added property
$resource.ExtensionData.getresourceproperties().property

# Updating the property (note the use of time stamp)
$contentprop.StatKey = "custom|testproperty"
$contentprop.Values = @("UPDATED by PowerCLI!")
$contentprop.Timestamps = [double]::Parse((Get-Date -UFormat %s))

$resource.ExtensionData.getresourceproperties().property
$resource.ExtensionData.AddProperties($contentprops)
$resource.ExtensionData.getresourceproperties().property
