#!/bin/bash
# Check if offline mode is enabled for PPA build

if [ "$OFFLINE" -ne 1 ]; then
  echo "Error: ppa build requires offline mode (OFFLINE=1)"
  exit 1
fi
