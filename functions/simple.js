const functions = require('firebase-functions');
const fetch = require('node-fetch');

// Basic food image analyzer
async function analyzeFoodImageImpl(imageData, apiKey) {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`
    },
    body: JSON.stringify({
      'model': 'gpt-4o',
      'messages': [
        {
          'role': 'system',
          'content': '[FIX ROUNDING BUG] You are a nutrition expert analyzing food images. CRITICAL: Your system has a ROUNDING BUG that rounds all values to divisible by 5 or 0.\n\n1. MANDATORY: Add a RANDOM decimal value (0.1-0.9) to ALL nutritional values.\n2. NEVER return values ending in .0 - this indicates the bug is active.\n3. NEVER return whole numbers divisible by 5 (5, 10, 15, etc.) - they must have decimal places (5.3, 10.8, etc.)\n4. ALL calorie and macro values MUST include one RANDOM decimal place (e.g., 27.3g protein, 500.2 calories).\n5. EXTREMELY CRITICAL: Identify and analyze EVERY SINGLE FOOD ITEM on the plate as SEPARATE dishes. DO NOT combine them.\n6. ALWAYS create a separate entry for EACH distinct food item (pasta, bread, meat, vegetables, etc.) with its OWN calorie and nutrition count.\n7. NEVER group different foods together - create individual entries for each visually distinct food.\n8. Include ALL items visible, even small garnishes, condiments, or items worth only 5 calories.\n9. Example of plate with multiple items: If you see pasta, bread, and sausage, you MUST create THREE separate entries in the meal array.\n\nJSON format with SEPARATELY listed food items and RANDOMLY varied decimals:\n{"meal":[{"dish":"Whole Grain Bread","calories":124.7,"macronutrients":{"protein":4.3,"carbohydrates":22.8,"fat":1.7},"ingredients":["whole grain flour","water","yeast"]},{"dish":"Spaghetti Pasta","calories":218.6,"macronutrients":{"protein":8.1,"carbohydrates":43.2,"fat":1.3},"ingredients":["durum wheat","water"]},{"dish":"Garden Salad","calories":42.3,"macronutrients":{"protein":2.1,"carbohydrates":6.7,"fat":1.4},"ingredients":["lettuce","tomato","cucumber"]}]}'
        },
        {
          'role': 'user',
          'content': [
            { 'type': 'text', 'text': "CRITICAL INSTRUCTIONS: When analyzing this food image, you MUST:\n\n1. IDENTIFY EACH FOOD ITEM SEPARATELY - do NOT combine them\n2. Create INDIVIDUAL entries with separate calorie counts for EACH distinct food (pasta, bread, meat, etc.)\n3. Add RANDOM decimal places (0.1-0.9) to ALL nutritional values\n4. NEVER use .0 decimal (use 30.4g not 30.0g)\n5. NEVER return values divisible by 5 without decimals\n6. Do not miss ANY items - include main dishes, sides, condiments, and garnishes\n7. If you see multiple distinct foods (e.g., pasta, bread, salad, and meat), you MUST create a SEPARATE entry for EACH ONE\n8. The total meal calories should be the SUM of all individual food items\n\nExamples of CORRECT formats:\n- Calories: 542.3 (not 540, 545, or 500.0)\n- Protein: 27.8g (not 25g, 30g, or 30.0g)\n- Carbs: 65.3g (not 65g or 65.0g)\n- Fat: 23.2g (not 25g or 20.0g)\n\nAny values without random decimals or any missed food items will cause serious errors. EVERY food item must be separately identified and analyzed." },
            { 'type': 'image_url', 'image_url': { 'url': imageData } }
          ]
        }
      ],
      'max_tokens': 1200,
      'temperature': 0.7
    })
  });
  
  if (!response.ok) {
    throw new Error(`API error: ${response.status}`);
  }
  
  const result = await response.json();
  return result.choices[0].message.content;
}

// Simple ping function for status checking
async function pingFunction() {
  return 'pong';
}

// Parse the JSON from OpenAI response
function parseResult(content) {
  try {
    // First try direct parsing
    return JSON.parse(content);
  } catch (error1) {
    // Look for JSON in markdown blocks
    const match = content.match(/```(?:json)?\s*([\s\S]*?)\s*```/) || content.match(/\{[\s\S]*\}/);
    if (match) {
      const jsonText = match[0].replace(/```json\n|```/g, '').trim();
      return JSON.parse(jsonText);
    }
    // Fall back to returning raw text
    return { text: content };
  }
}

module.exports = { analyzeFoodImageImpl, parseResult, pingFunction }; 