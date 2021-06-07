#!/bin/bash
if [[ $0 =~ ^(.*)/[^/]+$ ]]; then
	WORKDIR=${BASH_REMATCH[1]}
fi
source ${WORKDIR}/drv.avi.test
source ${WORKDIR}/mod.driver

# inputs
ITEM="useraccount"
INPUTS=()

# body
function makeBody {
	read -r -d '' BODY <<-CONFIG
	{
		"url": "https://avic.lab01.one/api/systemconfiguration",
		"uuid": "default",
		"dns_configuration": {
			"search_domain": "lab01.one",
			"server_list": [
				{
					"addr": "172.16.10.1",
					"type": "V4"
				}
			]
		},
		"ntp_configuration": {
			"ntp_servers": [
				{
					"server": {
						"addr": "0.us.pool.ntp.org",
						"type": "DNS"
					}
				},
				{
					"server": {
						"addr": "1.us.pool.ntp.org",
						"type": "DNS"
					}
				},
				{
					"server": {
						"addr": "2.us.pool.ntp.org",
						"type": "DNS"
					}
				},
				{
					"server": {
						"addr": "3.us.pool.ntp.org",
						"type": "DNS"
					}
				}
			],
			"ntp_server_list": [],
			"ntp_authentication_keys": []
		},
		"portal_configuration": {
			"enable_https": true,
			"redirect_to_https": true,
			"enable_http": true,
			"use_uuid_from_input": false,
			"enable_clickjacking_protection": true,
			"allow_basic_authentication": false,
			"password_strength_check": true,
			"disable_remote_cli_shell": false,
			"disable_swagger": false,
			"api_force_timeout": 24,
			"minimum_password_length": 8,
			"sslkeyandcertificate_refs": [
				"https://avic.lab01.one/api/sslkeyandcertificate/sslkeyandcertificate-566dd534-949f-4a58-b894-961c81effe35#System-Default-Portal-Cert",
				"https://avic.lab01.one/api/sslkeyandcertificate/sslkeyandcertificate-71812805-fc48-4175-bf86-7514e9768cec#System-Default-Portal-Cert-EC256"
			],
			"sslprofile_ref": "https://avic.lab01.one/api/sslprofile/sslprofile-3d234b89-5381-469d-ad82-9da4594fcbe1#System-Standard-Portal"
		},
		"global_tenant_config": {
			"tenant_vrf": false,
			"se_in_provider_context": true,
			"tenant_access_to_provider_se": true
		},
		"email_configuration": {
			"smtp_type": "SMTP_LOCAL_HOST",
			"from_email": "admin@avicontroller.net"
		},
		"docker_mode": false,
		"ssh_ciphers": [
			"aes128-ctr",
			"aes256-ctr"
		],
		"ssh_hmacs": [
			"hmac-sha2-512-etm@openssh.com",
			"hmac-sha2-256-etm@openssh.com",
			"hmac-sha2-512"
		],
		"default_license_tier": "ENTERPRISE",
		"secure_channel_configuration": {
			"sslkeyandcertificate_refs": [
				"https://avic.lab01.one/api/sslkeyandcertificate/sslkeyandcertificate-c2a3209b-4c57-4100-98a6-738a2a0afb9c#System-Default-Secure-Channel-Cert"
			]
		},
		"welcome_workflow_complete": false,
		"fips_mode": false,
		"enable_cors": false,
		"common_criteria_mode": false
	}
	CONFIG
	printf "${BODY}"
}

# run
run() {
	BODY=$(makeBody)
	URL=$(buildURL "${ITEM}")
	echo "<<< ${URL} >>>"
	if [[ -n "${URL}" ]]; then
		printf "[$(cgreen "INFO")]: avi [$(cgreen "list")] ${ITEM} [$(cgreen "$URL")]... " 1>&2
		aviPut "${URL}" "${BODY}"
	fi
}

# driver
driver "${@}"
