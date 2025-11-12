import { defineConfig } from "drizzle-kit";

// Check if we're running in Docker container or using DATABASE_URL
const isDocker = process.env.NODE_ENV === "development";
const databaseUrl = process.env.DATABASE_URL;

export default defineConfig({
    dialect: "postgresql",
    schema: "./db/schema.ts",
    out: "./drizzle",
    dbCredentials: databaseUrl 
        ? { url: databaseUrl }
        : {
            host: isDocker ? "db" : "localhost",
            port: 5432,
            database: "db",
            user: "postgres",
            password: "test123",
            ssl: false
        }
})