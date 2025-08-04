@echo off
echo Forcing deployment of Firebase functions...

cd functions
echo Updating package.json version to force redeployment
npm version patch --no-git-tag-version

cd ..
echo Deploying to Firebase
firebase deploy --only functions --force

echo Deployment completed!
pause 