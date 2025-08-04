# Food Analyzer API Server

A secure API server for analyzing food images using OpenAI's Vision API.

## Features

- Secure OpenAI API key handling
- Rate limiting to prevent abuse
- CORS protection
- JSON response parsing and formatting
- Error handling

## Setup

### Prerequisites

- Node.js v18 or higher
- An OpenAI API key with access to GPT-4 Vision (gpt-4o model)

### Local Development

1. Clone this repository
2. Navigate to the api-server directory
3. Install dependencies:
   ```
   npm install
   ```
4. Create a `.env` file from the example:
   ```
   cp .env.example .env
   ```
5. Add your OpenAI API key to the `.env` file
6. Start the development server:
   ```
   npm run dev
   ```

The server will start on port 3000 by default.

### Endpoints

#### `GET /`

Health check endpoint that returns the server status.

**Response:**
```json
{
  "message": "Food Analyzer API Server",
  "status": "operational"
}
```

#### `POST /api/analyze-food`

Analyzes a food image and returns nutritional information.

**Request Body:**
```json
{
  "image": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAA..."
}
```

The image can be a base64-encoded data URI or a URL to an image.

**Response:**
```json
{
  "success": true,
  "data": {
    "meal": [
      {
        "dish": "Chicken Salad",
        "calories": 350,
        "macronutrients": {
          "protein": 25,
          "carbohydrates": 15,
          "fat": 20
        },
        "ingredients": ["chicken", "lettuce", "tomato", "avocado"]
      }
    ]
  }
}
```

## Deployment

This server is designed to be deployed to Render.com:

1. Push this repository to GitHub
2. Create a new Web Service on Render.com
3. Connect your GitHub repository
4. Configure the build settings:
   - Build Command: `npm install`
   - Start Command: `npm start`
5. Add the necessary environment variables:
   - `OPENAI_API_KEY`: Your OpenAI API key
   - `ALLOWED_ORIGINS`: Comma-separated list of allowed origins
   - `RATE_LIMIT`: Request limits per minute (default: 30)
   - `DEBUG_MODE`: Enable debug logging (true/false)

## License

MIT 