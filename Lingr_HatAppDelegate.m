//
//  Lingr_HatAppDelegate.m
//  Lingr Hat
//
//  Created by Kohichi Aoki on 11/2/10.
//  Copyright 2010 drikin.com. All rights reserved.
//

#import "Lingr_HatAppDelegate.h"

@implementation Lingr_HatAppDelegate

@synthesize window, mainWebView;

NSTimer *timer = nil;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
    [mainWebView setMainFrameURL:@"http://lingr.com/"];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    [self cancelTimer];
    [self disableLogging];
}

- (void)applicationDidResignActive:(NSNotification *)aNotification {
    [self cancelTimer];
    timer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                             target:self
                                           selector:@selector(enableLogging)
                                           userInfo:nil
                                            repeats:NO];
    [timer retain];
}

- (void)                  webView : (WebView      *) sender
   decidePolicyForNewWindowAction : (NSDictionary *) info
                          request : (NSURLRequest *) request
                     newFrameName : (NSString     *) frameName
                 decisionListener : (id<WebPolicyDecisionListener>) listener
{
    [listener ignore];
    [[NSWorkspace sharedWorkspace] openURL:[request URL]];
}

- (void)enableLogging {
    NSString *script = @"\
        var d = document.getElementsByClassName('decorated'); \
        for (var i = 0; i < d.length; i++) { \
            var p = d[i].getElementsByTagName('p'); \
            for (var j = 0; j < p.length; j++) { \
                p[j].style.color = 'DarkGray'; \
            } \
        } \
        lingr.ui.getActiveRoom = function() {}; \
    ";
    [[mainWebView windowScriptObject] evaluateWebScript:script];
}

- (void)disableLogging {
    NSString *script = @"\
    lingr.ui.getActiveRoom = function() {return extractId($$('#left .active')[0]);}; \
    ";
    [[mainWebView windowScriptObject] evaluateWebScript:script];
}

- (void)cancelTimer {
    if (timer != nil) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
}
@end
