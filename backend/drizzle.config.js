const { defineConfig } = require("drizzle-kit");

const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
    throw new Error("DATABASE_URL environment variable is required");
}

module.exports = defineConfig({
    dialect: "postgresql",
    schema: "./src/db/schema.ts",
    out: "./src/drizzle",
    dbCredentials: {
        url: databaseUrl
    }
})
