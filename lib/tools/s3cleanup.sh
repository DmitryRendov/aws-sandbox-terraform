#!/bin/bash

BUCKET=sb-production-serverless-6e9141321b09
PROFILE=production

while : ; do
  # Get versions and delete markers
  OUTPUT=$(aws s3api list-object-versions --bucket "$BUCKET" --profile "$PROFILE")
  VERSIONS=$(echo "$OUTPUT" | jq '.Versions')
  DELETE_MARKERS=$(echo "$OUTPUT" | jq '.DeleteMarkers')

  # Build delete objects JSON
  OBJECTS=$(jq -n \
    --argjson versions "$VERSIONS" \
    --argjson markers "$DELETE_MARKERS" \
    '{Objects: ($versions + $markers | map({Key: .Key, VersionId: .VersionId})), Quiet: false}')

  # Check if there is anything to delete
  COUNT=$(echo "$OBJECTS" | jq '.Objects | length')
  if [ "$COUNT" -eq 0 ]; then
    echo "No more objects to delete."
    break
  fi

  # Delete objects
  aws s3api delete-objects --bucket "$BUCKET" --profile "$PROFILE" --delete "$OBJECTS"

  # Check for pagination
  NEXT_KEY_MARKER=$(echo "$OUTPUT" | jq -r '.NextKeyMarker // empty')
  NEXT_VERSION_ID_MARKER=$(echo "$OUTPUT" | jq -r '.NextVersionIdMarker // empty')
  if [ -z "$NEXT_KEY_MARKER" ]; then
    break
  fi

  # Prepare for next iteration
  OUTPUT=$(aws s3api list-object-versions \
    --bucket "$BUCKET" \
    --profile "$PROFILE" \
    --key-marker "$NEXT_KEY_MARKER" \
    --version-id-marker "$NEXT_VERSION_ID_MARKER")
done
