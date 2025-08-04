# DeepSeek API Bridge Server

This server acts as a bridge between your Flutter application and the DeepSeek API. It provides endpoints that match what your app expects while forwarding the requests to DeepSeek's API with the appropriate authentication.

## Endpoints

### Root Endpoint
- **GET /** - Health check endpoint that returns status information

### Food Fix Endpoint
- **POST /api/fix-food** - Endpoint that takes food data and instructions to modify it
  - Request body should include `food_data`, `instructions`, and optional `operation_type`

### Nutrition Calculation Endpoint
- **POST /api/nutrition** - Endpoint that calculates nutrition for a food item
  - Request body should include `food_name` and `serving_size`

## Environment Variables

This server requires the following environment variable:

- `DEEPSEEK_API_KEY` - Your DeepSeek API key

## Running Locally

To run this server locally:

```bash
npm install
npm start
```

For development with auto-restart:

```bash
npm run dev
```

## Deployment

This server is designed to be deployed on Render.com. Make sure to set the `DEEPSEEK_API_KEY` environment variable in your Render.com dashboard. 