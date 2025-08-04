require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({limit: '50mb'}));

// Health check endpoint
app.get('/', (req, res) => {
  res.json({ status: 'Deepseek Service Operational' });
});

// Main DeepSeek API proxy endpoint
app.post('/api/analyze', async (req, res) => {
  try {
    const { prompt, operation_type, food_data } = req.body;
    
    // Validate required fields
    if (!prompt) {
      return res.status(400).json({ 
        success: false, 
        error: 'Missing required prompt parameter' 
      });
    }
    
    console.log(`Processing request for operation: ${operation_type || 'general'}`);
    
    // Prepare messages for DeepSeek
    const messages = [
      {
        'role': 'system',
        'content': 'You are a nutrition expert that can analyze and modify foods based on user instructions. Return only valid JSON.'
      },
      {
        'role': 'user',
        'content': prompt
      }
    ];
    
    // Call DeepSeek API
    const response = await axios.post(
      'https://api.deepseek.com/v1/chat/completions',
      {
        model: 'deepseek-chat',
        messages: messages,
        max_tokens: 1000,
        temperature: 0.5,
        response_format: { type: 'json_object' }
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.DEEPSEEK_API_KEY}`
        },
        timeout: 30000 // 30 second timeout
      }
    );
    
    // Extract and validate the response
    const content = response.data.choices[0].message.content;
    
    try {
      // Parse JSON content
      const nutritionData = JSON.parse(content);
      
      // Return success with data
      return res.json({
        success: true,
        data: nutritionData,
        request_id: response.data.id,
        operation_type: operation_type || 'general'
      });
    } catch (jsonError) {
      console.error('JSON parsing error:', jsonError);
      // Try to extract JSON using regex as fallback
      const jsonRegex = /\{[\s\S]*\}/;
      const match = jsonRegex.exec(content);
      
      if (match) {
        try {
          const extractedJson = JSON.parse(match[0]);
          return res.json({
            success: true,
            data: extractedJson,
            extracted: true
          });
        } catch (e) {
          throw new Error('Could not parse response as JSON');
        }
      } else {
        throw new Error('Could not extract JSON from response');
      }
    }
  } catch (error) {
    console.error('Error processing request:', error);
    
    // Return appropriate error response
    return res.status(error.response?.status || 500).json({
      success: false,
      error: error.message,
      details: error.response?.data || 'Internal server error'
    });
  }
});

// Specialized endpoint for calculating nutrition
app.post('/api/nutrition', async (req, res) => {
  try {
    const { food_name, serving_size } = req.body;
    
    // Validate required fields
    if (!food_name || !serving_size) {
      return res.status(400).json({ 
        success: false, 
        error: 'Missing required parameters: food_name and serving_size are required' 
      });
    }
    
    console.log(`Calculating nutrition for: ${food_name} (${serving_size})`);
    
    // Prepare messages for DeepSeek
    const messages = [
      {
        'role': 'system',
        'content': 'You are a nutrition expert analyzing food items. Calculate accurate nutritional values for the specified food and serving size. Return ONLY RAW JSON with nutritional values that are accurate for the food type. Calculate values based on typical nutritional composition - DO NOT inflate protein content. For example, donuts should have LOW protein (3-7g), not high protein. CALORIES MUST BE PRECISE NUMBERS - not rounded to multiples of 10 or 50. For example, if a food has 283 calories, return 283 (not 280 or 300). Use accurate macronutrient distribution based on food type (e.g. more carbs for sweets, more protein for meat).'
      },
      {
        'role': 'user',
        'content': `Calculate accurate nutritional values for ${food_name}, serving size: ${serving_size}. Return only the JSON with calories, protein, fat, and carbs.`
      }
    ];
    
    // Call DeepSeek API
    const response = await axios.post(
      'https://api.deepseek.com/v1/chat/completions',
      {
        model: 'deepseek-chat',
        messages: messages,
        max_tokens: 500,
        temperature: 0.5,
        response_format: { type: 'json_object' }
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.DEEPSEEK_API_KEY}`
        },
        timeout: 30000 // 30 second timeout
      }
    );
    
    // Extract and validate the response
    const content = response.data.choices[0].message.content;
    let nutritionData;
    
    try {
      // Parse JSON content
      nutritionData = JSON.parse(content);
    } catch (jsonError) {
      console.error('JSON parsing error:', jsonError);
      // Try to extract JSON using regex as fallback
      const jsonRegex = /\{[\s\S]*\}/;
      const match = jsonRegex.exec(content);
      
      if (match) {
        try {
          nutritionData = JSON.parse(match[0]);
        } catch (e) {
          throw new Error('Could not parse response as JSON');
        }
      } else {
        throw new Error('Could not extract JSON from response');
      }
    }
    
    // Return success with data
    return res.json({
      success: true,
      data: nutritionData,
      request_id: response.data.id
    });
  } catch (error) {
    console.error('Error calculating nutrition:', error);
    
    // Return appropriate error response
    return res.status(error.response?.status || 500).json({
      success: false,
      error: error.message,
      details: error.response?.data || 'Internal server error'
    });
  }
});

