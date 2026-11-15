#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Keep the preview's preferences and Launch Services identity separate from
# the installed upstream app. Do not inherit the upstream Sparkle feed or key.
export BEADAZZLE_APP_NAME="Beadlane Preview"
export BEADAZZLE_BUNDLE_ID="com.github.andrew-bierman.beadlane.preview"
export BEADAZZLE_SPARKLE_FEED_URL=""
export BEADAZZLE_SPARKLE_PUBLIC_KEY=""

exec "$SCRIPT_DIR/build_app_bundle.sh" --configuration debug --codesign-identity - "$@"
