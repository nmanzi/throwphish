variable "domain" {
  type = "string"
  description = "Domain purchased for this campaign, e.g. phishdomain.com"
}

variable "hostname" {
  type = "string"
  description = "Hostname of the GoPhish Server / Landing Site"
}

variable "resource_group" {
  type = "string"
  description = "Name of the Resource Group where objects should be created"
}

variable "server_url" {
  default = "production"
}

variable "server_urls" {
  type = "map"
  default = {
    "staging" = "https://acme-staging-v02.api.letsencrypt.org/directory"
    "production" = "https://acme-v02.api.letsencrypt.org/directory"
  }
}

variable "reg_email" {
  description = "Email address under which LE certs will be registered"
}

variable "key_type" {
  default = 4096
}

variable "acme_id" {
  type = "string"
}

variable "azure_client_id" {
  type = "string"
}

variable "azure_client_secret" {
  type = "string"
}