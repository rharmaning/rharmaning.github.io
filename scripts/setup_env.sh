#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${1:-$(pwd)}"
RUBY_VERSION="3.1.6"
BUNDLER_VERSION="2.6.3"

if [ ! -d "$REPO_DIR" ]; then
  echo "Repo path not found: $REPO_DIR" >&2
  exit 1
fi

if ! command -v rbenv >/dev/null 2>&1; then
  echo "rbenv not found. Install it first (brew install rbenv ruby-build)." >&2
  exit 1
fi

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - bash)"

cd "$REPO_DIR"

rbenv install -s "$RUBY_VERSION"
rbenv local "$RUBY_VERSION"
rbenv rehash || true

if ! bundle _${BUNDLER_VERSION}_ -v >/dev/null 2>&1; then
  rbenv exec gem install bundler -v "$BUNDLER_VERSION"
fi

SDKROOT="$(xcrun --show-sdk-path)"
RUBYOPT_FILE="/tmp/rubyopt_eventmachine.rb"
cat > "$RUBYOPT_FILE" <<RUBYOPT
require "rbconfig"
sdk = "${SDKROOT}"
flags = "-isysroot#{sdk} -I#{sdk}/usr/include/c++/v1"
RbConfig::CONFIG["CXX"] = "clang++"
RbConfig::MAKEFILE_CONFIG["CXX"] = "clang++"
RbConfig::CONFIG["CXXFLAGS"] = [RbConfig::CONFIG["CXXFLAGS"], flags].compact.join(" ")
RbConfig::MAKEFILE_CONFIG["CXXFLAGS"] = [RbConfig::MAKEFILE_CONFIG["CXXFLAGS"], flags].compact.join(" ")
RUBYOPT

RUBYOPT="-r$RUBYOPT_FILE" rbenv exec bundle _${BUNDLER_VERSION}_ install

echo "Setup complete. Ruby $(rbenv exec ruby -v) using Bundler ${BUNDLER_VERSION}."
