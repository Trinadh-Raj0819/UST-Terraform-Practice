terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "existing_rg" {
   name = "example-resources1"
}

# Data source for existing NIC
data "azurerm_network_interface" "existing_nic" {
  name                = "example-nic"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}


# Create the VM using the specific existing resources
resource "azurerm_linux_virtual_machine" "example" {
  name                = "myVM"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"

  network_interface_ids = [
    data.azurerm_network_interface.existing_nic.id,  # Use the existing NIC
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    
  }

 source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"  # Corrected offer name
    sku       = "server"
    version   = "latest"
  }
}
