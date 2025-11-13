import { Pool } from "pg";

async function initDatabase() {
    console.log("\n=== INITIALIZING DATABASE ===\n");
    
    const connectionString = process.env.DATABASE_URL;
    
    if (!connectionString) {
        console.error("❌ DATABASE_URL is not defined");
        process.exit(1);
    }

    const pool = new Pool({
        connectionString,
        ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false
    });

    try {
        console.log("✓ Connecting to database...");
        const client = await pool.connect();
        console.log("✓ Connected successfully");

        // Create users table
        console.log("Creating users table...");
        await client.query(`
            CREATE TABLE IF NOT EXISTS "users" (
                "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
                "name" text NOT NULL,
                "email" text NOT NULL,
                "password" text NOT NULL,
                "created_at" timestamp DEFAULT now(),
                "updated_at" timestamp DEFAULT now(),
                CONSTRAINT "users_email_unique" UNIQUE("email")
            );
        `);
        console.log("✓ Users table created");

        // Create tasks table
        console.log("Creating tasks table...");
        await client.query(`
            CREATE TABLE IF NOT EXISTS "tasks" (
                "id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
                "title" text NOT NULL,
                "description" text NOT NULL,
                "created_at" timestamp DEFAULT now(),
                "updated_at" timestamp DEFAULT now(),
                "due_date" timestamp NOT NULL,
                "hex_color" text NOT NULL,
                "user_id" uuid NOT NULL
            );
        `);
        console.log("✓ Tasks table created");

        // Add foreign key constraint if it doesn't exist
        console.log("Adding foreign key constraint...");
        await client.query(`
            DO $$ BEGIN
                ALTER TABLE "tasks" ADD CONSTRAINT "tasks_user_id_users_id_fk" 
                FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") 
                ON DELETE cascade ON UPDATE no action;
            EXCEPTION
                WHEN duplicate_object THEN null;
            END $$;
        `);
        console.log("✓ Foreign key constraint added");

        client.release();
        await pool.end();
        
        console.log("\n✅ DATABASE INITIALIZATION COMPLETE!\n");
        process.exit(0);
    } catch (error) {
        console.error("\n❌ DATABASE INITIALIZATION FAILED:");
        console.error(error);
        await pool.end();
        process.exit(1);
    }
}

initDatabase();
