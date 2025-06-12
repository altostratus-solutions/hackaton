module "gke-sa-hackaton" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.3.0"

  project_id    = var.project_id
  names         = ["sa-gke-nodes"]
  description   = "SA for gke nodes"

  project_roles = [
    "${var.project_id}=>roles/logging.logWriter",
	  "${var.project_id}=>roles/logging.viewer",
    "${var.project_id}=>roles/cloudsql.client",
  ]
}