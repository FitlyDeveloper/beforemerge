// Simple test file to verify server setup
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Print environment variables for debugging
console.log('Environment variables:');
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('Current directory:', process.cwd());
console.log('File location:', __dirname);
console.log('OpenAI API Key exists:', !!process.env.OPENAI_API_KEY);

// Define a simple health check route
app.get('/', (req, res) => {
  res.json({
    message: 'Test server is running',
    status: 'ok',
    env: process.env.NODE_ENV,
    apiKeyExists: !!process.env.OPENAI_API_KEY
  });
});

// Start the server
app.listen(PORT, () => {
  console.log(`Test server running on port ${PORT}`);
}); 