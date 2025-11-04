#!/bin/bash
set -e

# Build frontend script
# This script builds the frontend application using pnpm

echo "Building frontend application..."
cd apps/gpgui-helper

# Install dependencies
echo "Installing frontend dependencies..."
pnpm install

# Build the application
echo "Building frontend..."
pnpm build

echo "Frontend build completed successfully."
