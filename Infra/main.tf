terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }  
}

provider "azurerm" {
  features {}

  subscription_id   = "b23019ef-882f-400c-bec3-05ad0c529130"
  tenant_id         = "c6d5705d-c3d8-44a2-9454-7f00b90ee67c"
  client_id         = "c7bcd53a-5ad8-4b01-8fad-6b0d6280e3b0"
  client_secret     = "x3N8Q~m1SK2Bvd_xFbT20CDxU~.w9z3Wx2B9VbCn"
}

resource "azurerm_resource_group" "infrarg_1" {
  name     = "infrarg1"
  location = "West Europe"
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
