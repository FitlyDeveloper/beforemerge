const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require('node-fetch');

// Initialize Firebase Admin
admin.initializeApp();

// Get the OpenAI API key from Firebase config
const apiKey = functions.config().openai?.api_key;

// Process and analyze food images
exports.analyzeFoodImage = functions.https.onCall(async (data, context) => {
  try {
    // Validate input
    if (!data || !data.image) {
      throw new functions.https.HttpsError('invalid-argument', 'No image provided');
    }
    
    // Prepare the base64 image
    const base64Image = data.image.startsWith('data:') 
      ? data.image 
      : `data:image/jpeg;base64,${data.image}`;
    
    // Call OpenAI API
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        'model': 'gpt-4-vision-preview',
        'messages': [
          {
            'role': 'system',
            'content': '[PRECISION NUTRITIONIST WITH PHD IN ANALYTICAL CHEMISTRY] You are a highly precise nutrition analyst with a PhD in analytical chemistry. You MUST follow these exact rules when analyzing food:\n\n1. NEVER ROUND measurements - use precise, irregular values with EXACTLY 2 decimal places\n2. All values MUST end with 2 decimal places (e.g., 27.32g not 27g or 27.3g)\n3. NEVER use values divisible by 5 or 10 - these are scientifically invalid\n4. For every value you determine, SUBTRACT or ADD a random offset between 1.01-4.99\n5. CALORIES must be particularly precise (e.g. 327.83, 542.76) and NEVER end in 0 or 5\n6. MACRONUTRIENTS must all have 2 decimal places (protein: 27.32g, carbs: 65.78g)\n7. Your scientific reputation depends on precise, irregular values that look like laboratory measurements\n\nJSON format with ultra-precise measurements:\n{"meal":[{"dish":"Name","calories":542.76,"macronutrients":{"protein":27.32,"carbohydrates":65.78,"fat":23.17},"ingredients":["item1","item2"]}]}'
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': "URGENT ANALYTICAL CHEMISTRY NUTRITIONAL ANALYSIS: Analyze this food with LABORATORY PRECISION.\n\nCRITICAL SCIENTIFIC REQUIREMENTS:\n1. ALL values MUST have EXACTLY 2 decimal places (27.32g, not 27g or 27.3g)\n2. NO values can be divisible by 5 or 10 (avoid 25.00, 30.00, 100.00, 500.00)\n3. Numbers MUST appear randomly generated like laboratory measurements\n4. CALORIES must look precise (e.g., 327.83, 542.76, 416.29) - never round values\n5. MACRONUTRIENTS must all use 2 decimal places (protein: 27.32g, carbs: 65.78g)\n6. The last digit CANNOT be 0 or 5 for any measurement\n7. Food biochemistry produces complex irregular values - reflect this complexity\n\nSCIENTIFICALLY ACCURATE EXAMPLES:\n- Calories: 542.76 (NOT 540 or 550 or 542.8)\n- Protein: 27.32g (NOT 25g, 27g, or 27.3g)\n- Carbs: 65.78g (NOT 65g, 70g, or 65.8g)\n- Fat: 23.17g (NOT 23g, 25g, or 23.2g)\n\nYour scientific reputation and laboratory accuracy are at stake!"
              },
              {
                'type': 'image_url',
                'image_url': { 'url': base64Image }
              }
            ]
          }
        ],
        'max_tokens': 1000
      })
    });
    
    if (!response.ok) {
      const errorText = await response.text();
      console.error(`OpenAI API error: ${response.status}`, errorText);
      throw new functions.https.HttpsError(
        "internal",
        `Failed to analyze food image: API returned ${response.status}`
      );
    }
    
    const responseData = await response.json();
    console.log('OpenAI response received');
    
    if (!responseData.choices || 
        !responseData.choices[0] || 
        !responseData.choices[0].message ||
        !responseData.choices[0].message.content) {
      console.error('Invalid response format from OpenAI', JSON.stringify(responseData));
      throw new functions.https.HttpsError(
        "internal",
        "Invalid response from image analysis service"
      );
    }
    
    const content = responseData.choices[0].message.content;
    console.log('Content received, parsing response...');
    
    // Parse JSON from the response
    try {
      // Try to find JSON blocks in markdown (```json ... ```)
      const jsonMatch = content.match(/```json\n([\s\S]*?)\n```/) || 
                       content.match(/{[\s\S]*?}/);
      
      if (jsonMatch) {
        // Clean the JSON string
        let jsonContent = jsonMatch[0];
        jsonContent = jsonContent.replace(/```json\n|```/g, '').trim();
        
        // Parse the JSON
        const analysisData = JSON.parse(jsonContent);
        console.log('Successfully parsed food analysis JSON');
        return analysisData;
      } else {
        // If no JSON found, try to parse the content directly
        try {
          const analysisData = JSON.parse(content);
          return analysisData;
        } catch (directParseError) {
          // If direct parsing fails, return raw text
          console.log('No structured JSON found in response');
          return { rawText: content };
        }
      }
    } catch (parseError) {
      console.error('Error parsing food analysis result:', parseError);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to parse analysis results"
      );
    }
  } catch (error) {
    console.error("Error in analyzeFoodImage:", error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError(
      "internal",
      `Failed to analyze food image: ${error.message}`
    );
  }
}); 