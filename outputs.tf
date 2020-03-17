output "server_ip" {
  value = ["${module.create_networking.public_ip}"]
}

output "dns_nameservers" {
  value = ["${module.create_dns.name_servers}"]
}