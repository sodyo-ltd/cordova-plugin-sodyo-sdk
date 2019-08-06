var exec = require('cordova/exec')

module.exports.init = function(apiKey, success, error) {
  return exec(success, error, 'SodyoSDKWrapper', 'init', [apiKey])
}

module.exports.start = function(success, error) {
  return exec(success, error, 'SodyoSDKWrapper', 'start', [])
}

module.exports.close = function() {
  return exec(null, null, 'SodyoSDKWrapper', 'close', [])
}
