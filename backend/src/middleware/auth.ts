import { NextFunction, Request, Response } from "express";
import { UUID } from "crypto";
import jwt from "jsonwebtoken";
import { db } from "../db";
import { users } from "../db/schema";
import { eq } from "drizzle-orm";

export interface AuthRequest extends Request {
    user? : UUID;
    token? : string;
}

export const authMiddleware = async (req : AuthRequest, res : Response, next : NextFunction) => {
    try {
        const authHeader = req.header('x-auth-token');

        if(!authHeader) {
            res.status(401).json({ message: "No authentication token, authorization denied" });
            return;
        }

        const verified = jwt.verify(authHeader, process.env.JWT_SECRET || "fallback_secret_key");

        if(!verified) {
            res.status(401).json({ message: "Token verification failed, authorization denied" });
            return;
        }

        const verifiedToken = verified as {id: UUID};

        const [user] = await db.select().from(users).where(eq(users.id, verifiedToken.id));

        if(!user) {
            res.status(401).json({ message: "User not found, authorization denied" });
            return;
        }
        
        req.user = (verified as {id: UUID}).id;
        req.token = authHeader;
        next();
    } catch (error) {
        res.status(500).json({ message: "Internal Server Error", error });
    }
}