### PROVIDER
terraform {
  backend "remote" {
    organization = "Mactech-44"

    workspaces {
      name = "advanced-terraform-3099246"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "myadvanced-rg" {
  name     = "advanced-resources-rg"
  location = "West Europe"
  tags = {
    environment = "dev"
    auto-delete = "true"
    #delete-after = data.time_offset.delete_after_time.rfc333 # Example: 4 hours from now
  }
}

### NETWORK
resource "azurerm_virtual_network" "linkedin_vnet" {
  name                = "linkedin-vnet"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.myadvanced-rg.name
  address_space       = ["10.127.0.0/16"]

  tags = {
    environment = "dev"
    auto-delete = "true"
  }
}

## SUBNET
resource "azurerm_subnet" "linkedin_subnet_1" {
  name                 = "linkedin_subnet1"
  resource_group_name  = azurerm_resource_group.myadvanced-rg.name
  virtual_network_name = azurerm_virtual_network.linkedin_vnet.name
  address_prefixes     = ["10.127.0.0/20"]

  delegation {
    name = "subnetDelegation"
    service_delegation {
      name = "Microsoft.Network/virtualNetworks"
    }
  }
}

### FIREWALL (NSG)
resource "azurerm_network_security_group" "linkedin_nsg" {
  name                = "linkedin-nsg"
  location            = azurerm_resource_group.myadvanced-rg.location
  resource_group_name = azurerm_resource_group.myadvanced-rg.name

  tags = {
    environment = "dev"
    auto-delete = "true"
  }
}

resource "azurerm_network_security_rule" "allow_icmp_and_tcp" {
  name                        = "allow-icmp-and-tcp"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "8080", "1000-2000", "22"]
  source_address_prefix       = "82.39.6.220/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myadvanced-rg.name
  network_security_group_name = azurerm_network_security_group.linkedin_nsg.name
}

# ### COMPUTE
# ## BASE VARIABLES
# variable "vm_size" {
#   default = "Standard_B1s"
# }

# variable "image_reference" {
#   default = {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }
# }

# ## NGINX PROXY
# resource "azurerm_linux_virtual_machine" "nginx_instance" {
#   name                = "nginx-instance"
#   resource_group_name = azurerm_resource_group.myrg-rg.name
#   location            = azurerm_resource_group.myrg-rg.location
#   size                = var.vm_size

#   admin_username      = "nginxadmin"
#   network_interface_ids = [
#     azurerm_network_interface.nginx_instance_nic.id
#   ]

#   admin_ssh_key {
#     username   = "nginxadmin"
#     public_key = var.ssh_public_key
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = var.image_reference["publisher"]
#     offer     = var.image_reference["offer"]
#     sku       = var.image_reference["sku"]
#     version   = var.image_reference["version"]
#   }

#   tags = {
#     environment = "dev"
#   }
# }

# resource "azurerm_network_interface" "nginx_instance_nic" {
#   name                = "nginx-instance-nic"
#   resource_group_name = azurerm_resource_group.myrg-rg.name
#   location            = azurerm_resource_group.myrg-rg.location

#   ip_configuration {
#     name                          = "nginx-ip-config"
#     subnet_id                     = azurerm_subnet.subnet_1.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.nginx_instance_pip.id
#   }

#   tags = {
#     environment = "dev"
#   }
# }

# resource "azurerm_public_ip" "nginx_instance_pip" {
#   name                = "nginx-instance-pip"
#   resource_group_name = azurerm_resource_group.myrg-rg.name
#   location            = azurerm_resource_group.myrg-rg.location
#   allocation_method   = "Static"

#   tags = {
#     environment = "dev"
#   }
# }

# ## WEB INSTANCES
# resource "azurerm_linux_virtual_machine" "web_instances" {
#   count               = 3
#   name                = "web${count.index + 1}"
#   resource_group_name = azurerm_resource_group.myrg-rg.name
#   location            = azurerm_resource_group.myrg-rg.location
#   size                = var.vm_size

#   admin_username      = "webadmin"
#   network_interface_ids = [
#     azurerm_network_interface.web_instance_nics[count.index].id
#   ]

#   admin_ssh_key {
#     username   = "webadmin"
#     public_key = var.ssh_public_key
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = var.image_reference["publisher"]
#     offer     = var.image_reference["offer"]
#     sku       = var.image_reference["sku"]
#     version   = var.image_reference["version"]
#   }

#   tags = {
#     environment = "dev"
#   }
# }

# resource "azurerm_network_interface" "web_instance_nics" {
#   count               = 3
#   name                = "web-nic-${count.index + 1}"
#   resource_group_name = azurerm_resource_group.myrg-rg.name
#   location            = azurerm_resource_group.myrg-rg.location

#   ip_configuration {
#     name                          = "web-ip-config-${count.index + 1}"
#     subnet_id                     = azurerm_subnet.subnet_1.id
#     private_ip_address_allocation = "Dynamic"
#   }

#   tags = {
#     environment = "dev"
#   }
# }

# ## DATABASE INSTANCE
# resource "azurerm_linux_virtual_machine" "mysql_instance" {
#   name                = "mysql-instance"
#   resource_group_name = azurerm_resource_group.myrg-rg.name
#   location            = azurerm_resource_group.myrg-rg.location
#   size                = var.vm_size

#   admin_username      = "mysqladmin"
#   network_interface_ids = [
#     azurerm_network_interface.mysql_instance_nic.id
#   ]

#   admin_ssh_key {
#     username   = "mysqladmin"
#     public_key = var.ssh_public_key
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = var.image_reference["publisher"]
#     offer     = var.image_reference["offer"]
#     sku       = var.image_reference["sku"]
#     version   = var.image_reference["version"]
#   }

#   tags = {
#     environment = "dev"
#   }
# }

# resource "azurerm_network_interface" "mysql_instance_nic" {
#   name                = "mysql-instance-nic"
#   resource_group_name = azurerm_resource_group.myrg-rg.name
#   location            = azurerm_resource_group.myrg-rg.location

#   ip_configuration {
#     name                          = "mysql-ip-config"
#     subnet_id                     = azurerm_subnet.subnet_1.id
#     private_ip_address_allocation = "Dynamic"
#   }

#   tags = {
#     environment = "dev"
#   }
# }
