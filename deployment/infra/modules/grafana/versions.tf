terraform {
  required_version = ">= 1.11"
  required_providers {
    grafana = {
      source                = "grafana/grafana"
      version               = "~> 4.20"
      configuration_aliases = [grafana.cloud, grafana.stack]
    }
  }
}
