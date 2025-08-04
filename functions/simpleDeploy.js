/**
 * Ultra simple script to deploy the analyzeFoodImage function
 */

const { execSync } = require('child_process');

try {
  console.log('Deploying only the analyzeFoodImage function...');
  execSync('firebase deploy --only functions:analyzeFoodImage', { 
    stdio: 'inherit'
  });
  console.log('Deployment completed!');
} catch (error) {
  console.error('Deployment failed:', error.message);
} 