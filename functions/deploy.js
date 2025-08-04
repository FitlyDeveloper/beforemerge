/**
 * Simple script to force deploy Firebase functions
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('Starting forced Firebase Functions deployment');

// Read the current package.json
const packagePath = path.join(__dirname, 'package.json');
const packageJson = JSON.parse(fs.readFileSync(packagePath, 'utf8'));

// Update the version
const versionParts = packageJson.version.split('.');
versionParts[2] = parseInt(versionParts[2], 10) + 1;
packageJson.version = versionParts.join('.');

console.log(`Updating version to ${packageJson.version}`);

// Write the updated package.json
fs.writeFileSync(packagePath, JSON.stringify(packageJson, null, 2), 'utf8');

// Set necessary config values (only if needed)
if (!process.env.OPENAI_API_KEY) {
  console.log('Setting Firebase config values...');
  try {
    // Try to set config, but don't worry if it fails
    const setApiKeyExampleCommand = 'firebase functions:config:set openai.api_key="YOUR_API_KEY_HERE"';
    execSync(setApiKeyExampleCommand, {
      stdio: 'inherit'
    });
  } catch (error) {
    console.warn('Warning: Could not set config values (this is not critical)');
  }
}

// Run the deploy command
try {
  console.log('Deploying functions with forced deploy...');
  execSync('cd .. && firebase deploy --only functions:echoTest,functions:analyzeImageSimple,functions:analyzeFoodImage,functions:testEndpoint --force', { stdio: 'inherit' });
  console.log('Deployment completed successfully');
} catch (error) {
  console.error('Deployment failed:', error.message);
  process.exit(1);
} 