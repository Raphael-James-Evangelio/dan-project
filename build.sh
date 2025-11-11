#!/bin/bash
set -e

# Function to run commands that might fail but shouldn't stop the build
run_safe() {
    "$@" || true
}

echo "Installing Flutter..."

# Determine project directory
PROJECT_DIR="${VERCEL_SOURCE_DIR:-$(pwd)}"
cd "$PROJECT_DIR"

# Install Flutter SDK (using a stable version)
FLUTTER_VERSION="3.24.0"
FLUTTER_SDK="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_SDK}"

echo "Downloading Flutter ${FLUTTER_VERSION}..."

# Create temp directory for Flutter
FLUTTER_DIR="/tmp/flutter"
mkdir -p "$FLUTTER_DIR"

# Download Flutter using curl (more widely available than wget)
cd /tmp
if command -v curl &> /dev/null; then
    curl -L "${FLUTTER_URL}" -o "${FLUTTER_SDK}"
elif command -v wget &> /dev/null; then
    wget -q "${FLUTTER_URL}" -O "${FLUTTER_SDK}"
else
    echo "Error: Neither curl nor wget is available"
    exit 1
fi

# Extract Flutter
tar xf "${FLUTTER_SDK}"

# Fix Git ownership issues (required when running as root)
echo "Configuring Git for Flutter..."
# Configure Git to trust the Flutter directory (must be done before using Flutter)
git config --global --add safe.directory /tmp/flutter
git config --global --add safe.directory '*'
# Fix permissions on Flutter directory
chmod -R u+w /tmp/flutter 2>/dev/null || true

# Set Flutter path
FLUTTER_BIN="/tmp/flutter/bin/flutter"
export PATH="$PATH:/tmp/flutter/bin"

# Set environment variables to help Flutter work in CI
export FLUTTER_GIT_URL="https://github.com/flutter/flutter.git"
export PUB_CACHE="/tmp/.pub-cache"
export FLUTTER_ROOT="/tmp/flutter"

# Configure Flutter to disable analytics and animations (non-interactive)
echo "Configuring Flutter..."
run_safe "$FLUTTER_BIN" config --no-analytics
run_safe "$FLUTTER_BIN" config --no-cli-animations

# Verify installation (this may show warnings but should work)
echo "Verifying Flutter installation..."
"$FLUTTER_BIN" --version 2>&1 | head -5 || echo "Version check had issues, but continuing..."

# Precache Flutter web dependencies (skip if it fails)
echo "Precaching Flutter web dependencies..."
"$FLUTTER_BIN" precache --web || true

# Run flutter doctor (non-blocking, ignore errors)
"$FLUTTER_BIN" doctor || true

# Navigate back to project directory
cd "$PROJECT_DIR"

# Get dependencies
echo "Getting Flutter dependencies..."
# Use --no-example to avoid unnecessary dependencies
"$FLUTTER_BIN" pub get --no-example || "$FLUTTER_BIN" pub get

# Build for web
echo "Building Flutter web app..."
"$FLUTTER_BIN" build web --release

echo "Build completed successfully!"

