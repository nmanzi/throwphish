variable "nic_id" {
  type = "string"
  description = "ID of NIC created for this VM"
}

variable "domain" {
  type = "string"
  description = "Domain purchased for this campaign, e.g. phishdomain.com"
}

variable "resource_group" {
  type = "string"
  description = "Name of the Resource Group where objects should be created"
}

variable "customer" {
  type = "string"
  description = "Customer for which this campaign is being run"
}

variable "public_ip" {
  type = "string"
  description = "Public IP for this instance, used by provisioners"
}

variable "certificate_file_path" {
  type = "string"
}

variable "certificate_private_key_file_path" {
  type = "string"
}
