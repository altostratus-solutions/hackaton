locals {
  authorized_source_ranges = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "allow-all"
    },
  ]
}

resource "google_container_cluster" "phoenix" {
    project           = var.project_id
    name              = "gke-alt-${var.location}"
    location          = var.location

    network           = google_compute_network.vpc.self_link
    subnetwork        = google_compute_subnetwork.subnetwork.self_link
    enable_autopilot  = true

    addons_config {
      gke_backup_agent_config {
        enabled = true
      }
    }

    cluster_autoscaling {
        auto_provisioning_defaults {
            service_account = module.gke-sa-hackaton.email
        }
    }

    private_cluster_config {
        enable_private_endpoint = false
        enable_private_nodes    = true
        master_ipv4_cidr_block  = "10.233.0.0/28"
    }

    master_authorized_networks_config {
      dynamic "cidr_blocks" {
        for_each = local.authorized_source_ranges
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }

    maintenance_policy {
      recurring_window {
        start_time = "2024-01-01T00:00:00Z"
        recurrence = "FREQ=WEEKLY;BYDAY=MO,SA,SU"
        end_time   = "2050-01-01T04:00:00Z"
      }
    }

    ip_allocation_policy {
      cluster_secondary_range_name  = "rn-${var.location}-gke-pod"
      services_secondary_range_name = "rn-${var.location}-gke-svc"
    }

    release_channel {
        channel = "REGULAR"
    }
    
    dns_config {
      cluster_dns        = "CLOUD_DNS" 
      cluster_dns_domain = "cluster.local" 
      cluster_dns_scope  = "CLUSTER_SCOPE" 
    }
    
    timeouts {
        create = "1h"
        update = "1h"
        delete = "1h"
    }

    depends_on = [ google_compute_network.vpc ]
}
