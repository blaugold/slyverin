#! /usr/bin/env bash

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$DIR/.."
EXAMPLE_DIR="$PROJECT_DIR/example"
EXAMPLE_BUILD_DIR="$PROJECT_DIR/example/build/web"
EXAMPLE_LIVE_DEMO_DIR="$PROJECT_DIR/docs/example_dist"

cd "$EXAMPLE_DIR"

flutter build web --pwa-strategy none

rm -rf "$EXAMPLE_LIVE_DEMO_DIR"
mkdir -p "$EXAMPLE_LIVE_DEMO_DIR"
cp -a "$EXAMPLE_BUILD_DIR/"* "$EXAMPLE_LIVE_DEMO_DIR"
