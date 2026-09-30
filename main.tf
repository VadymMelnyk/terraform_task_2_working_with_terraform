terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.105.0"
    }
  }
}


data "archive_file" "tf_code_zip" {
  type        = "zip"
  output_path = "${path.module}/my-code.zip"
  source_dir  = path.module
  
  # Ігноруємо сам ZIP-архів та системну папку .terraform, щоб не закольцовувати архів
  excludes = [
    "my-code.zip",
    ".terraform",
    ".terraform.lock.hcl",
    "tfplan"
  ]
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "blob" {
  name                   = var.blob_name
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = data.archive_file.tf_code_zip.output_path
}