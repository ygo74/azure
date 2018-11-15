$virtualNetworks=@(
        @{
            Name="MESF_Network"
            AddressPrefix="10.0.0.0/16"
            Subnets=@(
                @{
                    Name="MESF_Subnet_front"
                    AddressPrefix="10.0.1.0/24"
                },
                @{
                    Name="MESF_Subnet_Services"
                    AddressPrefix="10.0.3.0/24"
                },
                @{
                    Name="MESF_Subnet_back"
                    AddressPrefix="10.0.2.0/24"
                }
                @{
                    Name="MESF_Subnet_admin"
                    AddressPrefix="10.0.4.0/24"
                }
            )
        }
)

Write-Output $virtualNetworks
