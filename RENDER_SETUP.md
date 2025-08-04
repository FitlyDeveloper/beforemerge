# Setting Up OpenAI API Key on Render.com

This guide explains how to properly configure your OpenAI API key on Render.com to enable AI-powered food analysis in the app.

## Method 1: Using the Render.com Dashboard (Easiest)

1. Go to your [Render Dashboard](https://dashboard.render.com/) and log in
2. Select the `snap-food` service 
3. Click on the **Environment** tab in the left sidebar
4. Under "Environment Variables", click **Add Environment Variable**
5. Enter the following:
   - **Key**: `OPENAI_API_KEY`  
   - **Value**: Your OpenAI API key (starts with `sk-...`)
6. Click **Save Changes**
7. Go to the **Manual Deploy** button at the top right and select **Deploy latest commit**
8. Wait for the deployment to complete (about 1-2 minutes)
9. Test the API by opening your app and analyzing a food image

## Method 2: Using PowerShell Script (Windows)

1. Make sure you have a Render.com API key:
   - Go to your [Render Dashboard](https://dashboard.render.com/)
   - Click on your profile icon in the top right
   - Select **Account Settings**
   - Go to **API Keys**
   - Create a new API key if you don't have one

2. Run the `setup-render-env.ps1` script from the project folder:
   ```powershell
   .\setup-render-env.ps1
   ```

3. Enter your Render.com API key when prompted
4. Enter your OpenAI API key when prompted
5. Go to the Render dashboard and manually deploy the service

## Method 3: Using Bash Script (Mac/Linux)

1. Install the Render CLI:
   ```bash
   npm install -g @render/cli
   ```

2. Log in to Render:
   ```bash
   render login
   ```

3. Run the setup script:
   ```bash
   ./setup-render-env.sh
   ```

4. Enter your OpenAI API key when prompted
5. Go to the Render dashboard and manually deploy the service

## Verifying the Setup

To verify that your API key is properly configured:

1. Run the app and analyze a food image
2. If you see nutritional information displayed, it's working correctly
3. If you encounter a 401 error, the API key is not configured correctly

## Getting an OpenAI API Key

If you don't have an OpenAI API key:

1. Go to [platform.openai.com](https://platform.openai.com/)
2. Sign up or log in
3. Go to the API keys section
4. Create a new secret key
5. Copy the key (you won't be able to see it again)
6. Follow the steps above to configure it in Render.com 