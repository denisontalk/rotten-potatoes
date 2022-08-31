terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.20.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_azure" {
  name     = "resource-aks"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "kubernetes-aks" {
  name                = "kubernetes-aks"
  location            = azurerm_resource_group.resource_azure.location
  resource_group_name = azurerm_resource_group.resource_azure.name
  dns_prefix          = "resource"
  kubernetes_version = "1.24.0"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2_v2"
    zones = [1,2]
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_container_registry" "acr" {
  name                = "denisonregistry"
  resource_group_name = azurerm_resource_group.resource_azure.name
  location            = azurerm_resource_group.resource_azure.location
  sku                 = "Premium"
  admin_enabled       = false

}

resource "azurerm_role_assignment" "acr_role" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.kubernetes-aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
}