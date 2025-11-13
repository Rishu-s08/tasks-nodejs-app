# ⚠️ CRITICAL: Update Your Render Service

Your database initialization script is not running because Render might not be using the correct start command.

## Option 1: Update Existing Service (Quick Fix)

Go to your Render dashboard and update these settings:

### 1. Go to your service: `todonodejs-api`
   - Dashboard: https://dashboard.render.com/

### 2. Click "Settings" (not "Environment")

### 3. Update "Start Command":
   ```
   npm start
   ```
   (This should already be set, but verify it!)

### 4. Go to "Environment" tab

### 5. Verify these environment variables exist:
   - ✅ `NODE_ENV` = `production`
   - ✅ `DATABASE_URL` = (should be auto-set from database)
   - ✅ `JWT_SECRET` = (add any random string, at least 32 chars)
   - ✅ `PORT` = `8000`

### 6. Click "Manual Deploy" → "Deploy latest commit"

## Option 2: Use Blueprint (Recommended)

If the above doesn't work, delete your current service and recreate using Blueprint:

1. **Delete current service** (if it exists)
2. Go to Dashboard → New → Blueprint
3. Connect your GitHub repo: `Rishu-s08/tasks-nodejs-app`
4. Render will detect `render.yaml` and auto-configure everything
5. Click "Apply"

## What Should Happen

After deployment, check the logs. You should see:

```
=== INITIALIZING DATABASE ===

✓ Connecting to database...
✓ Connected successfully
Creating users table...
✓ Users table created
Creating tasks table...
✓ Tasks table created
Adding foreign key constraint...
✓ Foreign key constraint added

✅ DATABASE INITIALIZATION COMPLETE!

Server is running on port 8000
```

## Still Not Working?

If you see the server starting but NO database initialization messages, the start command is wrong.

**Manual fix on Render Dashboard:**
- Settings → Start Command → Change to: `node dist/init-db.js && node dist/index.js`
- Save and redeploy

This will force the database script to run before the server starts.
