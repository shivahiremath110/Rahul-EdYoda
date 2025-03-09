parm {
    name: $name
    location; $name
}

New-AzResourceGroup -Name $name -Location $name

New-AzVm -ResourceGroupName "myResourceGroupVM" -Name "$name" -Location "EastUS" -VirtualNetworkName "myVnet" -SubnetName "mySubnet" -SecurityGroupName "myNetworkSecurityGroup" -PublicIpAddressName "myPublicIpAddress" -Credential $cred