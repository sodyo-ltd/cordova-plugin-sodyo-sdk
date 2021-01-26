var exec = require('cordova/exec')

var callbacks = {}

function registerCallback(name, callback) {
  if (!name || typeof callback !== 'function') {
    return false
  }

  callbacks[name] = callback
}

function removeCallback(name) {
  if (!callbacks.hasOwnProperty(name)) {
    return false
  }

  return delete callbacks[name]
}

document.addEventListener('deviceready', function() {
  exec(
    function(callbackName, ...args) {
      if (!callbacks.hasOwnProperty(callbackName)) {
        console.error('Callback "' + callbackName + '" are not found')
        return
      }

      callbacks[callbackName](...args)
    },
    function(e) {
      console.error(e.stack || e)
      throw e
    },
    'SodyoSDKWrapper',
    'registerCallback',
    [],
  )
})

module.exports.init = function(apiKey, success, error) {
  return exec(success, error, 'SodyoSDKWrapper', 'init', [apiKey])
}

module.exports.setErrorListener = function(callback) {
  registerCallback('sodyoError', callback)
}

module.exports.start = function(success, error) {
  return exec(success, error, 'SodyoSDKWrapper', 'start', [])
}

module.exports.close = function() {
  return exec(null, null, 'SodyoSDKWrapper', 'close', [])
}

module.exports.setUserInfo = function(userInfo) {
  return exec(null, null, 'SodyoSDKWrapper', 'setUserInfo', [userInfo])
}

module.exports.setScannerParams = function(scannerPreferences) {
  return exec(null, null, 'SodyoSDKWrapper', 'setScannerParams', [scannerPreferences])
}

module.exports.setCustomAdLabel = function(label) {
  return exec(null, null, 'SodyoSDKWrapper', 'setCustomAdLabel', [label])
}

module.exports.setAppUserId = function(appUserId) {
  return exec(null, null, 'SodyoSDKWrapper', 'setAppUserId', [appUserId])
}

module.exports.setOverlayView = function(html) {
  return exec(null, null, 'SodyoSDKWrapper', 'setOverlayView', [html])
}

module.exports.setOverlayCallback = function(callbackName, callback) {
  registerCallback(callbackName, callback)
}

module.exports.setSodyoEventListener = function(callback) {
  const callbackWrapper = (eventName, eventData) => {
    try {
      callback(eventName, JSON.parse(eventData))
    } catch (e) {
      callback(eventName, eventData)
    }
  }

  registerCallback('sodyoEvent', callbackWrapper)

  return () => removeCallback('sodyoEvent')
}
