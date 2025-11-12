import { time } from "console";
import { pgTable, text, uuid, timestamp } from "drizzle-orm/pg-core";
import { title } from "process";


export const users = pgTable("users", {
    id: uuid("id").primaryKey().defaultRandom(),
    name: text("name").notNull(),
    email: text("email").notNull().unique(),
    password: text("password").notNull(),
    createdAt: timestamp("created_at").defaultNow(),
    updatedAt: timestamp("updated_at").defaultNow(),   
})

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;

export const tasks = pgTable("tasks", {
    id: uuid("id").primaryKey().defaultRandom(),
    title: text("title").notNull(),
    description: text("description").notNull(),
    createdAt: timestamp("created_at").defaultNow(),
    updatedAt: timestamp("updated_at").defaultNow(),
    dueAt: timestamp("due_date").notNull(),
    hexColor: text("hex_color").notNull(),
    uid: uuid("user_id").notNull().references(() => users.id, { onDelete: 'cascade' }),
});


export type Task = typeof tasks.$inferSelect;
export type NewTask = typeof tasks.$inferInsert;
