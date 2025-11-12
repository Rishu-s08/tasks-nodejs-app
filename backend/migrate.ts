import { drizzle } from "drizzle-orm/node-postgres";
import { migrate } from "drizzle-orm/node-postgres/migrator";
import { Pool } from "pg";
import path from "path";
import fs from "fs";

async function runMigrations() {
    const connectionString = process.env.DATABASE_URL;
    
    if (!connectionString) {
        throw new Error("DATABASE_URL is not defined");
    }

    console.log("=== Starting Migrations ===");
    console.log("NODE_ENV:", process.env.NODE_ENV);
    console.log("__dirname:", __dirname);
    
    const pool = new Pool({
        connectionString,
        ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false
    });

    const db = drizzle(pool);

    // The migrations folder is at dist/src/drizzle after build
    const migrationsFolder = path.join(__dirname, "src", "drizzle");
    console.log("Migrations folder:", migrationsFolder);
    console.log("Folder exists:", fs.existsSync(migrationsFolder));
    
    if (fs.existsSync(migrationsFolder)) {
        console.log("Files in migrations folder:", fs.readdirSync(migrationsFolder));
    }

    try {
        await migrate(db, { migrationsFolder });
        console.log("✅ Migrations completed successfully!");
        process.exit(0);
    } catch (error) {
        console.error("❌ Migration failed:", error);
        process.exit(1);
    } finally {
        await pool.end();
    }
}

runMigrations();
