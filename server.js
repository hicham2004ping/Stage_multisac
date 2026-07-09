require("dotenv").config();
//load the port of the application from the .env file
const port=process.env.APP_PORT;
// Import the express module
const express = require("express");
//Import the auth route
const authRoute=require("./src/modules/auth/route");

const app = express();

app.get("/",(req,res)=>{
    res.send("premier test");
})

app.use("/auth",authRoute);


app.listen(port,()=>{
console.log(`le serveur fonctionne sur ${port}`);
});