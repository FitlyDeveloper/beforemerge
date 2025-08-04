#!/bin/bash

# Script to set up OpenAI API Key on Render.com
# You need to have render-cli installed and be logged in

# Check if render-cli is installed
if ! command -v render &> /dev/null; then
    echo "Error: render-cli is not installed"
    echo "Install it with: npm install -g @render/cli"
    exit 1
fi

# Check if logged in
render whoami || {
    echo "Please log in to Render first: render login"
    exit 1
}

# Prompt for OpenAI API Key
echo "Please enter your OpenAI API Key (starts with 'sk-'):"
read -s OPENAI_API_KEY

if [[ -z "$OPENAI_API_KEY" ]]; then
    echo "Error: API Key cannot be empty"
    exit 1
fi

if [[ ! "$OPENAI_API_KEY" =~ ^sk- ]]; then
    echo "Warning: OpenAI API keys usually start with 'sk-'. Are you sure this is correct?"
    read -p "Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting."
        exit 1
    fi
fi

# Set the environment variable on Render
echo "Setting OpenAI API Key on Render.com..."
render env set OPENAI_API_KEY="$OPENAI_API_KEY" -s snap-food

echo "Done! Your OpenAI API Key has been set on Render.com."
echo "You need to redeploy your service for the changes to take effect."
echo "Go to the Render dashboard and click 'Manual Deploy' > 'Deploy latest commit'" 