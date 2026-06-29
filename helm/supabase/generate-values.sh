#!/bin/sh
#
# Generate secrets and keys for the Supabase Helm chart.
# Outputs a `custom-values.yaml` file you can use to install the Helm chart.
#

set -e

gen_hex() {
    openssl rand -hex "$1"
}

gen_base64() {
    openssl rand -base64 "$1"
}

base64_url_encode() {
    openssl enc -base64 -A | tr '+/' '-_' | tr -d '='
}

gen_token() {
    payload=$1
    payload_base64=$(printf %s "$payload" | base64_url_encode)
    header_base64=$(printf %s "$header" | base64_url_encode)
    signed_content="${header_base64}.${payload_base64}"
    signature=$(printf %s "$signed_content" | openssl dgst -binary -sha256 -hmac "$jwt_secret" | base64_url_encode)
    printf '%s' "${signed_content}.${signature}"
}

if ! command -v openssl >/dev/null 2>&1; then
    echo "Error: openssl is required but not found."
    exit 1
fi

jwt_secret="$(gen_base64 30)"
header='{"alg":"HS256","typ":"JWT"}'
iat=$(date +%s)
exp=$((iat + 5 * 3600 * 24 * 365)) # 5 years

anon_payload="{\"role\":\"anon\",\"iss\":\"supabase\",\"iat\":$iat,\"exp\":$exp}"
service_role_payload="{\"role\":\"service_role\",\"iss\":\"supabase\",\"iat\":$iat,\"exp\":$exp}"

anon_key=$(gen_token "$anon_payload")
service_role_key=$(gen_token "$service_role_payload")

secret_key_base=$(gen_base64 48)
vault_enc_key=$(gen_hex 16)
pg_meta_crypto_key=$(gen_base64 24)

s3_protocol_access_key_id=$(gen_hex 16)
s3_protocol_access_key_secret=$(gen_hex 32)

postgres_password=nnn000Nn
dashboard_password=nnn000Nn

cat <<EOF > custom-values.yaml
global:
  jwtSecret: "${jwt_secret}"
  anonKey: "${anon_key}"
  serviceRoleKey: "${service_role_key}"
  dashboardUsername: "supabase"
  dashboardPassword: "${dashboard_password}"
  postgresPassword: "${postgres_password}"
  secretKeyBase: "${secret_key_base}"
  vaultEncKey: "${vault_enc_key}"
  pgMetaCryptoKey: "${pg_meta_crypto_key}"
  s3ProtocolAccessKeyId: "${s3_protocol_access_key_id}"
  s3ProtocolAccessKeySecret: "${s3_protocol_access_key_secret}"
EOF

echo "Successfully generated custom-values.yaml with secure secrets!"
echo "Keep this file safe and do not commit it to version control."
