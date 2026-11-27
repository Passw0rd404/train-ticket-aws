output "zone_id" {
  value = data.cloudflare_zone.this.zone_id
}

output "tunnel_id" {
  value = cloudflare_zero_trust_tunnel_cloudflared.this.id
}

output "tunnel_token" {
  value     = data.cloudflare_zero_trust_tunnel_cloudflared_token.this.token
  sensitive = true
}

output "pages_subdomain" {
  value = cloudflare_pages_project.this.subdomain
}
