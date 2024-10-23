#data "azurerm_client_config" "current" {}
variable "client_secret" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  backend "azurerm" {
  resource_group_name  = "backendtf-rg"
  storage_account_name = "statefilestrg"
  container_name       = "tfstate"
  key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
#  subscription_id = "b23019ef-882f-400c-bec3-05ad0c529130"
#  client_id       = "a882255f-41b9-43e6-85a2-e7495a28db04"
#  client_secret   = "${var.client_secret}"
#  tenant_id       = "c6d5705d-c3d8-44a2-9454-7f00b90ee67c"
}

resource "azurerm_resource_group" "infrarg_1" {
  name     = "infrarg1"
  location = "North Europe"
}

resource "azurerm_container_registry" "cr1_cr" {
  name                = "infracr1"
  resource_group_name = azurerm_resource_group.infrarg_1.name
  location            = azurerm_resource_group.infrarg_1.location
  sku                 = "Premium"
}

resource "azurerm_kubernetes_cluster" "infra1_aks" {
  name                = "infraaks1"
  location            = azurerm_resource_group.infrarg_1.location
  resource_group_name = azurerm_resource_group.infrarg_1.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }
}

resource "azurerm_role_assignment" "infra_ra" {
  principal_id                     = azurerm_kubernetes_cluster.infra1_aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.cr1_cr.id
  skip_service_principal_aad_check = true
}
