output "vault_nlb_dns" {
  value = aws_lb.vault_nlb.dns_name
}

output "vault_instance_ips" {
  value = aws_instance.vault[*].private_ip
}
