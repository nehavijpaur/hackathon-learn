terraform {
  backend "azurerm" {
    resource_group_name  = "backendtf-rg"
    storage_account_name = "statefilestrg"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    tenant_id            = "c6d5705d-c3d8-44a2-9454-7f00b90ee67c"
    subscription_id      = "b23019ef-882f-400c-bec3-05ad0c529130"
    client_id            = "a882255f-41b9-43e6-85a2-e7495a28db04"
  }
}
