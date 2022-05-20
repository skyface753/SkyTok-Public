const env = process.env;



const config = {
    postgres: {
      host: env.POSTGRES_HOST || null,
    },
    mongodb: {
      host: env.MONGO_HOST || null,
    },
    redis: {
      host: env.REDIS_HOST || null,
    }
  };
  
  
  module.exports = config;