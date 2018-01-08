provider "google" {
  credentials = "${file(var.google_account_file)}"
  project = "${var.google_project_id}"
  region = "${var.google_region}"
}

resource "google_compute_instance" "packer-test" {
  name = "packer-test"
  zone = "${var.google_zone}"
  machine_type = "${var.google_machine_type}"
  boot_disk {
    initialize_params {
      image = "${var.google_image}"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata {
    ssh-keys = "${var.google_ssh_user}:${file("packer-test.pub")}"
  }
  labels = {
    name = "packer-test"
  }
}

output "google_instance_ip" {
  value = "${google_compute_instance.packer-test.network_interface.0.access_config.0.assigned_nat_ip}"
}
