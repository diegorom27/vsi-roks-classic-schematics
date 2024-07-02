##############################################################################
# Terraform Providers
##############################################################################
terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = ">=1.19.0"
    }
  }
}
##############################################################################
# Provider
##############################################################################
# ibmcloud_api_key = var.ibmcloud_api_key
provider ibm {
    alias  = "primary"
    region = var.ibm_region
    max_retries = 20
}
##############################################################################
# Resource Group
##############################################################################
data ibm_resource_group group {
    provider = ibm.primary
    name = var.resource_group
}
##############################################################################
# Control plane
# ibmcloud sl hardware create-options
# OS_RHEL_8_X_64_BIT_PER_PROCESSOR_LICENSING      REDHAT_8_64
##############################################################################
# Crear almacenamiento en bloque para cada disco
resource "ibm_storage_block" "control_plane_storage" {
  for_each = {
    for vm in var.control_plane : vm.hostname => { for idx, size in vm.disks : "${vm.hostname}-${idx}" => size }
  }
  type = "standard"
  os_format_type = "Linux"
  id           = "${each.key}"
  datacenter       = "dal13"
  capacity       = each.value
  iops           = 3
}

resource "ibm_compute_vm_instance" "control_plane" {
    for_each             = { for vm in var.control_plane : vm.hostname => vm }
    domain               = "clusteropenshift.com"
    os_reference_code    = "REDHAT_8_64"
    datacenter           = "dal13"
    hourly_billing       = true
    private_network_only = false
    cores                = 4
    memory               = 16384
    disks                = [25]
    local_disk           = true
    hostname = each.value.hostname
}

##############################################################################
# Worker nodes
##############################################################################

resource "ibm_storage_block" "worker_nodes_storage" {
  for_each = {
    for vm in var.worker_nodes : vm.hostname => { for idx, size in vm.disks : "${vm.hostname}-${idx}" => size }
  }
  type = "standard"
  os_format_type = "Linux"
  id         = "${each.key}"
  datacenter     = "dal13"
  capacity       = each.value
  iops           = 3
}

resource "ibm_compute_vm_instance" "worker_nodes" {
    for_each             = { for vm in var.worker_nodes : vm.hostname => vm }
    domain               = "clusteropenshift.com"
    os_reference_code    = "REDHAT_8_64"
    datacenter           = "dal13"
    hourly_billing       = true
    private_network_only = false
    cores                = 4
    memory               = 16384
    disks                = [25]
    local_disk           = true
    hostname = each.value.hostname
}

##############################################################################
# ODF
##############################################################################

resource "ibm_storage_block" "ODF_nodes_storage" {
  for_each = {
    for vm in var.ODF : vm.hostname => { for idx, size in vm.disks : "${vm.hostname}-${idx}" => size }
  }
  type = "standard"
  os_format_type = "Linux"
  id         = "${each.key}"
  datacenter     = "dal13"
  capacity       = each.value
  iops           = 3
}
resource "ibm_compute_vm_instance" "ODF" {
    for_each             = { for vm in var.ODF : vm.hostname => vm }
    domain               = "clusteropenshift.com"
    os_reference_code    = "REDHAT_8_64"
    datacenter           = "dal13"
    hourly_billing       = true
    private_network_only = false
    cores                = 8
    memory               = 32768
    disks                = [25]
    local_disk           = true
    hostname = each.value.hostname
}