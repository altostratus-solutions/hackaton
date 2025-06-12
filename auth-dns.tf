################################################
#######          CREATE SSL CERT           #####
################################################

resource "google_compute_managed_ssl_certificate" "hackaton" {
  project   = var.project_id
  name      = "ssl-cert"

  managed {
    domains = ["hackaton.martincloud.org"]
  }
}

######################################
########     IP Reserved     #########
######################################

resource "google_compute_global_address" "elb_hackaton" {
  project      = var.project_id
  name         = "elb-hackaton"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}

###############################################
######          CREATE SSL CERT           #####
###############################################

resource "google_certificate_manager_certificate" "cert_hackaton" {
  project     = var.project_id
  name        = "cert-hackaton"
  description = "Certificado GKE hackaton"
  managed {
    domains = ["hackaton.martincloud.org"]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.dnsauth_hackaton.id
    ]
  }
}

resource "google_certificate_manager_certificate_map" "cert_map_api_hackaton" {
  project     = var.project_id
  name        = "certmap-hackaton"
  description = "Certmap hackaton"
}

resource "google_certificate_manager_certificate_map_entry" "first_entry_hackaton" {
  project      = var.project_id
  name         = "map-entry-hackaton"
  description  = "Cert map hackaton"
  map          = google_certificate_manager_certificate_map.cert_map_api_hackaton.name
  certificates = [google_certificate_manager_certificate.cert_hackaton.id]
  hostname     = "hackaton.martincloud.org"
}

################################################
#######          Autorizacion DNS          #####
################################################

resource "google_certificate_manager_dns_authorization" "dnsauth_hackaton" {
  project     = var.project_id
  name        = "dnsauth-hackaton"
  description = "DNS Auth"
  domain      = "hackaton.martincloud.org"
}