#!/usr/bin/env bash
# usage: upload-frontend.sh <dist-dir> <bucket> <version>
set -euo pipefail

SRC="$1"
BUCKET="$2"
VERSION="$3"

# The UI files are not hashed (assets/js/app.js keeps its name between releases),
# so browsers get a short cache. Each release still lives under its own prefix,
# so CloudFront serves the right build once the version pointer is switched.
aws s3 sync "$SRC" "s3://$BUCKET/$VERSION" \
  --exclude "*.html" --exclude "version.txt" \
  --cache-control "public,max-age=300"

# HTML pages and the version stamp must never be served stale.
aws s3 sync "$SRC" "s3://$BUCKET/$VERSION" \
  --exclude "*" --include "*.html" --include "version.txt" \
  --cache-control "no-cache"
