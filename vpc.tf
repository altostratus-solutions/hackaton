################################################
#######              VPC                 #######
################################################

resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "vpc-hackaton"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  project       = var.project_id   
  name          = "sb-hackaton"
  ip_cidr_range = "10.0.0.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "rn-${var.location}-gke-pod"
    ip_cidr_range = "10.1.0.0/19"
  }

  secondary_ip_range {
    range_name    = "rn-${var.location}-gke-svc"
    ip_cidr_range = "10.2.0.0/24"
  }
}

################################################
#######              NAT                 #######
################################################

resource "google_compute_router" "router" {
  project = var.project_id
  name    = "router-gke-nat"
  region  = google_compute_subnetwork.subnetwork.region
  network = google_compute_network.vpc.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  project                            = var.project_id
  name                               = "nat-vms"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}