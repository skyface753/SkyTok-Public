var logModel = require('../models/log');

var insetCounter = 0;
var consoleExport = {
    log: function(msg){
        writeLog(msg, 'log');
    },
    info: function(msg){
        writeLog(msg, 'info');
    },
    error: function(msg){
        writeLog(msg, 'error');
    },
    warn: function(msg){
        writeLog(msg, 'warn');
    },
    debug: function(msg){
        writeLog(msg, 'debug');
    }
}

function writeLog(msg, level){
    insetCounter++;
    logModel.create({
        level: level,
        message: msg,
        dateTime: new Date()
    });
    console.log(msg);
    if(insetCounter > 20){
        deleteOldLogs();
    }

}

function deleteOldLogs(){
    // Get Yesterday's Date
    var yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    // Delete all logs older than yesterday
    logModel.deleteMany({dateTime: {$lt: yesterday}});
}

module.exports = consoleExport;