import e, { Router, Request, Response } from "express";
import { db } from "../db";
import { NewUser, users } from "../db/schema";
import { eq } from "drizzle-orm";
import bcryptjs from "bcryptjs";
import jwt from "jsonwebtoken";
import { authMiddleware, AuthRequest } from "../middleware/auth";
const authRouter = Router();

interface SignupRequestBody {
    name: string;
    email: string;
    password: string;
}
interface LoginRequestBody {
    email: string;
    password: string;
}

authRouter.post('/signup', async (req : Request<{}, {}, SignupRequestBody>, res : Response) => {
    try {
        // get request body
        const {name, email, password} = req.body;

        //check if user already exists
        const existingUser = await db.select().from(users).where(eq(users.email, email));

        if(existingUser.length){
            res.status(400).json({message: "User already exists"});
            return;
        }

        //hashed password
        const hashedPassword = await bcryptjs.hash(password, 10);

        //create user
        const newUser : NewUser = {
            name,
            email,
            password: hashedPassword
        } 

        const [user] =await db.insert(users).values(newUser).returning();

        res.status(201).json({message: "User created successfully", user});
    } catch (error) {
        res.status(500).json({ message: "Internal Server Error", error });
    }
})

authRouter.post('/login', async (req: Request<{}, {}, LoginRequestBody>, res: Response) => {
    try {
        // get request body
        const {email, password } = req.body;

        //check if user exists
        const existingUser = await db.select().from(users).where(eq(users.email, email));

        if (!existingUser.length) {
            res.status(400).json({ message: "User does not exist" });
            return;
        }

        //hashed password
        const hashedPassword = await bcryptjs.compare(password, existingUser[0].password);

        if (!hashedPassword) {
            res.status(400).json({ message: "Invalid credentials" });
            return;
        }

        const token = jwt.sign(
            {id: existingUser[0].id, email: existingUser[0].email}, 
            process.env.JWT_SECRET || "fallback_secret_key"
        );

        res.status(200).json({ message: "Login successful", token, ...existingUser[0] });
    } catch (error) {
        res.status(500).json({ message: "Internal Server Error", error });
    }
})

authRouter.get("/tokenIsValid", async(req, res)=>{
    try {
        //get token from header
        const token = req.header("x-auth-token");
        if(!token) 
        { res.json(false);
            return;
        }
        //verify token
        const verify = jwt.verify(token, process.env.JWT_SECRET || "fallback_secret_key");
        if(!verify) {
            res.json(false)
            return;
        }
        //get the user data if token is valid
        const verifiedToken = verify as {id: string};
        const [user] = await db.select().from(users).where(eq(users.id, verifiedToken.id));

        //return true or false based on token validity
        if(user) {
            res.json(true);
            return;
        }
        res.json(false);
    } catch (error) {
        res.status(500).json({ message: "Internal Server Error", error });
    }
})



authRouter.get('/',authMiddleware ,async (req : AuthRequest, res) => {
    try {
        if(!req.user) {
            res.status(401).json({ message: "Unauthorized" });
            return;
        }

        const [user] = await db.select().from(users).where(eq(users.id, req.user));
        res.json({ ...user, token: req.token });
    } catch (error) {
        res.status(500).json({ message: "Internal Server Error", error });
    }
});

authRouter.get('/', (req, res) => {
    res.send("Login Route");
});


export default authRouter;