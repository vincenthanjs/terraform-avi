#!/bin/bash
URL="https://$ENDPOINT"
CSRFREGEX='csrftoken=([A-Za-z0-9]+)'
while [[ -z $CSRFTOKEN ]]; do
	CSRFHEADER=$(curl -kvs -X GET "$URL" 2>&1 | grep -i set-cookie | grep csrftoken)
	if [[ $CSRFHEADER =~ $CSRFREGEX ]]; then
		CSRFTOKEN=${BASH_REMATCH[1]}
		printf "%s\n" "X-CSRFToken [[ $CSRFTOKEN ]]"
	else
		printf "%s\n" "Waiting for API [$URL] to respond.. sleep 30"
		sleep 30
	fi
done
