const express=require("express");
const jwt = require("jsonwebtoken");
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const port_test=process.env.APP_PORT;
console.log(`la valeur du port de test est : ${port_test}`);
const router=express.Router();
const REALM = process.env.REALM
const CLIENT_ID =  process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;
const KEYCLOAK ="http://localhost:8080/realms/" + REALM;
const REDIRECT_URI ="http://localhost:3000/auth/callback";
console.log(`${CLIENT_ID} ${KEYCLOAK} ${REDIRECT_URI}`);

router.get("/",(req,res)=>{
        const authUrl =
        `${KEYCLOAK}/protocol/openid-connect/auth`
        + `?client_id=${CLIENT_ID}`
        + `&response_type=code`
        + `&scope=openid profile email`
        + `&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;
    res.redirect(authUrl);    
});

router.get("/callback",async(req,res)=>{
    const code =req.query.code;
    console.log(`code received: ${code}`);
    try{
        const reponse=await fetch(`${KEYCLOAK}/protocol/openid-connect/token`,{
            method:"POST",
            headers:{
                "content-type":"application/x-www-form-urlencoded"
            },
            body:new URLSearchParams({
                    client_id: CLIENT_ID,
                    client_secret: CLIENT_SECRET,
                    grant_type: "authorization_code",
                    code: code,
                    redirect_uri: REDIRECT_URI})
        });

        if(!reponse.ok){
            const error=await reponse.text();
            console.log(`Erreur`);
            return res.status(reponse.status).send(error);
        }
        const tokens=await reponse.json();
        console.log(tokens);
        const userResponse = await fetch(
    `${KEYCLOAK}/protocol/openid-connect/userinfo`,
    {
        method: "GET",
        headers: {
            Authorization: `Bearer ${tokens.access_token}`
        }
    }
);

    if (!userResponse.ok) {
    return res.status(userResponse.status).send("Impossible de récupérer les informations de l'utilisateur");
    }
        const user = await userResponse.json();
        console.log(user);
        console.log("les infos decoder sont :");
        const decoded = jwt.decode(tokens.access_token);
        console.log(decoded);
        const tableau=decoded.realm_access.roles;
        const userRole=tableau[0];
        const userEmail=decoded.email;
        const service=decoded.service;
        const site=decoded.site;
        console.log(`l'email de l'utilisateur est : ${userEmail}`);

        const utilisateur=await prisma.User.findUnique({
            where:{
                email:userEmail
            }
        });

        if(utilisateur==null){
            //on va essayer de trouver le role de l'utilisateur dans la base de données
            const role=await prisma.role.findFirst({
                where:{
                    nom:userRole
                }
            });
            console.log("le role c'est "+role.id+" son nom est "+role.nom);
            console.log("le nom du site est et le nom du service st sont : "+site+" "+service);
            console.log("labayka ya nascerallah");
            const utilisateurCreer=await prisma.User.create({
                data:{
                    email:userEmail,
                    roleId:role.id,
                    service:service,
                    site:site,
                    nom:decoded.family_name,
                    prenom:decoded.given_name
                }
            })
            if (utilisateurCreer) {
                console.log("utilisateur créé avec succès :", utilisateurCreer);
            }
        }
        else{
            console.log("le user existe deja dans la base");
        }
        res.json(tokens);
    }
    catch(error){
        console.error("Error occurred while processing callback:", error);
        res.status(500).send("erreur.");
    }
});
module.exports=router;