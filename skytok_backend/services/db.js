// const mysql = require('mysql2/promise');
const config = require('../config');

const console = require('../helpers/log');
const { Pool } = require('pg')
const pool = new Pool({
  user: 'postgres',
  host: config.postgres.host,
  database: 'skytok',
  password: 'example',
  port: 5432,
})

var averageTimeInMs = 0;
var averageTimeInMsArray = [];
function addTimeToAverage(time){
  averageTimeInMsArray.push(time);
  averageTimeInMs = averageTimeInMsArray.reduce((a,b) => a + b, 0) / averageTimeInMsArray.length;
  // console.log("Average time: " + averageTimeInMs.toPrecision(3));
}

const queryPG = async (text, params) => {
  try{

    const start = Date.now()
    const res = await pool.query(text, params)
    const duration = Date.now() - start
    // console.log(`${text} took ${duration}ms`)
    addTimeToAverage(duration)
    return res.rows
  }catch(e){
    // if(process.env.MODE == "TEST"){
      console.log("Error TEXT: ", text);
      console.log(e)
    // }
    return null;
  }
}

module.exports = {
  // query: (text, params) => pool.query(text, params),
  queryPG,
}



// var retryCounter = 0;
// async function query(sql, params) {
//   try{
//     if(process.env.MODE == "TEST"){
//       console.log("SQL Query: " + sql);
//       console.log("SQL Params: " + JSON.stringify(params));
//       console.log("DB CONFIG: " + JSON.stringify(config.db));
//     }
//     const connection = await mysql.createConnection(config.db);
//     const [results, ] = await connection.execute(sql, params);
//     await connection.end();
//     retryCounter = 0;
//     return results;
//   } catch(error){
//     retryCounter++;
//     if(retryCounter < 3){
//       console.log("Retry: " + retryCounter);
//       setTimeout(function(){
//       return query(sql, params);
//       }, 2000);
//     }else{
//       retryCounter = 0;
//       console.log("Error in SQL Query " + error);
//       return {"Result": "Error"};
//     }
//   }
// }

// module.exports = {
//   query,
//   queryPG
// };


