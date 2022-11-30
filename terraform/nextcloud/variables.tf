variable "cf_api_token" {
  description = "Token do edycji DNS cloudflare"
  type        = string
  sensitive   = true
}

variable "cf_wlodek_pro_zone_id" {
  description = "ID strefy wlodek.pro"
  type        = string
  sensitive   = true
}