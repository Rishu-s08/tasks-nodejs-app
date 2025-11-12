import { drizzle } from "drizzle-orm/node-postgres";
import { migrate } from "drizzle-orm/node-postgres/migrator";
import { Pool } from "pg";
import path from "path";

async function runMigrations() {
    const connectionString = process.env.DATABASE_URL;
    
    if (!connectionString) {
        throw new Error("DATABASE_URL is not defined");
    }

    console.log("Running migrations...");
    
    const pool = new Pool({
        connectionString,
        ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false
    });

    const db = drizzle(pool);

    // Use path.join to handle both dev and production paths
    const migrationsFolder = path.join(__dirname, "src", "drizzle");
    console.log("Migrations folder:", migrationsFolder);

    try {
        await migrate(db, { migrationsFolder });
        console.log("Migrations completed successfully!");
    } catch (error) {
        console.error("Migration failed:", error);
        process.exit(1);
    } finally {
        await pool.end();
    }
}

runMigrations();
