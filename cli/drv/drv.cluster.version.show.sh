#!/bin/bash
if [[ $0 =~ ^(.*)/[^/]+$ ]]; then
	WORKDIR=${BASH_REMATCH[1]}
fi
source ${WORKDIR}/drv.avi.test
source ${WORKDIR}/mod.driver

# inputs
ITEM="cluster/version"
INPUTS=()

# run
run() {
	URL=$(buildURL "${ITEM}")
	if [[ -n "${URL}" ]]; then
		printf "[$(cgreen "INFO")]: avi [$(cgreen "list")] ${ITEM} [$(cgreen "$URL")]... " 1>&2
		aviGet "${URL}"
	fi
}

# driver
driver "${@}"
