#variable ibmcloud_api_key {
#    description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
#    type        = string
#}
variable ibm_region {
    description = "IBM Cloud region where all resources will be deployed"
    type        = string

    validation  {
      error_message = "Must use an IBM Cloud region. Use `ibmcloud regions` with the IBM Cloud CLI to see valid regions."
      condition     = can(
        contains([
          "au-syd",
          "jp-tok",
          "eu-de",
          "eu-gb",
          "us-south",
          "us-east"
        ], var.ibm_region)
      )
    }
}
variable resource_group {
    description = "Name of resource group where all infrastructure will be provisioned"
    type        = string
    default     = "asset-development"

    validation  {
      error_message = "Unique ID must begin and end with a letter and contain only letters, numbers, and - characters."
      condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.resource_group))
    }
}
variable public_vlan_name {
    description = "vlan name for the cluster"
    type        = string
    default     = "dal13.fcr02.781"
}
variable private_vlan_name {
    description = "vlan name for the cluster"
    type        = string
    default     = "dal13.bcr02.815"
}
variable control_plane {
    description = "List of vm for control plane"
    type = list(object({
        hostname = string
        disks = list(number)
    }))
    default = [
        {
            hostname = "controlplane01.satellite-demo.cloud"
            disks    = [25,100]
        },
        {
            hostname = "controlplane02.satellite-demo.cloud"
            disks    = [25,100]
        },
        {
            hostname = "controlplane03.satellite-demo.cloud"
            disks    = [25,100]
        },
    ]
}

variable worker_nodes {
    description = "List of vm for worker nodes"
        type        = list(object({
            hostname     = string
            disks = list(number)
        }))
    default     = [
        {
            hostname     = "worker01.satellite-demo.cloud"
            disks = [25,100]
        },
        {
            hostname     = "worker02.satellite-demo.cloud"
            disks = [25,100]
        },
        {
            hostname     = "worker03.satellite-demo.cloud "
            disks = [25,100]
        }
    ]
}

variable ODF {
    description = "List of vm for ODF"
        type        = list(object({
            hostname     = string
            disks = list(number)
        }))
    default     = [
        {
            hostname     = "worker01.satellite-demo.cloud"
            disks = [25,100,100,300]
        },
        {
            hostname     = "worker02.satellite-demo.cloud"
            disks = [25,100,100,300]
        },
        {
            hostname     = "worker03.satellite-demo.cloud "
            disks = [25,100,100,300]
        }
    ]
}