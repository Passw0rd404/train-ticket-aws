data "cloudflare_zone" "this" {
  filter = {
    name = var.zone_name
    account = {
      id = var.account_id
    }
  }
}

locals {
  zone_suffix     = ".${var.zone_name}"
  api_subdomain   = trimsuffix(var.api_hostname, local.zone_suffix)
  pages_subdomain = trimsuffix(var.pages_domain, local.zone_suffix)
}

# ---- Remotely managed Cloudflare Tunnel -> Traefik (ClusterIP :80) ----------
resource "cloudflare_zero_trust_tunnel_cloudflared" "this" {
  account_id = var.account_id
  name       = "${var.name}-tunnel"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "this" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id

  config = {
    ingress = [
      {
        hostname = var.api_hostname
        service  = var.traefik_service_url
      },
      {
        service = "http_status:404"
      },
    ]
  }
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "this" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id
}

resource "cloudflare_dns_record" "api" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = local.api_subdomain
  content = "${cloudflare_zero_trust_tunnel_cloudflared.this.id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

# ---- Cloudflare Pages (frontend) + custom domain ----------------------------
resource "cloudflare_pages_project" "this" {
  account_id        = var.account_id
  name              = var.pages_project_name
  production_branch = "main"
}

resource "cloudflare_pages_domain" "this" {
  account_id   = var.account_id
  project_name = cloudflare_pages_project.this.name
  name         = var.pages_domain
}

resource "cloudflare_dns_record" "pages" {
  zone_id = data.cloudflare_zone.this.zone_id
  name    = local.pages_subdomain
  content = cloudflare_pages_project.this.subdomain
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
