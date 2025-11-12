import express from "express";
import authRouter from "./routes/auth";
import taskRouter from "./routes/task";
const app = express();

app.use(express.json());
app.use("/auth", authRouter)
app.use("/task", taskRouter)

app.get('/', (req, res)=>{
    res.send("Hello World! Nodemon is working!");
})

app.listen(8000, ()=>{
    console.log("Server is running on port 8000ds");
})