#!/bin/sh

# Fail this script if any subcommand fails.
set -ex

# print verbose failure on error
trap 'echo "[ERROR] Command failed on line $LINENO: $BASH_COMMAND"' ERR

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"


# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter clean
flutter precache --ios
flutter pub get

HOMEBREW_NO_AUTO_UPDATE=1

cd ios && pod install

# to flush build
flutter build ios

exit 0