const Connect = require('./connection');

async function getS3File(bucket, objectName) {
    const s3 = Connect();
    const params = { Bucket: bucket, Key: objectName };
    var response = await s3.getObject(params, (err, data) => {
        if (err) console.log(err);
        return(`${process.env.S3_ENDPOINT_URL}${bucket}/${objectName}`);
    }).promise();
    return response;
}

module.exports = getS3File;