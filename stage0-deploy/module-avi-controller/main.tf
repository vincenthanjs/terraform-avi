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
		always_run = timestamp()
	}
	provisioner "local-exec" {
		interpreter = ["/bin/bash", "-c"]
		command = <<-EOT
			CSRFREGEX='csrftoken=([A-Za-z0-9]+)'
			while [[ -z $CSRFTOKEN ]]; do
				CSRFHEADER=$(curl -kvs -X GET "https://avic.lab01.one" 2>&1 | grep -i set-cookie | grep csrftoken)
				if [[ $CSRFHEADER =~ $CSRFREGEX ]]; then
					CSRFTOKEN=$${BASH_REMATCH[1]}
					printf "%s\n" "X-CSRFToken [[ $CSRFTOKEN ]]"
				else
					printf "%s\n" "Waiting for API to respond.. sleep 30"
					sleep 30
				fi
			done
		EOT
	}
}

resource "null_resource" "updateuser" {
	triggers = {
		avi-endpoint = "avic.lab01.one"
		admin-password = var.admin-password
		always_run = timestamp()
	}
	provisioner "local-exec" {
		interpreter = ["/bin/bash", "-c"]
		command = <<-EOT
			## login
			AVIUSER="admin"
			NEWPASS="${self.triggers.admin-password}"
			OLDPASS="58NFaGDJm(PJH0G"
			ENDPOINT="${self.triggers.avi-endpoint}"
			LOGINHEADERS=$(curl -kvs -X POST \
				--data-urlencode "username=$AVIUSER" \
				--data-urlencode "password=$OLDPASS" \
			"https://$ENDPOINT/login" 2>&1 | grep -i set-cookie)
			
			## get cookies
			CSRFREGEX='csrftoken=([A-Za-z0-9]+)'
			if [[ $LOGINHEADERS =~ $CSRFREGEX ]]; then
				CSRFTOKEN=$${BASH_REMATCH[1]}
			fi
			printf "%s\n" "X-CSRFToken	[[ $CSRFTOKEN ]]"
			SESSIONREGEX='avi-sessionid\=([A-Za-z0-9]+)'
			if [[ $LOGINHEADERS =~ $SESSIONREGEX ]]; then
				SESSIONID=$${BASH_REMATCH[1]}
			fi
			printf "%s\n" "avi-sessionid	[[ $SESSIONID ]]"
			
			## update password
			if [[ -n "$CSRFTOKEN" && -n "$SESSIONID" ]]; then
				read -r -d '' BODY <<-CONFIG
				{
					"username": "$AVIUSER",
					"password": "$NEWPASS",
					"old_password": "$OLDPASS"
				}
				CONFIG
				curl -ks -X PUT \
					-b "sessionid=$SESSIONID;csrftoken=$CSRFTOKEN" \
					-H "Referer: https://avic.lab01.one" \
					-H "X-Avi-Version: 20.1.5" \
					-H "X-CSRFToken: $CSRFTOKEN" \
					-H "Content-Type: application/json" \
					--data "$BODY" \
				"https://$ENDPOINT/api/useraccount"
				echo "user [ $AVIUSER ] updated with password [ $NEWPASS ]"
			else
				echo "CSRFTOKEN or SESSIONID missing - check credentials"
			fi
		EOT
	}
	depends_on = [
		null_resource.healthcheck
	]		
}
