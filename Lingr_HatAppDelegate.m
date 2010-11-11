//
//  Lingr_HatAppDelegate.m
//  Lingr Hat
//
//  Created by Kohichi Aoki on 11/2/10.
//  Copyright 2010 drikin.com. All rights reserved.
//

#import "Lingr_HatAppDelegate.h"

#define LINGR_HAT_LINGR_BASEURL  @"http://lingr.com/"

const int LINGR_HAT_NON_ACTIVE_TIMER_INTERVAL = 15.0; //30sec is too long to check

@implementation Lingr_HatAppDelegate

@synthesize window, mainWebView, timer;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [mainWebView setMainFrameURL:LINGR_HAT_LINGR_BASEURL];
    self.timer = nil;
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    [self cancelTimer];
    [self disableLogging];
}

- (void)applicationDidResignActive:(NSNotification *)aNotification {
    [self cancelTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:LINGR_HAT_NON_ACTIVE_TIMER_INTERVAL
                                             target:self
                                           selector:@selector(enableLogging)
                                           userInfo:nil
                                            repeats:NO];
    [self.timer retain];
}

#pragma mark -
#pragma mark WebPolicyDelegate

- (void)                  webView : (WebView      *) sender
   decidePolicyForNewWindowAction : (NSDictionary *) info
                          request : (NSURLRequest *) request
                     newFrameName : (NSString     *) frameName
                 decisionListener : (id<WebPolicyDecisionListener>) listener
{
    [listener ignore];
    [[NSWorkspace sharedWorkspace] openURL:[request URL]];
}

#pragma mark -
#pragma mark Methods

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
    if (self.timer != nil) {
        [self.timer invalidate];
        [self.timer release];
        self.timer = nil;
    }
}

@end
