terraform {                                                                        
	required_providers {
		vsphere	= "~> 1.26.0"
		avi	= {
			source  = "vmware/avi"
			version = ">= 20.1.5"
		}
	}
}

provider "vsphere" {
	vsphere_server		= "vcenter.lab01.one"
	user			= "administrator@vsphere.local"
	password		= "VMware1!SDDC"
	allow_unverified_ssl	= true
}

provider "avi" {
	avi_controller		= var.avi_controller
	avi_username		= var.avi_username
	avi_password		= var.avi_password
	avi_tenant		= "admin"
	avi_version		= "20.1.5"
}

## vsphere objects
data "vsphere_datacenter" "datacenter" {
	name          = var.datacenter
}

data "vsphere_compute_cluster" "cmp" {
	name          = "cmp"
	datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "mgmt" {
	name          = "mgmt"
	datacenter_id = data.vsphere_datacenter.datacenter.id
}

## avi objects
data "avi_tenant" "tenant" {
	name = var.tenant
}

data "avi_cloud" "default" {
        name		= "Default-Cloud"
}

#resource "avi_systemconfiguration" "default" {
#	uuid	= "default"
#	dns_configuration {
#		search_domain = "lab01.one"
#		server_list {
#			addr = "172.16.10.1"
#			type = "V4"
#		}
#	}
#	ntp_configuration {
#		ntp_servers {
#			key_number = 1
#			server {
#				addr	= "172.16.10.1"
#				type	= "V4"
#			}
#		}
#	}
#	#dns_virtualservice_refs	= [
#	#	data.avi_virtualservice.ns1.id
	#]
	#portal_configuration {
	#	http_port			= 80
	#	https_port			= 443
	#	sslprofile_ref			= "https://avic.lab01.one/api/sslprofile/sslprofile-7c98e8cb-8f86-45b9-9e3b-fdb75dbd1d64"
	#	sslkeyandcertificate_refs	= [
	#		"https://avic.lab01.one/api/sslkeyandcertificate/sslkeyandcertificate-2987634c-1890-48e5-8863-cdd504c5eaec",
	#		"https://avic.lab01.one/api/sslkeyandcertificate/sslkeyandcertificate-d32fbfb9-4faf-4c5a-ae5d-a9515aa2ad47"
	#	]
	#}
#	welcome_workflow_complete	= true
#	lifecycle {
#		ignore_changes = all
			#[
			#ssh_ciphers,
			#ssh_hmacs
			#portal_configuration
		#]
#	}
#}

resource "avi_network" "ls-vip-pool" {
        name			= "ls-vip-pool"
	cloud_ref		= data.avi_cloud.default.id
	dhcp_enabled		= false
	ip6_autocfg_enabled	= false
	configured_subnets {
		prefix {
			ip_addr {
				addr = "172.16.20.0"
				type = "V4"
			}
			mask = 24
		}
		static_ip_ranges {
			type  = "STATIC_IPS_FOR_VIP"
			range {
				begin {
					addr = "172.16.20.101"
					type = "V4"
				}
				end {
					addr = "172.16.20.199"
					type = "V4"
				}
			}
		}
	}
}

resource "avi_ipamdnsproviderprofile" "tf-dns-vmw" {
	name	= "tf-dns-vmw"
	type	= "IPAMDNS_TYPE_INTERNAL_DNS"
	internal_profile {
		dns_service_domain {
			domain_name  = "lb.lab01.one"
			pass_through = false
			record_ttl   = 30
		}
	}
}

resource "avi_ipamdnsproviderprofile" "tf-ipam-vmw" {
	name	= "tf-ipam-vmw"
	type	= "IPAMDNS_TYPE_INTERNAL"
	internal_profile {
		usable_networks {
			nw_ref = avi_network.ls-vip-pool.id
		}
	}
}

resource "avi_cloud" "cloud" {
	name         = var.cloud_name
	vtype        = "CLOUD_VCENTER"
	tenant_ref   = data.avi_tenant.tenant.id
	license_tier = var.vcenter_license_tier
	license_type = var.vcenter_license_type
	dhcp_enabled = true
	vcenter_configuration {
		username		= var.vcenter_configuration.username
		#password		= var.vcenter_configuration.password
		password		= "VMware1!SDDC"
		vcenter_url		= var.vcenter_configuration.vcenter_url
		datacenter		= var.vcenter_configuration.datacenter
		management_network	= var.vcenter_configuration.management_network
		privilege		= var.vcenter_configuration.privilege
	}
	dns_provider_ref = avi_ipamdnsproviderprofile.tf-dns-vmw.id
	ipam_provider_ref = avi_ipamdnsproviderprofile.tf-ipam-vmw.id
	lifecycle {
		ignore_changes = [
			vcenter_configuration
		]
	}
}

resource "avi_serviceenginegroup" "cmp-se-group" {
	name			= "Default-Group"
	cloud_ref		= avi_cloud.cloud.id
	tenant_ref		= data.avi_tenant.tenant.id
	se_name_prefix		= "cmp"
	max_se			= 4
	#buffer_se		= 0
	se_deprovision_delay	= 1
	vcenter_clusters {
		cluster_refs	= [
			"https://avic.lab01.one/api/vimgrclusterruntime/${data.vsphere_compute_cluster.cmp.id}-${avi_cloud.cloud.uuid}"
		]
		include		= true
	}
}

resource "avi_serviceenginegroup" "mgmt-se-group" {
	name			= "mgmt-se-group"
	cloud_ref		= avi_cloud.cloud.id
	tenant_ref		= data.avi_tenant.tenant.id
	se_name_prefix		= "mgmt"
	max_se			= 2
	#buffer_se		= 0
	se_deprovision_delay	= 1
	vcenter_clusters {
		cluster_refs	= [
			"https://avic.lab01.one/api/vimgrclusterruntime/${data.vsphere_compute_cluster.mgmt.id}-${avi_cloud.cloud.uuid}"
		]
		include		= true
	}
}
