import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";

// Use DATABASE_URL from environment or fallback to local Docker
const connectionString = process.env.DATABASE_URL || "postgresql://postgres:test123@db:5432/db";

const pool = new Pool({
    connectionString,
    ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false
})

export const db = drizzle(pool);