resource "google_compute_firewall" "hc_range_gcp" {
  project   = var.project_id
  name      = "fw-1000-i-a-hc-gke"
  network   = google_compute_network.vpc.self_link
  direction = "INGRESS"
  priority  = 1000
  disabled  = false

  allow {
    protocol = "all"
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}