import { Response } from "express";
import { authMiddleware, AuthRequest } from "../middleware/auth";
import { NewTask, tasks } from "../db/schema";
import { db } from "../db";
import { eq } from "drizzle-orm";

const express = require('express');
const router = express.Router();
 

router.post('/add',authMiddleware, async(req : AuthRequest, res : Response)=>{
    try {
        req.body = {...req.body,dueAt: new Date(req.body.dueAt), uid: req.user};
        const newTask: NewTask = req.body;  

         const [task] = await db.insert(tasks).values(newTask).returning();
        res.status(201).json({message: 'Task added successfully', task});

    } catch (error) {
        res.status(500).json({message: 'Internal server error', error});
    }
})

router.get('/', authMiddleware, async (req: AuthRequest, res: Response) => {
    try {
        const allTasks = await db.select().from(tasks).where(eq(tasks.uid, req.user!));       
        res.status(200).json( allTasks);

    } catch (error) {
        res.status(500).json({ message: 'Internal server error' });
    }
})

router.delete('/delete', authMiddleware, async (req: AuthRequest, res: Response) => {
    try {
        const {taskId} : {taskId:string} = req.body;
        await db.delete(tasks).where(eq(tasks.id, taskId));
        res.json(true);

    } catch (error) {
        res.status(500).json({ message: 'Internal server error' });
    }
})

router.post('/sync', authMiddleware, async (req: AuthRequest, res: Response) => {
    try {
        // req.body = { ...req.body, dueAt: new Date(req.body.dueAt), uid: req.user };
        const tasksList = req.body;  // Array of tasks to sync

        const filteredTasks : NewTask[] = [];


        for(let t of tasksList){
            t = {...t, dueAt: new Date(t.dueAt),createdAt: new Date(t.createdAt), updatedAt: new Date(t.updatedAt), uid: req.user};
            filteredTasks.push(t);
        }
        const pushedTasks = await db.insert(tasks).values(filteredTasks).returning();
        res.status(201).json({ message: 'Task added successfully', task: pushedTasks });

    } catch (error) {
        res.status(500).json({ message: 'Internal server error', error });
    }
})


export default router;