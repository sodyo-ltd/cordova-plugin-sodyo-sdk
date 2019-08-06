declare var SodyoSDKWrapper: {
  init (apiKey: string, successCallback?: () => void, errorCallback?: (msg: string) => void): void
  start (successCallback?: (immediateData?: string) => void, errorCallback?: (msg: string) => void): void
  close (): void
}
