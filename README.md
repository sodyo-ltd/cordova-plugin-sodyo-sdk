
# Sodyo SDK Cordova Plugin that wraps Sodyo sdk for android and ios

[SodyoSDK for iOS](https://github.com/sodyo-ltd/SodyoSDKPod) v 3.40.041
[SodyoSDK for Android](https://search.maven.org/search?q=a:sodyo-android-sdk) v 3.42.021


## Install
Requires Cordova > 5.x.x

Requires multidex support
```
cordova plugin add cordova-plugin-enable-multidex
```
Install the plugin

    cordova plugin add @sodyo/cordova-plugin-sodyo-sdk

## Initialization and quick start
Init the plugin with your Sodyo App Key project token with
```
SodyoSDK.init(your-app-key,
    function(){ /* successful init */ },
    function(){ /* fail */})
```
Open the Sodyo scanner
```
SodyoSDK.start(
    function(immedateContentData){ /* data content callback */ },
    function(){ /* fail */})
```
Close Sodyo scanner
```
SodyoSDK.close()
```

