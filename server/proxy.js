// This file exists only as a compatibility layer
// Render.com is still trying to run proxy.js based on the logs
// This will load our actual server code from index.js

console.log('Starting server via proxy.js compatibility layer...');
console.log('Redirecting to index.js');

// Load the actual server code
require('./index.js'); 