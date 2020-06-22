const { Pool } = require("pg");
const SCHEMA_NAME  = 'public';

const pool = new Pool({
    user: "postgres",
    host: "localhost",
    database: "caroapp",
    password: "kyo1122",
    port: "5432"
  });

function getfunc(key, bindParams){
    switch(key) {

        case 'USER': {
            let nameFunc = 'prc_process_user';

            let cmd = getQuery(nameFunc, bindParams);
           
            return cmd;
        }
        default: return;
    }
}

// ham lay cau lenh query vao database
function getQuery(nameFunc, bindParams){
    let query = 'SELECT * FROM '+ nameFunc + "(";
    let str;

    if(bindParams.length == 0){
        query = 'SELECT * FROM '+ nameFunc;
        return query;
    } 
    else{
        bindParams.forEach(item => {                             
            query = `${query}'${item.toString().trim()}',`;
        });
    }  
    str = query.slice(0,[query.length-1]) + ")";  
    console.log({str});
    return str;
};

async function exequery(key, bindParams){
    return new Promise(async resolve =>{
       const client = await pool
       .connect()

       .catch(err => {
       console.log("\nclient.connect():", err.name);

       // iterate over the error object attributes
       for (item in err) {
           if (err[item] != undefined) {
           process.stdout.write(item + " - " + err[item] + " ");
           }
       }

       // end the Pool instance
       console.log("\n");
       process.exit();
       });

   try {
       // Initiate the Postgres transaction
       await client.query("BEGIN");

       try {
           await client.query(`SET search_path TO "${SCHEMA_NAME}"`)
           .then(async function (res) {             
               
               // Ham goi lay chuoi query vao database
               let func = getfunc(key, bindParams); 
                              
               // Pass SQL string to the query() method
               await client.query(func, function(err, result) {                 
                   
                   if (err) {                       
                       // Rollback before executing another transaction
                       client.query("ROLLBACK");
                       console.log("Transaction ROLLBACK called");                        

                       // Ghi loi vao logger                       
                       return resolve({error: true, message: err.message});
                   } else {

                   client.query("COMMIT");                    

                   return resolve({error: false, result});
                   }
               });
           });
           
       } catch (er) {
           // Rollback before executing another transaction
           client.query("ROLLBACK");
          
           console.log({er});
           

           console.log("Transaction ROLLBACK called");

           return resolve({error: true, message: er.message});
       }
   } finally {
       client.release();
       console.log("Client is released");
   }

  });
   
}


module.exports = {
   getfunc,
   exequery
}