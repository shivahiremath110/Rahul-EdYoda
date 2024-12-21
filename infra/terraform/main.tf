provider "azurerm" { 
  features {}
  tenant_id       = var.tenant_id 
  subscription_id = var.subscription_id 
  client_id       = var.client_id 
  client_secret   = var.client_secret
} 

 
#------------------------------------------------------------------------# 
#************Terraform script to create resource groups******************# 
#------------------------------------------------------------------------# 

 
 resource "azurerm_resource_group" "rg" { 

        name           = "terraform-demo-rg"
        location       = "eastus"
} 


#------------------------------------------------------------------------# 
#************Terraform script to virtual network & subnet****************# 
#------------------------------------------------------------------------# 

resource "azurerm_virtual_network" "vnet" {
  name                = "Demo-virtual-network"
  location            = azurerm_resource_group.rg.location
  #location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "Demo-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = [ "Microsoft.Storage"]
}

resource "azurerm_network_interface" "main" {
  name                = "demo-network-interface-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "demo-tf-auto-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}