// Specialized endpoint for fixing food
app.post('/api/fix-food', async (req, res) => {
  try {
    const { food_name, current_data, instructions, operation_type } = req.body;
    
    // Validate required fields
    if (!food_name || !instructions || !current_data) {
      return res.status(400).json({ 
        success: false, 
        error: 'Missing required parameters' 
      });
    }
    
    console.log(`Fixing food: ${food_name} with operation: ${operation_type || 'unknown'}`);
    
    // Create a description of the current food with all ingredients
    let currentFoodDescription = `Food: ${food_name}\n`;
    currentFoodDescription += `Total calories: ${current_data.calories}\n`;
    currentFoodDescription += `Total protein: ${current_data.protein}\n`;
    currentFoodDescription += `Total fat: ${current_data.fat}\n`;
    currentFoodDescription += `Total carbs: ${current_data.carbs}\n`;
    currentFoodDescription += "Ingredients:\n";

    if (current_data.ingredients && Array.isArray(current_data.ingredients)) {
      for (const ingredient of current_data.ingredients) {
        currentFoodDescription += `- ${ingredient.name} (${ingredient.amount}): ${ingredient.calories} calories, ${ingredient.protein}g protein, ${ingredient.fat}g fat, ${ingredient.carbs}g carbs\n`;
      }
    }

    // Add the specific instruction about what to fix
    currentFoodDescription += `\nPlease analyze and update the food according to the following instruction: '${instructions}' (Operation type: ${operation_type || 'UNKNOWN'})`;
    
    // Prepare messages for DeepSeek
    const messages = [
      {
        'role': 'system',
        'content': 'You are a nutrition expert that can modify foods based on user instructions. You will receive a description of a food with its ingredients and total nutritional values, along with instructions to modify the food. Your task is to intelligently parse the user instructions and make the requested changes, which may include:\n\n1. ADDING new ingredients\n2. REMOVING existing ingredients\n3. ADJUSTING overall calories (increasing or decreasing)\n4. MODIFYING serving sizes or amounts of existing ingredients\n\nRules to follow:\n1. CAREFULLY ANALYZE the user instructions to identify the requested change type (add, remove, adjust calories, modify amount)\n2. If instructions mention "less calories" or "fewer calories" - REDUCE the total calories by adjusting ingredient amounts or removing ingredients\n3. If instructions mention "more calories" - INCREASE the total calories by adjusting ingredient amounts or adding ingredients\n4. If instructions mention "remove X" or "didn\'t have X" - REMOVE that ingredient completely\n5. If instructions mention "less X" or "smaller amount of X" - REDUCE the amount of that ingredient\n6. If instructions mention "more X" - INCREASE the amount of that ingredient\n7. Format all NEW ingredients consistently with existing ones\n8. RECALCULATE all nutrition values after making changes\n9. Return ONLY a JSON object with all the updated information'
      },
      {
        'role': 'user',
        'content': `Here is the current food information:\n\n${currentFoodDescription}\n\nPlease fix this food according to these instructions: "${instructions}"\n\nImportant instructions:\n\n1. ANALYZE "${instructions}" carefully to determine what type of change is needed:\n   - If adding ingredients: parse it to identify actual ingredients\n   - If removing ingredients: identify which ones to remove\n   - If adjusting calories: determine whether to increase or decrease and by how much\n   - If modifying amounts: identify which ingredients to adjust\n\n2. Make changes according to the specific instruction type:\n   - For ADDING: If multiple ingredients are mentioned, add EACH ONE SEPARATELY with its own nutritional values\n   - For REMOVING: Remove the specified ingredients completely\n   - For CALORIE ADJUSTMENT: Adjust ingredients proportionally to reach the target calories\n   - For AMOUNT MODIFICATION: Change specific ingredient amounts while updating nutritional values\n\n3. Follow these formatting requirements:\n   - Name each ingredient clearly and simply (e.g., "Olive Oil", "Chicken")\n   - Use the same measurement units as existing ingredients (typically grams, "g")\n   - Provide realistic portions and nutritional values for all ingredients\n   - Make sure all values are numeric with no units in the values - only in amount fields\n   - Return a complete JSON with updated name, calories, protein, fat, carbs, and the FULL ingredients list'`
      }
    ];
    
    // Call DeepSeek API
    const response = await axios.post(
      'https://api.deepseek.com/v1/chat/completions',
      {
        model: 'deepseek-chat',
        messages: messages,
        max_tokens: 1000,
        temperature: 0.5,
        response_format: { type: 'json_object' }
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.DEEPSEEK_API_KEY}`
        },
        timeout: 30000 // 30 second timeout
      }
    );
    
    // Extract and process the response
    const content = response.data.choices[0].message.content;
    let modifiedFood;
    
    try {
      // Parse JSON content
      modifiedFood = JSON.parse(content);
      
      // Handle case sensitivity in keys (normalize to lowercase)
      if (modifiedFood.Ingredients && !modifiedFood.ingredients) {
        modifiedFood.ingredients = modifiedFood.Ingredients;
        delete modifiedFood.Ingredients;
      }
      
      if (modifiedFood.Name && !modifiedFood.name) {
        modifiedFood.name = modifiedFood.Name;
        delete modifiedFood.Name;
      }
      
      if (modifiedFood.Calories && !modifiedFood.calories) {
        modifiedFood.calories = modifiedFood.Calories;
        delete modifiedFood.Calories;
      }
      
      if (modifiedFood.Protein && !modifiedFood.protein) {
        modifiedFood.protein = modifiedFood.Protein;
        delete modifiedFood.Protein;
      }
      
      if (modifiedFood.Fat && !modifiedFood.fat) {
        modifiedFood.fat = modifiedFood.Fat;
        delete modifiedFood.Fat;
      }
      
      if (modifiedFood.Carbs && !modifiedFood.carbs) {
        modifiedFood.carbs = modifiedFood.Carbs;
        delete modifiedFood.Carbs;
      }
    } catch (jsonError) {
      console.error('JSON parsing error:', jsonError);
      // Try to extract JSON using regex as fallback
      const jsonRegex = /\{[\s\S]*\}/;
      const match = jsonRegex.exec(content);
      
      if (match) {
        try {
          modifiedFood = JSON.parse(match[0]);
          // Process case sensitivity here too
        } catch (e) {
          throw new Error('Could not parse response as JSON');
        }
      } else {
        throw new Error('Could not extract JSON from response');
      }
    }
    
    // Return success with data
    return res.json({
      success: true,
      data: modifiedFood,
      request_id: response.data.id,
      operation_type: operation_type || 'general'
    });
  } catch (error) {
    console.error('Error fixing food:', error);
    
    // Return appropriate error response
    return res.status(error.response?.status || 500).json({
      success: false,
      error: error.message,
      details: error.response?.data || 'Internal server error'
    });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Deepseek service running on port ${PORT}`);
}); 