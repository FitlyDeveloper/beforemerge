#!/bin/bash
# Script to set up the deployment environment for Render.com

# Copy the server file to the root
cp api-server/server.js server.js

# Install required packages
npm install dotenv express cors node-fetch express-rate-limit

# Create a basic .env file if it doesn't exist
if [ ! -f .env ]; then
  echo "Creating .env file..."
  echo "# Configuration for Food Analyzer API" > .env
  echo "PORT=3000" >> .env
  echo "NODE_ENV=production" >> .env
  # Note: Don't store actual API keys in this script
  echo "# Add your OpenAI API key below" >> .env
  echo "OPENAI_API_KEY=your_api_key_here" >> .env
fi

echo "Setup complete! Make sure to add your actual OpenAI API key to the .env file." 