#!/bin/sh
set -e

trap 'echo "[ERROR] Command failed on line $LINENO"' ERR

cd "$CI_PRIMARY_REPOSITORY_PATH"

# ── Flutter Setup ────────────────────────────────────────────────────────────
# Cache flutter between runs using CI_DERIVED_DATA_PATH (persists across builds)
FLUTTER_ROOT="$CI_DERIVED_DATA_PATH/flutter"

if [ ! -d "$FLUTTER_ROOT" ]; then
  echo "Flutter not cached — cloning..."
  git clone https://github.com/flutter/flutter.git \
    --depth 1 \
    -b stable \
    --single-branch \
    "$FLUTTER_ROOT"
else
  echo "Flutter found in cache — skipping clone"
fi

export PATH="$PATH:$FLUTTER_ROOT/bin"

# ── Validate Required Secrets ─────────────────────────────────────────────────
: "${SENTRY_DSN:?SENTRY_DSN secret is not set}"
: "${TODOIST_API_KEY:?TODOIST_API_KEY secret is not set}"

# ── Write .env File ───────────────────────────────────────────────────────────
cat > .env <<EOL
SENTRY_DSN=$SENTRY_DSN
TODOIST_API_KEY=$TODOIST_API_KEY
EOL

# ── Flutter Build Prep ────────────────────────────────────────────────────────
flutter clean
flutter precache --ios
flutter pub get

# ── CocoaPods ─────────────────────────────────────────────────────────────────
export HOMEBREW_NO_AUTO_UPDATE=1
export COCOAPODS_DISABLE_STATS=1   # skip telemetry, speeds up pod install

cd ios
# Restore pod cache if available (avoids redundant downloads)
pod install --repo-update # ensures specs repo is fresh for TestFlight builds

exit 0