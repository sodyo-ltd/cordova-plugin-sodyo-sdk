/********* SodyoSDKWrapper.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <SodyoSDK/SodyoSDK.h>

@interface SodyoSDKWrapper : CDVPlugin <SodyoSDKDelegate, SodyoMarkerDelegate, UIWebViewDelegate> {
    UIViewController *sodyoScanner;
}

- (void)init:(CDVInvokedUrlCommand*)command;

- (void)start:(CDVInvokedUrlCommand*)command;

- (void)close:(CDVInvokedUrlCommand*)command;

- (void)setUserInfo:(CDVInvokedUrlCommand*)command;

- (void)setCustomAdLabel:(CDVInvokedUrlCommand*)command;

- (void)setAppUserId:(CDVInvokedUrlCommand*)command;

- (void)setScannerParams:(CDVInvokedUrlCommand*)command;

- (void)setOverlayView:(CDVInvokedUrlCommand*)command;

- (void)registerCallback:(CDVInvokedUrlCommand*)command;

@property (nonatomic, retain) NSString *eventCallbackId;
@property (nonatomic, retain) NSString *startCallbackId;
@property (nonatomic, retain) NSString *scannerCallbackId;
@property (nonatomic, retain) NSString *htmlOverlay;

@end

@implementation SodyoSDKWrapper

- (void)init:(CDVInvokedUrlCommand*)command
{
    self.startCallbackId = command.callbackId;
    NSString* code = [command.arguments objectAtIndex:0];

    if (code != nil) {
        [SodyoSDK LoadApp:code Delegate:self MarkerDelegate:self PresentingViewController:nil];
    } else {
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)start:(CDVInvokedUrlCommand*)command
{
    NSLog(@"start");
    self.scannerCallbackId = command.callbackId;
    [self launchSodyoScanner];
}

- (void)close:(CDVInvokedUrlCommand*)command
{
    NSLog(@"close");
    [self closeScanner];
}

- (void)setCustomAdLabel:(CDVInvokedUrlCommand*)command
{
    NSLog(@"setCustomAdLabel");
    NSString* labels = [command.arguments objectAtIndex:0];
    [SodyoSDK setCustomAdLabel:labels];
}

- (void)setAppUserId:(CDVInvokedUrlCommand*)command
{
    NSLog(@"setAppUserId");
    NSString* userId = [command.arguments objectAtIndex:0];
    [SodyoSDK setUserId:userId];
}

- (void)setUserInfo:(CDVInvokedUrlCommand*)command
{
    NSLog(@"setUserInfo");
    NSDictionary* userInfo = [command.arguments objectAtIndex:0];
    [SodyoSDK setUserInfo:userInfo];
}

- (void)setScannerParams:(CDVInvokedUrlCommand*)command
{
    NSLog(@"setScannerParams");
    NSDictionary* params = [command.arguments objectAtIndex:0];
    [SodyoSDK setScannerParams:params];
}

- (void)registerCallback:(CDVInvokedUrlCommand*)command
{
    NSLog(@"registerCallback");
    self.eventCallbackId = command.callbackId;
}

- (void)setOverlayView:(CDVInvokedUrlCommand*)command
{
    NSLog(@"setOverlayView");
    NSString* html = [command.arguments objectAtIndex:0];
    self.htmlOverlay = html;
}

- (void)setOverlayView
{
    if (!self.htmlOverlay) return;

    UIView *overlay = [SodyoSDK overlayView];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    webView.delegate = self;
    webView.opaque = NO;
    webView.backgroundColor = [UIColor clearColor];
    webView.scalesPageToFit = YES;
    [webView loadHTMLString:self.htmlOverlay baseURL:nil];
    [overlay addSubview:webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = request.URL;
        NSString *scheme = [url scheme];
        if ([scheme isEqualToString:@"sodyosdk"]) {
            NSString *absoluteUrl = [url absoluteString];
            NSArray *parsedUrl = [absoluteUrl componentsSeparatedByString:@"sodyosdk://"];
            if ([parsedUrl count] < 2) return NO;

            NSString *methodName = parsedUrl[1];
            [self callOverlayCallback:methodName];
        }
    }

    return YES;
}

- (void) callOverlayCallback:(NSString*)callackName {
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:callackName];
    [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCallbackId];
}

- (void) closeScanner {
    NSLog(@"closeScanner");
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) launchSodyoScanner {
    NSLog(@"launchSodyoScanner");
    self->sodyoScanner = [SodyoSDK initSodyoScanner];

    [self setOverlayView];
    [self.viewController presentViewController:self->sodyoScanner animated:YES completion:nil];
}

#pragma mark - SodyoSDKDelegate
- (void) onSodyoAppLoadSuccess:(NSInteger)AppID {
    NSLog(@"onSodyoAppLoadSuccess");
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.startCallbackId];
}

- (void) onSodyoAppLoadFailed:(NSInteger)AppID error:(NSError *)error {
    NSLog(@"Failed loading Sodyo: %@", error);
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.startCallbackId];
}

- (void) sodyoError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"sodyoError: %@", error.userInfo[@"NSLocalizedDescription"]);
        NSArray* params = @[@"sodyoError", error.userInfo[@"NSLocalizedDescription"]];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsMultipart:params];
        [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.eventCallbackId];
    });
}

- (void) SodyoMarkerDetectedWithData:(NSDictionary*)Data {
    NSLog(@"SodyoMarkerDetectedWithData: %@", Data[@"sodyoMarkerData"]);
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:Data[@"sodyoMarkerData"]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.scannerCallbackId];
}

@end

