#!/bin/bash

# Setup script for CI/CD environments
# Creates missing configuration files with safe defaults

echo "Setting up CI configuration..."

# Ensure auth config exists
dart scripts/ensure_config.dart

echo "CI setup complete!"