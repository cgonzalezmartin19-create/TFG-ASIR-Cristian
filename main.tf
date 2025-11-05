terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_proyecto" {
  name     = "rg-tfg-asir-prueba"
  location = "West Europe"

  tags = {
    Proyecto = "TFG ASIR"
    Entorno  = "Desarrollo"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-tfg-asir"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_proyecto.location
  resource_group_name = azurerm_resource_group.rg_proyecto.name
  tags = {
    Proyecto = "TFG ASIR"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-tfg-asir"
  resource_group_name  = azurerm_resource_group.rg_proyecto.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-tfg-asir"
  location            = azurerm_resource_group.rg_proyecto.location
  resource_group_name = azurerm_resource_group.rg_proyecto.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-tfg-asir"
  location            = azurerm_resource_group.rg_proyecto.location
  resource_group_name = azurerm_resource_group.rg_proyecto.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_nic" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-tfg-asir"
  resource_group_name = azurerm_resource_group.rg_proyecto.name
  location            = azurerm_resource_group.rg_proyecto.location
  size                = "Standard_B2s"
  admin_username      = "azureuser"

  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${path.module}/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-focal"
  sku       = "20_04-lts-gen2"
  version   = "latest"
}

  tags = {
    Proyecto = "TFG ASIR"
  }
}
