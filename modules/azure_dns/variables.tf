variable "domain" {
  type = "string"
  description = "Domain purchased for this campaign, e.g. phishdomain.com"
}

variable "resource_group" {
  type = "string"
  description = "Name of the Resource Group where objects should be created"
}

variable "hostname" {
  type = "string"
  description = "Hostname of the GoPhish Server / Landing Site"
}

variable "ip_address" {
  type = "string"
  description = "Public IP Address of GoPhish Server"
}

variable "customer" {
  type = "string"
  description = "Customer for which this campaign is being run"
}