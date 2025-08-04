// Import required packages
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const fetch = require('node-fetch');

// Create Express app
const app = express();
const PORT = process.env.PORT || 3000;

// Debug startup
console.log('Starting server...');
console.log('Node environment:', process.env.NODE_ENV);
console.log('Current directory:', process.cwd());
console.log('OpenAI API Key present:', process.env.OPENAI_API_KEY ? 'Yes' : 'No');

// Configure rate limiting
const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: process.env.RATE_LIMIT || 30, // Limit each IP to 30 requests per minute
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  message: {
    status: 429,
    message: 'Too many requests, please try again later.'
  }
});

// Get allowed origins from environment or use default
const allowedOrigins = process.env.ALLOWED_ORIGINS 
  ? process.env.ALLOWED_ORIGINS.split(',') 
  : ['http://localhost:3000'];

// Configure CORS
app.use(cors({
  origin: function(origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    
    // Check if the origin is allowed
    if (allowedOrigins.indexOf(origin) === -1) {
      const msg = 'The CORS policy for this site does not allow access from the specified Origin.';
      return callback(new Error(msg), false);
    }
    return callback(null, true);
  },
  methods: ['POST'],
  credentials: true
}));

// Body parser middleware
app.use(express.json({ limit: '10mb' }));

// Middleware to check for OpenAI API key
const checkApiKey = (req, res, next) => {
  if (!process.env.OPENAI_API_KEY) {
    console.error('OpenAI API key not configured');
    return res.status(500).json({
      success: false,
      error: 'Server configuration error: OpenAI API key not set'
    });
  }
  console.log('OpenAI API key verified');
  next();
};

// Define routes
app.get('/', (req, res) => {
  console.log('Health check endpoint called');
  res.json({
    message: 'Food Analyzer API Server',
    status: 'operational'
  });
});

// OpenAI proxy endpoint for food analysis
app.post('/api/analyze-food', limiter, checkApiKey, async (req, res) => {
  try {
    console.log('Analyze food endpoint called');
    const { image } = req.body;

    if (!image) {
      console.error('No image provided in request');
      return res.status(400).json({
        success: false,
        error: 'Image data is required'
      });
    }

    // Debug logging
    console.log('Received image data, length:', image.length);
    console.log('Image data starts with:', image.substring(0, 50));

    // Call OpenAI API
    console.log('Calling OpenAI API...');
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
      },
      body: JSON.stringify({
        model: 'gpt-4o',
        messages: [
          {
            role: 'system',
            content: '[PRECISION NUTRITIONIST WITH PHD IN ANALYTICAL CHEMISTRY] You are a highly precise nutrition analyst with a PhD in analytical chemistry. You MUST follow these exact rules when analyzing food:\n\n1. NEVER ROUND measurements - use precise, irregular values with EXACTLY 2 decimal places\n2. All values MUST end with 2 decimal places (e.g., 27.32g not 27g or 27.3g)\n3. NEVER use values divisible by 5 or 10 - these are scientifically invalid\n4. For every value you determine, SUBTRACT or ADD a random offset between 1.01-4.99\n5. CALORIES must be particularly precise (e.g. 327.83, 542.76) and NEVER end in 0 or 5\n6. MACRONUTRIENTS must all have 2 decimal places (protein: 27.32g, carbs: 65.78g)\n7. Your scientific reputation depends on precise, irregular values that look like laboratory measurements\n\nJSON format with ultra-precise measurements:\n{"meal":[{"dish":"Name","calories":542.76,"macronutrients":{"protein":27.32,"carbohydrates":65.78,"fat":23.17},"ingredients":["item1","item2"]}]}'
          },
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: "URGENT ANALYTICAL CHEMISTRY NUTRITIONAL ANALYSIS: Analyze this food with LABORATORY PRECISION.\n\nCRITICAL SCIENTIFIC REQUIREMENTS:\n1. ALL values MUST have EXACTLY 2 decimal places (27.32g, not 27g or 27.3g)\n2. NO values can be divisible by 5 or 10 (avoid 25.00, 30.00, 100.00, 500.00)\n3. Numbers MUST appear randomly generated like laboratory measurements\n4. CALORIES must look precise (e.g., 327.83, 542.76, 416.29) - never round values\n5. MACRONUTRIENTS must all use 2 decimal places (protein: 27.32g, carbs: 65.78g)\n6. The last digit CANNOT be 0 or 5 for any measurement\n7. Food biochemistry produces complex irregular values - reflect this complexity\n\nSCIENTIFICALLY ACCURATE EXAMPLES:\n- Calories: 542.76 (NOT 540 or 550 or 542.8)\n- Protein: 27.32g (NOT 25g, 27g, or 27.3g)\n- Carbs: 65.78g (NOT 65g, 70g, or 65.8g)\n- Fat: 23.17g (NOT 23g, 25g, or 23.2g)\n\nYour scientific reputation and laboratory accuracy are at stake!"
              },
              {
                type: 'image_url',
                image_url: { url: image }
              }
            ]
          }
        ],
        max_tokens: 1000
      })
    });

    if (!response.ok) {
      const errorData = await response.text();
      console.error('OpenAI API error:', response.status, errorData);
      return res.status(response.status).json({
        success: false,
        error: `OpenAI API error: ${response.status}`
      });
    }

    console.log('OpenAI API response received');
    const data = await response.json();
    
    if (!data.choices || 
        !data.choices[0] || 
        !data.choices[0].message || 
        !data.choices[0].message.content) {
      console.error('Invalid response format from OpenAI:', JSON.stringify(data));
      return res.status(500).json({
        success: false,
        error: 'Invalid response from OpenAI'
      });
    }

    const content = data.choices[0].message.content;
    console.log('OpenAI API response content:', content.substring(0, 100) + '...');
    
    // Process and parse the response
    try {
      // First try direct parsing
      const parsedData = JSON.parse(content);
      console.log('Successfully parsed JSON response');
      return res.json({
        success: true,
        data: parsedData
      });
    } catch (error) {
      console.log('Direct JSON parsing failed, attempting to extract JSON from text');
      // Try to extract JSON from the text
      const jsonMatch = content.match(/```json\n([\s\S]*?)\n```/) || 
                      content.match(/\{[\s\S]*\}/);
      
      if (jsonMatch) {
        const jsonContent = jsonMatch[0].replace(/```json\n|```/g, '').trim();
        try {
          const parsedData = JSON.parse(jsonContent);
          console.log('Successfully extracted and parsed JSON from text');
          return res.json({
            success: true,
            data: parsedData
          });
        } catch (err) {
          console.error('JSON extraction failed:', err);
          // Return the raw text if JSON parsing fails
          return res.json({
            success: true,
            data: { text: content }
          });
        }
      } else {
        console.warn('No JSON pattern found in response');
        // Return the raw text if no JSON found
        return res.json({
          success: true,
          data: { text: content }
        });
      }
    }
  } catch (error) {
    console.error('Server error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error processing request'
    });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`API Key configured: ${process.env.OPENAI_API_KEY ? 'Yes' : 'No'}`);
  console.log(`Allowed origins: ${allowedOrigins.join(', ')}`);
});

// Error handling for unhandled promises
process.on('unhandledRejection', (error) => {
  console.error('Unhandled Promise Rejection:', error);
}); 