variable "domain" {
  type = "string"
  description = "Domain purchased for this campaign, e.g. phishdomain.com"
}

variable "hostname" {
  type = "string"
  description = "Hostname of the GoPhish Server / Landing Site, e.g. 'landing' for landing.domain.com"
}

variable "sendgrid_server" {
  type = "string"
  description = "SendGrid SMTP Server Address"
  default = "smtp.sendgrid.com"
}

variable "sendgrid_user" {
  type = "string"
  description = "Username for SendGrid - usually starts with azure_..."
}

variable "sendgrid_pass" {
  type = "string"
  description = "Password for SendGrid, specified during account creation"
}

variable "customer" {
  type = "string"
  description = "Customer for which this campaign is being run (spaces not allowed)"
}

variable "support_email" {
  type = "string"
  description = "Email address used for LetsEncrypt cert registration"
}

variable "azure_client_id" {
  type = "string"
}

variable "azure_client_secret" {
  type = "string"
}