terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.62.1"
    }
  }
}

variable "subscription_id_1" {
  type = string
}

variable "tenant_id_1" {
  type = string
}

variable "client_id_1" {
  type = string
}

variable "client_secret_1" {
  type = string
}

variable "subscription_id_2" {
  type = string
}

variable "tenant_id_2" {
  type = string
}

variable "client_id_2" {
  type = string
}

variable "client_secret_2" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

data "azurerm_client_config" "current" {
  provider = azurerm.subscription_1
}

data "azurerm_subscription" "current" {
  provider = azurerm.subscription_2
}



data "azurerm_client_config" "remote" {
  provider = azurerm.subscription_2
}

data "azurerm_subscription" "remote" {
  provider = azurerm.subscription_2
}


# Configure the Azure provider

provider "azurerm" {
  alias           = "subscription_1"
  subscription_id = var.subscription_id_1
  client_id       = var.client_id_1
  client_secret   = var.client_secret_1
  tenant_id       = var.tenant_id_1

  features {
  }
}

provider "azurerm" {
  alias           = "subscription_2"
  subscription_id = var.subscription_id_2
  client_id       = var.client_id_2
  client_secret   = var.client_secret_2
  tenant_id       = var.tenant_id_2
  features {
  }
}

resource "azurerm_resource_group" "tenant_1" {
  provider = azurerm.subscription_1
  name     = "tenant_1"
  location = var.location
}

resource "azurerm_resource_group" "tenant_2" {
  provider = azurerm.subscription_2
  name     = "tenant_2"
  location = var.location
}


# Create network resources in Subscription A

resource "azurerm_virtual_network" "network_a" {
  provider            = azurerm.subscription_1
  name                = "network_a"
  address_space       = ["10.111.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.tenant_1.name
}

resource "azurerm_subnet" "subnet_a" {
  provider             = azurerm.subscription_1
  name                 = "subnet_a"
  resource_group_name  = azurerm_virtual_network.network_a.resource_group_name
  virtual_network_name = azurerm_virtual_network.network_a.name
  address_prefixes     = ["10.111.0.0/24"]
}


# resource "azurerm_role_assignment" "network_contributor_1" {
#   provider = azurerm.subscription_1
#   #   scope                = azurerm_virtual_network.network_a.id
#   scope                = data.azurerm_subscription.current.id
#   role_definition_name = "Network Contributor"
#   principal_id         = data.azurerm_client_config.current.object_id
# }


# resource "azurerm_role_assignment" "network_contributor_2" {
#   provider = azurerm.subscription_2
#   #   scope                = azurerm_virtual_network.network_b.id
#   scope                = data.azurerm_subscription.remote.id
#   role_definition_name = "Network Contributor"
#   principal_id         = data.azurerm_client_config.remote.object_id
# }


# Create network resources in Subscription B

resource "azurerm_virtual_network" "network_b" {
  provider            = azurerm.subscription_2
  name                = "network_b"
  address_space       = ["10.112.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.tenant_2.name
}

resource "azurerm_subnet" "subnet_b" {
  provider             = azurerm.subscription_2
  name                 = "subnet_b"
  resource_group_name  = azurerm_virtual_network.network_b.resource_group_name
  virtual_network_name = azurerm_virtual_network.network_b.name
  address_prefixes     = ["10.112.0.0/24"]
}

# Create network peering connections

# resource "azurerm_virtual_network_peering" "peering_a_to_b" {
#   provider                  = azurerm.subscription_1
#   name                      = "peering_a_to_b"
#   resource_group_name       = azurerm_virtual_network.network_a.resource_group_name
#   virtual_network_name      = azurerm_virtual_network.network_a.name
#   remote_virtual_network_id = azurerm_virtual_network.network_b.id
#   #   remote_subscription_id       = var.subscription_id_2
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
#   allow_gateway_transit        = false
#   use_remote_gateways          = false
# }

# resource "azurerm_virtual_network_peering" "peering_b_to_a" {
#   provider                  = azurerm.subscription_2
#   name                      = "peering_b_to_a"
#   resource_group_name       = azurerm_virtual_network.network_b.resource_group_name
#   virtual_network_name      = azurerm_virtual_network.network_b.name
#   remote_virtual_network_id = azurerm_virtual_network.network_a.id
#   #   remote_subscription_id       = var.subscription_id_1
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = true
#   allow_gateway_transit        = false
#   use_remote_gateways          = false
# }


output "tenant_1" {
  value = data.azurerm_subscription.current.tenant_id
}

output "subscription_1" {
  value = data.azurerm_subscription.current.id
}

output "tenant_2" {
  value = data.azurerm_subscription.remote.tenant_id
}


output "subscription_2" {
  value = data.azurerm_subscription.remote.id
}


