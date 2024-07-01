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
data ibm_resource_group resource_group {
    provider = ibm.primary
    name = var.resource_group
}
##############################################################################
# Control plane
# ibmcloud sl hardware create-options
# OS_RHEL_8_X_64_BIT_PER_PROCESSOR_LICENSING      REDHAT_8_64
##############################################################################
# Crear almacenamiento en bloque para cada disco
resource "ibm_block_storage" "control_plane_storage" {
    for_each = {
        for vm in var.control_plane : vm.hostname => flatten([for idx, size in vm.disks : {
            vm_hostname = vm.hostname
            index       = idx
            size        = size
        }])
    }
    resource_group = data.ibm_resource_group.group.id
    name         = "${each.value.vm_hostname}-disk-${each.value.index + 1}"
    storage_type = "performance"
    size         = each.value.size
    iops         = 3
    location     = "dal13"
}

resource "ibm_compute_vm_instance" "control_plane" {
    for_each             = { for vm in var.control_plane : vm.hostname => vm }
    domain               = "clusteropenshift.com"
    os_reference_code    = "REDHAT_8_64"
    datacenter           = "dal13"
    hourly_billing       = true
    private_network_only = false
    cores                = 4
    memory               = 16000
    disks                = [25]
    local_disk           = true
    resource_group = data.ibm_resource_group.group.id
    hostname = each.value.hostname
}

# Adjuntar cada disco a la instancia correspondiente
resource "ibm_compute_vm_instance_block_device_attachment" "control_plane_storage_attachment" {
  for_each = {
    for vm in var.control_plane : vm.hostname => { for idx, size in vm.disks : "${vm.hostname}-${idx}" => size }
  }
  instance_id     = ibm_compute_vm_instance.control_plane[split("-", each.key)[0]].id
  block_volume_id = ibm_block_storage.control_plane_storage[each.key].id
  device_name     = "xvd${char(97 + tonumber(split("-", each.key)[1]))}" # a, b, c, etc.
}

##############################################################################
# Worker nodes
##############################################################################

resource "ibm_block_storage" "worker_nodes_storage" {
    for_each = {
        for vm in var.worker_nodes : vm.hostname => flatten([for idx, size in vm.disks : {
            vm_hostname = vm.hostname
            index       = idx
            size        = size
        }])
    }
    resource_group = data.ibm_resource_group.group.id
    name         = "${each.value.vm_hostname}-disk-${each.value.index + 1}"
    storage_type = "performance"
    size         = each.value.size
    iops         = 3
    location     = "dal13"
}

resource "ibm_compute_vm_instance" "worker_nodes" {
    for_each             = { for vm in var.worker_nodes : vm.hostname => vm }
    domain               = "clusteropenshift.com"
    os_reference_code    = "REDHAT_8_64"
    datacenter           = "dal13"
    hourly_billing       = true
    private_network_only = false
    cores                = 4
    memory               = 16000
    disks                = [25]
    local_disk           = true
    resource_group = data.ibm_resource_group.group.id
    hostname = each.value.hostname
}

# Adjuntar cada disco a la instancia correspondiente
resource "ibm_compute_vm_instance_block_device_attachment" "worker_nodes_storage_attachment" {
  for_each = {
    for vm in var.worker_nodes : vm.hostname => { for idx, size in vm.disks : "${vm.hostname}-${idx}" => size }
  }
  instance_id     = ibm_compute_vm_instance.worker_nodes[split("-", each.key)[0]].id
  block_volume_id = ibm_block_storage.worker_nodes_storage[each.key].id
  device_name     = "xvd${char(97 + tonumber(split("-", each.key)[1]))}" # a, b, c, etc.
}
##############################################################################
# ODF
##############################################################################

resource "ibm_block_storage" "ODF_nodes_storage" {
    for_each = {
        for vm in var.ODF : vm.hostname => flatten([for idx, size in vm.disks : {
            vm_hostname = vm.hostname
            index       = idx
            size        = size
        }])
    }
    resource_group = data.ibm_resource_group.group.id
    name         = "${each.value.vm_hostname}-disk-${each.value.index + 1}"
    storage_type = "performance"
    size         = each.value.size
    iops         = 3
    location     = "dal13"
}
resource "ibm_compute_vm_instance" "ODF" {
    for_each             = { for vm in var.ODF : vm.hostname => vm }
    domain               = "clusteropenshift.com"
    os_reference_code    = "REDHAT_8_64"
    datacenter           = "dal13"
    hourly_billing       = true
    private_network_only = false
    cores                = 8
    memory               = 32000
    disks                = [25]
    local_disk           = true
    resource_group = data.ibm_resource_group.group.id
    hostname = each.value.hostname
}

# Adjuntar cada disco a la instancia correspondiente
resource "ibm_compute_vm_instance_block_device_attachment" "ODF_storage_attachment" {
  for_each = {
    for vm in var.ODF : vm.hostname => { for idx, size in vm.disks : "${vm.hostname}-${idx}" => size }
  }
  instance_id     = ibm_compute_vm_instance.ODF[split("-", each.key)[0]].id
  block_volume_id = ibm_block_storage.ODF_nodes_storage[each.key].id
  device_name     = "xvd${char(97 + tonumber(split("-", each.key)[1]))}" # a, b, c, etc.
}