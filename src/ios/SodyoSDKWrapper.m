/********* SodyoSDKWrapper.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <SodyoSDK/SodyoSDK.h>

@interface SodyoSDKWrapper : CDVPlugin <SodyoSDKDelegate, SodyoMarkerDelegate> {
  UIViewController *sodyoScanner;
}

- (void)init:(CDVInvokedUrlCommand*)command;

- (void)start:(CDVInvokedUrlCommand*)command;

- (void)close:(CDVInvokedUrlCommand*)command;

@property (nonatomic, retain) CDVInvokedUrlCommand *lastCommand;

@end

@implementation SodyoSDKWrapper

- (void)init:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* code = [command.arguments objectAtIndex:0];

    if (code != nil && [code length] > 0) {
        [SodyoSDK LoadApp:code Delegate:self MarkerDelegate:self PresentingViewController:nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)start:(CDVInvokedUrlCommand*)command
{
    self.lastCommand = command;
    [self launchSodyoScanner];
}

- (void)close:(CDVInvokedUrlCommand*)command
{
    [self closeScanner];
}

- (void) addCustomView {
    UIView *overlay = [SodyoSDK overlayView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
    label.text = @"Close";
    label.textColor = [UIColor whiteColor];
    label.center = overlay.center;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeScanner)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [label addGestureRecognizer:tapGestureRecognizer];
    label.userInteractionEnabled = YES;

    [overlay addSubview:label];
}

- (void) closeScanner {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) launchSodyoScanner {
    self->sodyoScanner = [SodyoSDK initSodyoScanner];

    [self addCustomView];
    [self.viewController presentViewController:self->sodyoScanner animated:YES completion:nil];
}

#pragma mark - SodyoSDKDelegate
- (void) onSodyoAppLoadSuccess:(NSInteger)AppID {
    NSLog(@"onSodyoAppLoadSuccess");
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.lastCommand.callbackId];
}

- (void) onSodyoAppLoadFailed:(NSInteger)AppID error:(NSError *)error {
    NSLog(@"Failed loading Sodyo: %@", error);
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.lastCommand.callbackId];
}

- (void) sodyoError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"sodyoError: %@", error.userInfo[@"NSLocalizedDescription"]);
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error.userInfo[@"NSLocalizedDescription"]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.lastCommand.callbackId];
    });
}

- (void) SodyoMarkerDetectedWithData:(NSDictionary*)Data {
    NSLog(@"SodyoMarkerDetectedWithData: %@", Data[@"sodyoMarkerData"]);
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:Data[@"sodyoMarkerData"]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.lastCommand.callbackId];
}

@end


