// Creation of the inventory file for Ansible
// The outputs will be the hostname in GCP format that the internal DNS can interpret
// and the internal IP

resource "local_file" "ansible_inventory" {
  content = templatefile ("inventory.tmpl",
    {
      ip_mongo_node1 = google_compute_instance.mongo_node1.network_interface.0.network_ip
      ip_mongo_node2 = google_compute_instance.mongo_node2.network_interface.0.network_ip
      ip_mongo_node3 = google_compute_instance.mongo_node3.network_interface.0.network_ip

      hostname_mongo_node1 = "${google_compute_instance.mongo_node1.name}.${google_compute_instance.mongo_node1.zone}.c.${var.project}.internal"
      hostname_mongo_node2 = "${google_compute_instance.mongo_node2.name}.${google_compute_instance.mongo_node2.zone}.c.${var.project}.internal"
      hostname_mongo_node3 = "${google_compute_instance.mongo_node3.name}.${google_compute_instance.mongo_node3.zone}.c.${var.project}.internal"
    })
  filename = "../ansible/inventory"
}
