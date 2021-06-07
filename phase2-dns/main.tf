## provider setup
terraform {                                                                        
	required_providers {
		avi	= {
			source  = "vmware/avi"
			version = ">= 20.1.5"
		}
	}
}
provider "avi" {
	avi_controller		= var.avi_server
	avi_username		= var.avi_username
	avi_password		= var.avi_password
	avi_tenant		= "admin"
	avi_version		= "20.1.5"
}

## avi data objects
data "avi_tenant" "admin" {
	name	= "admin"
}
data "avi_cloud" "vmware" {
	name	= var.cloud_name
}
data "avi_cloud" "default" {
	name	= "Default-Cloud"
}
data "avi_serviceenginegroup" "mgmt" {
	name	= "mgmt-se-group"
}
data "avi_applicationprofile" "system-dns" {
	name	= "System-DNS"
}
data "avi_networkprofile" "system-udp-per-pkt" {
	name	= "System-UDP-Per-Pkt"
}
data "avi_vrfcontext" "default" {
	cloud_ref = data.avi_cloud.default.id
}
data "avi_vrfcontext" "vmware" {
	cloud_ref = data.avi_cloud.vmware.id
}

## create the avi vip
resource "avi_vsvip" "dns" {
	name		= "tf-vip-ns1"
	tenant_ref	= data.avi_tenant.admin.id
	cloud_ref	= data.avi_cloud.vmware.id

	# static vip IP address
	vip {
		vip_id = "0"
		ip_address {
			type = "V4"
			addr = "172.16.10.120"
		}
	}
}

## create the dns virtual service and attach vip
resource "avi_virtualservice" "dns1" {
	name			= "tf-vs-ns1"
	tenant_ref		= data.avi_tenant.admin.id
	cloud_ref		= data.avi_cloud.vmware.id
	vsvip_ref		= avi_vsvip.dns.id
	application_profile_ref	= data.avi_applicationprofile.system-dns.id
	network_profile_ref	= data.avi_networkprofile.system-udp-per-pkt.id
	se_group_ref		= data.avi_serviceenginegroup.mgmt.id
	enabled			= true
	services {
		port           = 53
	}
}
