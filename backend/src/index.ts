import express from "express";
import authRouter from "./routes/auth";
import taskRouter from "./routes/task";

const app = express();
const PORT = process.env.PORT || 8000;

app.use(express.json());
app.use("/auth", authRouter)
app.use("/task", taskRouter)

app.get('/', (req, res)=>{
    res.send("Hello World! Server is running!");
})

app.listen(PORT, ()=>{
    console.log(`Server is running on port ${PORT}`);
})