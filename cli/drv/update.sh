#PUT https://avic.lab01.one/api/useraccount

## login
AVIUSER="admin"
NEWPASS="VMware1!SDDC"
AVIPASS="58NFaGDJm(PJH0G"
ENDPOINT="avic.lab01.one"
LOGINHEADERS=$(curl -kvs -X POST \
	--data-urlencode "username=${AVIUSER}" \
	--data-urlencode "password=${AVIPASS}" \
"https://${ENDPOINT}/login" 2>&1 | grep set-cookie)

## get cookies
if [[ $LOGINHEADERS =~ csrftoken\=([A-Za-z0-9]+) ]]; then
	CSRFTOKEN=${BASH_REMATCH[1]}
fi
printf "%s\n" "X-CSRFToken	[[ ${CSRFTOKEN} ]]"
if [[ $LOGINHEADERS =~ avi-sessionid\=([A-Za-z0-9]+) ]]; then
	SESSIONID=${BASH_REMATCH[1]}
fi
printf "%s\n" "avi-sessionid	[[ ${SESSIONID} ]]"

## update password
if [[ -n "${CSRFTOKEN}" && -n "${SESSIONID}" ]]; then
	read -r -d '' BODY <<-CONFIG
	{
		"username": "${AVIUSER}",
		"password": "${NEWPASS}",
		"old_password": "${AVIPASS}"
	}
	CONFIG
	curl -k -X PUT \
		-b "sessionid=${SESSIONID};csrftoken=${CSRFTOKEN}" \
		-H "Referer: https://avic.lab01.one" \
		-H "X-Avi-Version: 20.1.5" \
		-H "X-CSRFToken: ${CSRFTOKEN}" \
		-H "Content-Type: application/json" \
		--data "${BODY}" \
	"https://${ENDPOINT}/api/useraccount"
	echo "user [ ${AVIUSER} ] updated with password [ ${NEWPASS} ]"
else
	echo "CSRFTOKEN or SESSIONID missing - check credentials"
fi
