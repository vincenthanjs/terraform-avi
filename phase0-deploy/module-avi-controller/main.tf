data "vsphere_datacenter" "datacenter" {
	name          = var.datacenter
}

data "vsphere_datastore" "datastore" {
	name          = var.datastore
	datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
	name          = var.cluster
	datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
	name          = var.host
	datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
	name          = var.network
	datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_ovf_vm_template" "ovf" {
	name             = var.vm_name
	resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
	datastore_id     = data.vsphere_datastore.datastore.id
	host_system_id   = data.vsphere_host.host.id
	remote_ovf_url   = var.remote_ovf_url

	ovf_network_map = {
		"Management" = data.vsphere_network.network.id
	}
}

resource "vsphere_virtual_machine" "vm" {
	datacenter_id	= data.vsphere_datacenter.datacenter.id
	name		= data.vsphere_ovf_vm_template.ovf.name
	num_cpus	= data.vsphere_ovf_vm_template.ovf.num_cpus
	memory		= data.vsphere_ovf_vm_template.ovf.memory
	guest_id	= data.vsphere_ovf_vm_template.ovf.guest_id

	resource_pool_id = data.vsphere_ovf_vm_template.ovf.resource_pool_id
	datastore_id     = data.vsphere_ovf_vm_template.ovf.datastore_id
	host_system_id   = data.vsphere_ovf_vm_template.ovf.host_system_id

	dynamic "network_interface" {
		for_each = data.vsphere_ovf_vm_template.ovf.ovf_network_map
		content {
			network_id = network_interface.value
		}
	}
	ovf_deploy {
		disk_provisioning	= "thin"
		ovf_network_map		= data.vsphere_ovf_vm_template.ovf.ovf_network_map
		remote_ovf_url		= data.vsphere_ovf_vm_template.ovf.remote_ovf_url
	}
	vapp {
		properties = {
			"mgmt-ip"	= var.mgmt-ip
			"mgmt-mask"	= var.mgmt-mask
			"default-gw"	= var.default-gw
		}
	}
}

resource "null_resource" "healthcheck" {
	triggers = {
		always_run	= timestamp()
		avi_addresses	= vsphere_virtual_machine.vm.guest_ip_addresses[0]
		avi-endpoint	= "avic.lab01.one"
	}
	provisioner "local-exec" {
		interpreter	= ["/bin/bash", "-c"]
		command		= "{path.module}/healthcheck.sh"
		environment	= {
			ENDPOINT	= self.triggers.avi-endpoint
		}
	}
}

resource "null_resource" "updateuser" {
	triggers = {
		avi-endpoint	= "avic.lab01.one"
		avi-username	= "admin"
		avi-oldpass	= "58NFaGDJm(PJH0G"
		avi-newpass	= var.admin-password
	}
	provisioner "local-exec" {
		interpreter	= ["/bin/bash", "-c"]
		command		= "${path.module}/updateuser.sh"
		environment	= {
			ENDPOINT	= self.triggers.avi-endpoint
			AVIUSER		= self.triggers.avi-username
			OLDPASS		= self.triggers.avi-oldpass
			NEWPASS		= self.triggers.avi-newpass
		}
	}
	depends_on = [
		null_resource.healthcheck
	]		
}
