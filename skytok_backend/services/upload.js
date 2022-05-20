// import { PutObjectOutput, PutObjectRequest } from 'aws-sdk/clients/s3';
// import {AWSError} from 'aws-sdk/lib/error';
// import * as S3 from 'aws-sdk/clients/s3';
// import Connect from './connection';
const Connect = require('./connection');

 async function Upload(bucket, file, objectName, path, mime) {
    // return new Promise<string>((resolve, reject) => {
        const s3 = Connect();
        const params = { Bucket: bucket, Key: objectName, Body: file.buffer, ACL: 'public-read', ContentType: file.mimetype, mime: mime };
        var response = await s3.putObject(params, (err, data) => {
            if (err) console.log(err);
            return(`${process.env.S3_ENDPOINT_URL}${bucket}/${path}/${objectName}`);
        }).promise();
        return response;
    // });
}

async function getFile(bucket, objectName, path) {
    // return new Promise<string>((resolve, reject) => {
        const s3 = Connect();
        const params = { Bucket: bucket, Key: objectName };
        var response = await s3.getObject(params, (err, data) => {
            if (err) throw err;
            return data;
        }).promise();
        return response;
    // });
}


module.exports = {Upload, getFile};