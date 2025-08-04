#!/bin/bash

echo -e "\033[0;32mDeploying to Render.com...\033[0m"

# Check if Render CLI is installed
if ! command -v render &> /dev/null
then
    echo -e "\033[0;31mRender CLI not found. Please install it first.\033[0m"
    echo -e "\033[0;33mVisit https://render.com/docs/cli for installation instructions.\033[0m"
    exit 1
fi

# Force deploy to Render
echo -e "\033[0;36mTriggering deployment...\033[0m"
render deploy --yaml render.yaml

echo -e "\033[0;32mDeployment initiated. Check the Render dashboard for deployment status.\033[0m"
echo "Once deployed, your API will be available at:"
echo -e "\033[0;33m* https://snap-food.onrender.com\033[0m"
echo -e "\033[0;33m* https://deepseek-uhrc.onrender.com\033[0m" 