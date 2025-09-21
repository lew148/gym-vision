#!/bin/sh

# fail this script if any subcommand fails.
# set -ex

# print verbose failure on error
trap 'echo "[ERROR] Command failed on line $LINENO: $BASH_COMMAND"' ERR

# the default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# creation of ev file for environment variables
cat > .env <<EOL
SENTRY_DSN=$SENTRY_DSN
TODOIST_API_KEY=$TODOIST_API_KEY
EOL

# install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter clean
flutter precache --ios
flutter pub get

HOMEBREW_NO_AUTO_UPDATE=1

cd ios && pod install

# to flush build
flutter build ios

exit 0