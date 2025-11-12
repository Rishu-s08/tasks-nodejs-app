import { defineConfig } from "drizzle-kit";

// Check if we're running in Docker container
const isDocker = process.env.NODE_ENV === "development";

export default defineConfig({
    dialect: "postgresql",
    schema: "./db/schema.ts",
    out: "./drizzle",
    dbCredentials:{
        host: isDocker ? "db" : "localhost",
        port: 5432,
        database: "db",
        user: "postgres",
        password: "test123",
        ssl: false
    }
})