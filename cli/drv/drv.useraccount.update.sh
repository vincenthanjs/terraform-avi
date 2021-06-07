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
		"username": "admin",
		"password": "VMware1!SDDC",
		"old_password": "58NFaGDJm(PJH0G"
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
