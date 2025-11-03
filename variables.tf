variable "location" {
  description = "Región de Azure donde se crean los recursos"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "rg-tfg-asir-prueba"
}
