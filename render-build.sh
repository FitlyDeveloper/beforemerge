#!/usr/bin/env bash
# Exit on error
set -o errexit

echo "Starting build script..."

# Install dependencies 
npm install

# Make sure we have express-rate-limit and node-fetch
npm install express-rate-limit node-fetch

# Copy the correct server.js file
cp api-server/server.js server.js

echo "Build completed successfully!" 