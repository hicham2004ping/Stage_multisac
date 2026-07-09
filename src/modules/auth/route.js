const express=require("express");
const router=express.Router();
router.get("/login",(req,res)=>{
    res.send("vous etes connecter");
});
module.exports=router;