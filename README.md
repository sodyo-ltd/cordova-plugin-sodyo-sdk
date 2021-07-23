
# Sodyo SDK Cordova Plugin that wraps Sodyo sdk for android and ios

[SodyoSDK for iOS](https://github.com/sodyo-ltd/SodyoSDKPod) v 3.54.22

[SodyoSDK for Android](https://search.maven.org/search?q=a:sodyo-android-sdk) v 3.54.27


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
    function(){ /* successful init callback */ },
    function(){ /* fail init callback */})
```

Set the Sodyo error listener
```
SodyoSDK.setErrorListener(
    function(err){ /* fail callback */ }
)
```

Open the Sodyo scanner
```
SodyoSDK.start(
    function(markerData){ /* data content callback */ },
    function(){ /* fail */}
)
```

Set Sodyo event listener (events from scanner)
```
interface IEventData {
    MarkerValue: string
    ActionType?: string // for example, 'CLOSE'
    Parameters?: { [key: string]: string } // for example, { "color":"#ffffff" }
}

const unsubscribe = SodyoSDK.setSodyoEventListener((eventName, eventData) => {
...
})

unsubscribe()
```

Close Sodyo scanner
```
SodyoSDK.close()
```

Personal User Information

```
SodyoSDK.setUserInfo(userInfo)
```

User Identification (ID)
```
SodyoSDK.setAppUserId(userId)
```

Setting Scanner Preferences
```
SodyoSDK.setScannerParams(scannerPreferences)
```

Personalized Content
```
SodyoSDK.setCustomAdLabel(label)
```
`The label may include one or more tags in comma-separated values (CSV) format as follows: “label1,label2,label3”`

Customizing the scanner user interface
```
// set any html (with css)
SodyoSDK.setOverlayView('<a href="sodyosdk://handleClose">Close</a>') 

// define a handler for the button
SodyoSDK.setOverlayCallback('handleClose', () => { /* do something */ });
```

