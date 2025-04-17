#!/bin/bash

OIDC_URL=$(jq -r '.oidc_url' <&0)
HOST=$(echo "$OIDC_URL" | awk -F/ '{print $3}') # Extract domain only

# Fetch thumbprint and clean format
THUMBPRINT=$(echo | openssl s_client -servername "$HOST" -connect "$HOST:443" 2>/dev/null \
  | openssl x509 -fingerprint -noout -sha1 \
  | cut -d'=' -f2 | tr -d ':' | tr 'A-Z' 'a-z')

if [ ${#THUMBPRINT} -ne 40 ]; then
  echo "Invalid thumbprint length: $THUMBPRINT" >&2
  exit 1
fi

jq -n --arg thumbprint "$THUMBPRINT" '{"thumbprint":$thumbprint}'
