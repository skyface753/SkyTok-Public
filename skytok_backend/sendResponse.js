

let sendResponse = {
    error: function(res, message){ 
        res.status(400).send({
            error: true,
            message: message
        });
    },
    success: function(res, response){
        res.status(200).send({
            error: false,
            response: response
        });
    }
}


module.exports = sendResponse;