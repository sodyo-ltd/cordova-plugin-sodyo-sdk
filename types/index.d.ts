declare var SodyoSDK: {
  init (apiKey: string, successCallback?: () => void, errorCallback?: (msg: string) => void): void
  setErrorListener (errorCallback: (err: string) => void): void
  start (successCallback?: (immediateData?: string) => void, errorCallback?: (msg: string) => void): void
  close (): void
  setUserInfo (userInfo: { [key: string]: string | number }): void
  setScannerParams (scannerPreferences: { [key: string]: string | number }): void
  setCustomAdLabel (label: string): void
  setAppUserId (appUserId: string): void
  setOverlayView (html: string): void
  setOverlayCallback (callbackName: string, callback: () => void): void
  setSodyoLogoVisible (isVisible: boolean): void
  performMarker (markerId: string): void
}
