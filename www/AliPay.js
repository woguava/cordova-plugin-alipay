var exec = require('cordova/exec');

exports.starPay = function(orderInfo, success, error) {
    exec(success, error, "AliPay", "starPay", [orderInfo]);
};
