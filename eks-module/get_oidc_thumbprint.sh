#!/bin/bash
OIDC_URL=$(jq -r '.oidc_url' <&0)
HOST=$(echo "$OIDC_URL" | sed 's|https://||')

THUMBPRINT=$(echo | \
  openssl s_client -servername "$HOST" -connect "$HOST:443" 2>/dev/null | \
  openssl x509 -fingerprint -noout -sha1 | \
  cut -d'=' -f2 | tr -d ':' | tr 'A-Z' 'a-z')

jq -n --arg thumbprint "$THUMBPRINT" '{"thumbprint":$thumbprint}'