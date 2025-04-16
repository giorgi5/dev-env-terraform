#!/bin/bash
OIDC_URL=$(jq -r '.oidc_url' <&0)
THUMBPRINT=$(echo | openssl s_client -connect ${OIDC_URL#https://}:443 -servername ${OIDC_URL#https://} 2>/dev/null \
  | openssl x509 -fingerprint -noout \
  | cut -d"=" -f2 \
  | tr -d ':')

jq -n --arg thumbprint "$THUMBPRINT" '{"thumbprint":$thumbprint}'