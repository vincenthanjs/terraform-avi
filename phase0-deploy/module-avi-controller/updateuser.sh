#!/bin/bash
## login
#AVIUSER="admin"
#NEWPASS="VMware1!SDDC"
#OLDPASS="58NFaGDJm(PJH0G"
#ENDPOINT="avic.lab01.one"
LOGINHEADERS=$(curl -kvs -X POST \
	--data-urlencode "username=$AVIUSER" \
	--data-urlencode "password=$OLDPASS" \
"https://$ENDPOINT/login" 2>&1 | grep -i set-cookie)

## get cookies
CSRFREGEX='csrftoken=([A-Za-z0-9]+)'
if [[ $LOGINHEADERS =~ $CSRFREGEX ]]; then
	CSRFTOKEN=${BASH_REMATCH[1]}
fi
printf "%s\n" "X-CSRFToken	[[ $CSRFTOKEN ]]"
SESSIONREGEX='avi-sessionid\=([A-Za-z0-9]+)'
if [[ $LOGINHEADERS =~ $SESSIONREGEX ]]; then
	SESSIONID=${BASH_REMATCH[1]}
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
		-H "Referer: https://$ENDPOINT" \
		-H "X-Avi-Version: 20.1.6" \
		-H "X-CSRFToken: $CSRFTOKEN" \
		-H "Content-Type: application/json" \
		--data "$BODY" \
	"https://$ENDPOINT/api/useraccount"
	echo "user [ $AVIUSER ] updated with password [ $NEWPASS ]"
else
	echo "CSRFTOKEN or SESSIONID missing - check credentials"
fi
