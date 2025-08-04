#!/bin/bash

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Deploying Firebase Functions...${NC}"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}Node.js is not installed. Please install Node.js first.${NC}"
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}Firebase CLI is not installed. Please install it with: npm install -g firebase-tools${NC}"
    exit 1
fi

# Check if Firebase is logged in
firebase projects:list &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}You are not logged in to Firebase. Please login with: firebase login${NC}"
    exit 1
fi

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
npm install

# Check if OpenAI API key is configured
echo -e "${YELLOW}Checking for OpenAI API key...${NC}"
OPENAI_API_KEY=$(firebase functions:config:get openai.api_key 2>/dev/null || echo "{}")

if [[ -z "$OPENAI_API_KEY" || "$OPENAI_API_KEY" == "{}" ]]; then
    echo -e "${RED}OpenAI API key is not configured.${NC}"
    echo -e "${YELLOW}Please enter your OpenAI API key:${NC}"
    read -s openai_api_key
    
    if [[ -z "$openai_api_key" ]]; then
        echo -e "${RED}No OpenAI API key provided. Aborting deployment.${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Setting OpenAI API key...${NC}"
    firebase functions:config:set openai.api_key="$openai_api_key"
else
    echo -e "${GREEN}OpenAI API key is configured.${NC}"
fi

# Deploy functions
echo -e "${YELLOW}Deploying Firebase Functions...${NC}"
firebase deploy --only functions

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Deployment successful!${NC}"
    echo -e "${YELLOW}Functions available:${NC}"
    echo -e "- analyzeFoodImage"
    echo -e ""
    echo -e "API Keys configured:"
    echo -e "- OpenAI API Key: ✅"
else
    echo -e "${RED}Deployment failed. Please check the error message above.${NC}"
    exit 1
fi

# Instructions for local testing
echo -e "${YELLOW}For local testing:${NC}"
echo -e "1. Run 'firebase functions:config:get > .runtimeconfig.json'"
echo -e "2. Run 'firebase emulators:start --only functions'"

echo -e "${GREEN}Done!${NC}" 