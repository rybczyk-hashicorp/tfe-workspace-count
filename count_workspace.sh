#!/usr/bin/env bash
TFE_HOST="HOSTNAME" # This will either be your TFE server or HCP URL, keep the quotes
TOKEN="TOKEN"   # Change TOKEN to a valid token, keep the quotes here too
TOTAL=0
# Get all organizations
ORGS=$(curl -s \
 --header "Authorization: Bearer $TOKEN" \
 https://$TFE_HOST/api/v2/organizations | jq -r '.data[].id')
for ORG in $ORGS; do
 echo "Checking org: $ORG"
 NEXT_URL="https://$TFE_HOST/api/v2/organizations/$ORG/workspaces"
 ORG_COUNT=0
 # Follow pagination
 while [ -n "$NEXT_URL" ] && [ "$NEXT_URL" != "null" ]; do
  RESPONSE=$(curl -s --header "Authorization: Bearer $TOKEN" "$NEXT_URL")
  COUNT=$(echo "$RESPONSE" | jq '.data | length')
  ORG_COUNT=$((ORG_COUNT + COUNT))
  NEXT_URL=$(echo "$RESPONSE" | jq -r '.links.next')
 done
 echo " Workspaces: $ORG_COUNT"
 TOTAL=$((TOTAL + ORG_COUNT))
done
echo "=========================="
echo "Total workspaces in use: $TOTAL"
