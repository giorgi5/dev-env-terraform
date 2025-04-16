#!/bin/bash

OIDC_URL=$(jq -r '.oidc_url' <&0)
HOST=$(echo "$OIDC_URL" | sed 's|https://||')

THUMBPRINT=$(echo | openssl s_client -servername "$HOST" -connect "$HOST:443" 2>/dev/null \
  | openssl x509 -fingerprint -noout -sha1 \
  | cut -d'=' -f2 | tr -d ':' | tr 'A-Z' 'a-z')

# Ensure it outputs a 40-character string
if [ ${#THUMBPRINT} -ne 40 ]; then
  echo "Failed to generate valid thumbprint" >&2
  exit 1
fi

jq -n --arg thumbprint "$THUMBPRINT" '{"thumbprint":$thumbprint}'