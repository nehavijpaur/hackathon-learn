data "azurerm_client_config" "current" {}

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
