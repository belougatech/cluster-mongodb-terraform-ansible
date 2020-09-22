// Configuration of the provider
// In this project, credentials are provided in a .json file. 
// The file has been generated through GCP Console for a service account used for terraform deployment only
// You can use also use application default credentials.
provider "google" {
  credentials = file("${var.credentials_path}")
  project     = var.project
  region      = var.region
}

// Creation of the 3 Compute Engine instances for the mongodb cluster.
// The first one will me the leader (where the cluster will be initialized from).
// The 2 other will start as secondary nodes
// Instances will be provisionned on 3 different zones for resiliency purpose.
resource "google_compute_instance" "mongo_node1" {
  name         = "mongodb-node1"
  description  = "VM hosting tools for node 1 of mongodb"

  machine_type = "f1-micro"
  zone         = var.zones[0]

  labels = {
    env        = "dev"
    app        = "mongodb"
  }

  boot_disk {
    initialize_params {
      image    = "ubuntu-os-cloud/ubuntu-1804-lts"
      size     = 10
    }
  }

  // In this project, the instances are created in a private subnet which is not reachable from internet
  network_interface {
   network     = var.network
   subnetwork  = var.subnet
  }

  // SSH-keys used for authentication
  metadata = {
    ssh-keys   = "${var.ssh_user}:${file("${var.public_key_path}")}"
  }

  // Tags used by the ILB
  tags = ["allow-mongodb"]
}

resource "google_compute_instance" "mongo_node2" {
  name         = "mongodb-node2"
  description  = "VM hosting tools for node 2 of mongodb"

  machine_type = "f1-micro"
  zone         = var.zones[1]

  labels = {
    env        = "dev"
    app        = "mongodb"
  }

  boot_disk {
    initialize_params {
      image    = "ubuntu-os-cloud/ubuntu-1804-lts"
      size     = 10
    }
  }

  network_interface {
   network     = var.network
   subnetwork  = var.subnet
  }
  
  metadata = {
    ssh-keys   = "${var.ssh_user}:${file("${var.public_key_path}")}"
  }

  tags = ["allow-mongodb"]
}

resource "google_compute_instance" "mongo_node3" {
  name         = "mongodb-node3"
  description  = "VM hosting tools for node 3 of mongodb"

  machine_type = "f1-micro"
  zone         = var.zones[2]

  labels = {
    env        = "dev"
    app        = "mongodb"
  }

  boot_disk {
    initialize_params {
      image    = "ubuntu-os-cloud/ubuntu-1804-lts"
      size     = 10
    }
  }

  network_interface {
   network     = var.network
   subnetwork  = var.subnet
  }

  metadata = {
    ssh-keys   = "${var.ssh_user}:${file("${var.public_key_path}")}"
  }

  tags = ["allow-mongodb"]
}

// Creation of the 3 Unmanaged Instance Groups, 1 per zone
// Each IGM will be attached to one of the instance created previously
resource "google_compute_instance_group" "mongo_group1" {
  name        = "mongodb-group1"
  description = "Zonal instance group for mongodb cluster"

  instances = [
    google_compute_instance.mongo_node1.id,
  ]

  named_port {
    name = "mongodb"
    port = var.mongodb_port
  }

  zone = var.zones[0]
}

resource "google_compute_instance_group" "mongo_group2" {
  name        = "mongodb-group2"
  description = "Zonal instance group for mongodb cluster"

  instances = [
    google_compute_instance.mongo_node2.id,
  ]

  named_port {
    name = "mongodb"
    port = var.mongodb_port
  }

  zone = var.zones[1]
}

resource "google_compute_instance_group" "mongo_group3" {
  name        = "mongodb-group3"
  description = "Zonal instance group for mongodb cluster"

  instances = [
    google_compute_instance.mongo_node3.id,
  ]

  named_port {
    name = "mongodb"
    port = var.mongodb_port
  }

  zone = var.zones[2]
}