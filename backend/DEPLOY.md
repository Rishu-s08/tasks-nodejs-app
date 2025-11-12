# Todo App Backend - Render Deployment Guide

## Quick Deploy to Render

### Option 1: Using render.yaml (Recommended)

1. Push your code to GitHub
2. Go to [Render Dashboard](https://dashboard.render.com/)
3. Click "New" → "Blueprint"
4. Connect your GitHub repository
5. Render will automatically detect `render.yaml` and set up:
   - PostgreSQL database
   - Web service with auto-deploy

### Option 2: Manual Setup

#### Step 1: Create PostgreSQL Database
1. In Render Dashboard, click "New" → "PostgreSQL"
2. Name: `todonodejs-db`
3. Database: `todonodejs`
4. User: `todonodejs`
5. Region: Choose closest to you
6. Click "Create Database"
7. Copy the **Internal Database URL** (starts with `postgresql://`)

#### Step 2: Create Web Service
1. Click "New" → "Web Service"
2. Connect your GitHub repository
3. Configure:
   - **Name**: `todonodejs-api`
   - **Region**: Same as database
   - **Branch**: `main`
   - **Root Directory**: `backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm start`

4. Add Environment Variables:
   - `NODE_ENV` = `production`
   - `DATABASE_URL` = (paste your database URL)
   - `PORT` = `8000`
   - `JWT_SECRET` = (generate a strong random secret - at least 32 characters)

5. Click "Create Web Service"

## Local Development

```bash
# Start with Docker
docker compose up

# The API will be available at:
# http://localhost:3000
```

## Environment Variables

- `NODE_ENV`: Set to `production` for Render, `development` for Docker
- `DATABASE_URL`: PostgreSQL connection string (auto-provided by Render)
- `PORT`: Server port (default: 8000)
- `JWT_SECRET`: Secret key for JWT token signing/verification (REQUIRED)
  - For production: Generate a strong random string (minimum 32 characters)
  - Example: Use `openssl rand -base64 32` to generate one

## API Endpoints

- `GET /` - Health check
- `POST /auth/signup` - Create new user
- `POST /auth/login` - Login user
- `POST /auth/tokenIsValid` - Validate JWT token
- `POST /task/add` - Create new task
- `GET /task` - Get all tasks
- `DELETE /task/delete` - Delete task
- `POST /task/syncTasks` - Sync offline tasks

## After Deployment

1. Your API will be available at: `https://your-service-name.onrender.com`
2. Update your Flutter app's `lib/core/constants/paths.dart`:
   ```dart
   static String get baseUrl => 'https://your-service-name.onrender.com';
   ```
3. Test with: `curl https://your-service-name.onrender.com/`

## Notes

- Render free tier spins down after 15 minutes of inactivity
- First request after spin-down may take 30-60 seconds
- Database migrations run automatically during build (`postbuild` script)
