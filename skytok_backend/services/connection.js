// import * as S3 from 'aws-sdk/clients/s3';
const S3 = require('aws-sdk/clients/s3');


 function Connect(path) {
    return new S3({
        apiVersion: 'latest',
        endpoint: `${process.env.S3_ENDPOINT_URL}`,
        s3ForcePathStyle: true,
        credentials: {
            accessKeyId: process.env.S3_ACCESS_KEY,
            secretAccessKey: process.env.S3_SECRET_KEY,
        },
        signatureVersion: 'v4',
    });
}

module.exports = Connect;