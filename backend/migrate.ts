import { drizzle } from "drizzle-orm/node-postgres";
import { migrate } from "drizzle-orm/node-postgres/migrator";
import { Pool } from "pg";
import path from "path";
import fs from "fs";

async function runMigrations() {
    console.log("\n=== STARTING MIGRATIONS ===\n");
    
    const connectionString = process.env.DATABASE_URL;
    
    if (!connectionString) {
        console.error("❌ ERROR: DATABASE_URL is not defined");
        console.error("Available env vars:", Object.keys(process.env).filter(k => k.includes('DATABASE')));
        process.exit(1);
    }

    console.log("✓ DATABASE_URL is set");
    console.log("✓ NODE_ENV:", process.env.NODE_ENV || 'not set');
    console.log("✓ Current directory (__dirname):", __dirname);
    
    // The migrations folder is at dist/src/drizzle after build
    const migrationsFolder = path.join(__dirname, "src", "drizzle");
    console.log("✓ Looking for migrations in:", migrationsFolder);
    
    const folderExists = fs.existsSync(migrationsFolder);
    console.log("✓ Migrations folder exists:", folderExists);
    
    if (!folderExists) {
        console.error("❌ ERROR: Migrations folder not found!");
        console.error("Contents of __dirname:", fs.readdirSync(__dirname));
        process.exit(1);
    }
    
    const files = fs.readdirSync(migrationsFolder);
    console.log("✓ Files in migrations folder:", files);
    
    if (files.length === 0) {
        console.error("❌ ERROR: No migration files found!");
        process.exit(1);
    }

    console.log("\n--- Connecting to database ---");
    const pool = new Pool({
        connectionString,
        ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false
    });

    console.log("✓ Pool created with SSL:", process.env.NODE_ENV === "production" ? "enabled" : "disabled");

    try {
        // Test connection
        const client = await pool.connect();
        console.log("✓ Database connection successful");
        client.release();

        const db = drizzle(pool);
        
        console.log("\n--- Running migrations ---");
        await migrate(db, { migrationsFolder });
        
        console.log("\n✅ MIGRATIONS COMPLETED SUCCESSFULLY!\n");
        await pool.end();
        process.exit(0);
    } catch (error) {
        console.error("\n❌ MIGRATION FAILED:");
        console.error("Error name:", (error as any)?.name);
        console.error("Error message:", (error as any)?.message);
        console.error("Full error:", error);
        await pool.end();
        process.exit(1);
    }
}

runMigrations();
