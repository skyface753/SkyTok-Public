const { Database, aql } = require("arangojs");

const bcrypt = require('bcrypt');
const console = require('../helpers/log');

const db = new Database({
    url: "http://node-intel:8529",
    databaseName: "SkyTok",
    auth: { username: "root", password: "SkyTokPass123!" },
  });


//   async function main() {
//     try {
//       const pokemons = await db.query(aql`
//         FOR pokemon IN ${Pokemons}
//         FILTER pokemon.type == "fire"
//         RETURN pokemon
//       `);
//       console.log("My pokemons, let me show you them:");
//       for await (const pokemon of pokemons) {
//         console.log(pokemon.name);
//       }
//     } catch (err) {
//       console.error(err.message);
//     }
//   }


//Create first user
async function createUser(req, res){
    var username = "sjoerz";
    var mail = "seppel8426@gmail.com";
    var password = "8";
    var passwordHash = await bcrypt.hash(password, 10);
    var user = await db.query(aql`
        
        INSERT {
            username: ${username},
            mail: ${mail},
            password: ${passwordHash},
            created_at: DATE_NOW(),
            updated_at: DATE_NOW()
        } INTO "users"
        RETURN NEW

    `);
}
try{
    // createUser();

}catch(err){
    console.error("User already exists");
}


  let userServiceArango = {
    getAllUsers: async function(req, res){
        try {
            const users = await db.query(aql`

            FOR user IN users
            RETURN user
            `);
            res.send(users);
        } catch (err) {
            console.error(err.message);
        }
    },
      getUsers: async function(){
            return await db.query(aql`
                FOR user IN users
                RETURN user
            `);
        },
        login: async function(req, res){
            var usernameOrEmail = req.body.usernameOrEmail;
            var password = req.body.password;
            if(!usernameOrEmail || !password){
                res.send("Username or password is null");
                return;
            }
            usernameOrEmail = "sjoerz";
            const users = await db.query(aql`
                FOR user IN users
                FILTER user.username == ${usernameOrEmail} OR user.mail == ${usernameOrEmail}
                RETURN user
            `);
            if(users == null){
                res.send("User does not exist");
                return;
            }
            if(users.length == 0){
                res.send("User does not exist");
                return;
            }
            if(users.length > 1){
                res.send("Too many users with this username or email");
                return;
            }
            users.forEach(function(user){
                bcrypt.compare(password, user.password, function(err, result) {
                    if(result){
                        var jwtToken = signToken(user.id);
                        res.send({
                            token: jwtToken,
                            username: user.username,
                            mail: user.mail,
                        })
                    }else{
                        
                        //Hash password
                        bcrypt.hash(password, 10, function(err, hash) {
                            // Store hash in your password DB.
                            console.log(hash);
                        });
                        res.send("Wrong password");
                    }
                });
            }
            );
            

        },
        getAllTagsForUser: async function(req, res){
            var user_id = getUserIdFromToken(req);
            if(user_id){
                const tags = await db.query(aql`
                    FOR tag IN tags
                    FILTER tag.user_id == ${user_id}
                    RETURN tag
                `);
                res.send(tags);
            }else{
                res.send("User is not logged in");
            }
        }
    }

  
 module.exports = userServiceArango;