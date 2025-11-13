# Docker Setup

## For Local Development (Docker Compose)

```bash
docker compose up
```

This uses `Dockerfile.dev` which runs nodemon for hot-reload.

## For Render (Production Deployment)

Render will automatically use the main `Dockerfile` which:
1. Installs dependencies
2. Builds TypeScript → JavaScript
3. Runs database initialization (`init-db.js`)
4. Starts the server

## Important Files

- **Dockerfile** - Production build (used by Render)
- **Dockerfile.dev** - Development build (used by docker-compose)
- **docker-compose.yaml** - Local development orchestration

## Environment Variables on Render

Make sure these are set in your Render service:
- `DATABASE_URL` - Auto-set from database connection
- `JWT_SECRET` - Set manually (any random 32+ char string)
- `NODE_ENV=production` - Set manually
- `PORT=8000` - Set manually

## Troubleshooting

If tables aren't being created on Render:
1. Check Render logs for "=== INITIALIZING DATABASE ==="
2. Verify DATABASE_URL is set in environment variables
3. Make sure the Docker build completed successfully
