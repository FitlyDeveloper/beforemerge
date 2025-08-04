#!/bin/bash

# Flutter project dependency installer

echo "Installing Flutter dependencies for the project..."

# Update packages first
flutter pub get

# Check if path_provider was installed
if grep -q "path_provider" pubspec.yaml; then
  echo "path_provider already in pubspec.yaml"
else
  echo "Adding path_provider to dependencies..."
  sed -i '/dependencies:/a \  path_provider: ^2.1.2' pubspec.yaml
  flutter pub get
fi

# Check for cloud_functions
if grep -q "cloud_functions" pubspec.yaml; then
  echo "cloud_functions already in pubspec.yaml"
else
  echo "Adding cloud_functions to dependencies..."
  sed -i '/dependencies:/a \  cloud_functions: ^5.4.0' pubspec.yaml
  flutter pub get
fi

echo "Setting up Firebase functions..."
cd functions
npm install
cd ..

echo "All dependencies installed!"
echo "To deploy Firebase functions, run: cd functions && ./deploy.sh" 