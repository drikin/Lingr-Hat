//
//  Lingr_HatAppDelegate.m
//  Lingr Hat
//
//  Created by Kohichi Aoki on 11/2/10.
//  Copyright 2010 drikin.com. All rights reserved.
//

#import "Lingr_HatAppDelegate.h"

#define LH_LINGR_BASEURL  @"http://lingr.com/"

const float LH_NON_ACTIVE_DEFAULT_TIMER_INTERVAL = 30.0;

@implementation Lingr_HatAppDelegate

@synthesize window, mainWebView, timer;

+ (void)setupDefaults {
    NSDictionary   *userDefaultsValuesDict;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *initialValuesDict;
	
	// set UserDefaults Default
    userDefaultsValuesDict = [NSDictionary dictionaryWithObjectsAndKeys:
			/* Default Values Here VALUE,KEY and VALUE MUST BE OBJECT */
							  [NSNumber numberWithBool:NO], @"bgScroll",
							  [NSNumber numberWithFloat:LH_NON_ACTIVE_DEFAULT_TIMER_INTERVAL], @"checkLogInterval",
							  [NSNumber numberWithInt:800], @"windowWidth",
							  [NSNumber numberWithInt:700], @"windowHeight",
			/* Default Values Ended */
			nil];
	[defaults registerDefaults:userDefaultsValuesDict];

    // enable for Reset
	NSArray *resettableUserDefaultsKeys = [NSArray arrayWithObjects:@"bgScroll",
																	@"checkLogInterval",
																	@"windowWidth",
																	@"windowHeight",
										   nil];
    initialValuesDict=[userDefaultsValuesDict dictionaryWithValuesForKeys:resettableUserDefaultsKeys];    
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initialValuesDict];
}


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    // initialize member variables
    numOfMessage = 0;
    numOfUnreadMessage = 0;
    
	// set UserDefault
    [Lingr_HatAppDelegate setupDefaults];

	// init member variables
	self.timer = nil;
	
    // set URL
	[mainWebView setMainFrameURL:LH_LINGR_BASEURL]; 
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    [self cancelTimer];
    [self disableLogging];

    // Hide Notification Badge
    NSDockTile *dockTile = [NSApp dockTile];
    [dockTile setShowsApplicationBadge:YES];
    [dockTile setBadgeLabel:nil];
}

- (void)applicationDidResignActive:(NSNotification *)aNotification {
    [self cancelTimer];

    bEvaluatedOnDeactive = NO;	
    float fIntervalSec = [[NSUserDefaults standardUserDefaults] floatForKey:@"checkLogInterval"];
	fIntervalSec = fIntervalSec == 0.0 ?  LH_NON_ACTIVE_DEFAULT_TIMER_INTERVAL : fIntervalSec;
	self.timer = [NSTimer scheduledTimerWithTimeInterval:fIntervalSec
                                             target:self
                                           selector:@selector(enableLogging)
                                           userInfo:nil
                                            repeats:YES];
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
    if (!bEvaluatedOnDeactive) {
        NSMutableString *script = [NSMutableString stringWithString:@"\
            var numOfElements = 0;\
            var d = document.getElementsByClassName('decorated'); \
            for (var i = 0; i < d.length; i++) { \
                var p = d[i].getElementsByTagName('p'); \
                for (var j = 0; j < p.length; j++) { \
                    p[j].style.color = 'DarkGray'; \
                    numOfElements += 1; \
                } \
            } \
        "];

        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"bgScroll"]) {
            [script appendString:@"lingr.ui.getActiveRoom = function() {};"];
        }
        [script appendString:@"numOfElements"];

        id result = [[mainWebView windowScriptObject] evaluateWebScript:script];
        if ([result isMemberOfClass:[WebUndefined class]]) {
            //error
            return;
        } else {
            //NSLog([result stringValue]);
            numOfMessage = [result intValue];
        }
        bEvaluatedOnDeactive = YES;
    } else {
        NSMutableString *script = [NSMutableString stringWithString:@"\
                                   var numOfElements = 0;\
                                   var d = document.getElementsByClassName('decorated'); \
                                   for (var i = 0; i < d.length; i++) { \
                                   var p = d[i].getElementsByTagName('p'); \
                                   for (var j = 0; j < p.length; j++) { \
                                   numOfElements += 1; \
                                   } \
                                   } \
                                   "];
        
        [script appendString:@"numOfElements"];
        id result = [[mainWebView windowScriptObject] evaluateWebScript:script];
        if ([result isMemberOfClass:[WebUndefined class]]) {
            //error
        } else {
            int currentNumOfUnreadMessage = [result intValue] - numOfMessage;
            NSLog(@"Num of Unread Messages: %d", currentNumOfUnreadMessage);

            NSDockTile *dockTile = [NSApp dockTile];
            
            // Show Notification Badge
            [dockTile setShowsApplicationBadge:YES];
            if (currentNumOfUnreadMessage > 0) {
                [dockTile setBadgeLabel:[NSString stringWithFormat:@"%d",currentNumOfUnreadMessage]];
                if (numOfUnreadMessage != currentNumOfUnreadMessage) {
                    //Dock Bounce
                    [NSApp requestUserAttention:NSInformationalRequest];
                }                
                numOfUnreadMessage = currentNumOfUnreadMessage;
            } else {
                [dockTile setBadgeLabel:nil];
            }
        }
    }    
}

- (void)disableLogging {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"bgScroll"]) {
        NSString *script = @"\
                           lingr.ui.getActiveRoom = function() {return extractId($$('#left .active')[0]);}; \
                           ";
        [[mainWebView windowScriptObject] evaluateWebScript:script];
    }
}

- (void)cancelTimer {
    if (self.timer != nil) {
        [self.timer invalidate];
        [self.timer release];
        self.timer = nil;
    }
}

@end
