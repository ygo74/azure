class NetworkRule
{
    [ValidateNotNullOrEmpty()]    
    [String] $Name

    [ValidateSet("Tcp","Udp")]    
    [String] $Protocol ="Tcp"

    [ValidateSet("Inbound","Outbound")]    
    [String] $Direction="Inbound"

    [String] $Description=""

    [Int] $Priority=1000

    [String] $SourceAddressPrefix="*"
    [String] $SourcePortRange="*"
    [String] $DestinationAddressPrefix="*"
    [String] $DestinationPortRange="*"

    [ValidateSet("Allow","Reject")]    
    [String] $Access="Allow"

}

function Get-NetworkRuleDefinition
{
    param(
        [System.Collections.Hashtable] $property
    )

    return New-Object -TypeName NetworkRule -Property $property

}