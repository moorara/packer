variable "google_account_file" {
  type = string
}

variable "google_project_id" {
  type = string
}

variable "google_region" {
  type = string
  default = "us-east4"
}

variable "google_zone" {
  type = string
  default = "us-east4-a"
}

variable "google_image" {
  type = string
}

variable "google_ssh_user" {
  type = string
}

variable "google_machine_type" {
  type = string
  default = "g1-small"
}
