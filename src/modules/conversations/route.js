const express=require('express');
const routeur=express.Router();

routeur.post("/",async (req,res)=>{

const json=await fetch("http://localhost:11434/api/generate",{
    method:"POST",
    headers:{
        "content-type":"application/json",
    },
    body:JSON.stringify({
            "model": "tinyllama",
            "prompt": "my name is nascerallah",
            "stream": false
    }),
});

const response=await json.json();
console.log(response);
const data=response.response;
res.json(data);
console.log("salut ca va")
console.log(data);    
});
module.exports=routeur;