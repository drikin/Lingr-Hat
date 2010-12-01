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

@synthesize window, mainWebView, singleShotTimer, unreadCheckTimer;

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
    numOfUnreadMessages = 0;
    bEnableCheking = NO;
    
	// set UserDefault
    [Lingr_HatAppDelegate setupDefaults];

	// init member variables
	self.singleShotTimer = nil;
	
    // set URL
	[mainWebView setMainFrameURL:LH_LINGR_BASEURL];

    self.unreadCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                             target:self 
                                                           selector:@selector(periodicInvoker) 
                                                           userInfo:nil repeats:YES];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    if (self.unreadCheckTimer != nil) {
        [self.unreadCheckTimer invalidate];
        [self.unreadCheckTimer release];
        self.unreadCheckTimer = nil;
    }
    return NSTerminateNow;
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
	[self cancelSingleshotTimer];
    [self disableLogging];

	// Reset unread and disable UnreadChecking
    bEnableCheking = NO;
	
    // Hide Notification Badge
    NSDockTile *dockTile = [NSApp dockTile];
    [dockTile setBadgeLabel:nil];


    NSString *script = @"numOfUnreadMessage = 0;";
    [[mainWebView windowScriptObject] evaluateWebScript:script];
}


- (void)applicationDidResignActive:(NSNotification *)aNotification {

    
    [self cancelSingleshotTimer];

    // invoke oneshot timer
	float fIntervalSec = [[NSUserDefaults standardUserDefaults] floatForKey:@"checkLogInterval"];
	fIntervalSec = fIntervalSec == 0.0 ?  LH_NON_ACTIVE_DEFAULT_TIMER_INTERVAL : fIntervalSec;
	self.singleShotTimer = [NSTimer scheduledTimerWithTimeInterval:fIntervalSec
                                             target:self
                                           selector:@selector(enableLogging)
                                           userInfo:nil
                                            repeats:NO];
    [self.singleShotTimer retain];
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


-(int) countUnreadMessagesFromScript
{
    NSString *script = @"numOfUnreadMessage";
    id result = [[mainWebView windowScriptObject] evaluateWebScript:script];
    if ([result isMemberOfClass:[WebUndefined class]]) {
        return -1;
    } else {
        return [result intValue];
    }
}


-(void)periodicInvoker
{
    // 
    if (bEnableCheking == NO) {
        return;
    }

    // injection for counting unread messages
    static BOOL bInjected =  NO;
    if (bInjected == NO) {
        NSString *script = @"\
        var numOfUnreadMessage = 0;\
        lingr.ui.insertMessageFunc = lingr.ui.insertMessage;\
        lingr.ui.insertMessage = function(a,b) {\
            numOfUnreadMessage += 1;\
            return this.insertMessageFunc(a,b);\
        };\
        ";
        id result = [[mainWebView windowScriptObject] evaluateWebScript:script];
        if ([result isMemberOfClass:[WebUndefined class]]) {
            NSLog(@"Injection Error occurs");
        } else {
            NSLog(@"Success injection ");
            bInjected = YES; // once for all
        }        
    }
    
    // check and show counted number of unread messages
    if ([NSApp isActive] == NO) {
        int unreadmessage = [self countUnreadMessagesFromScript];
        if (unreadmessage > 0) {
            NSDockTile *dockTile = [NSApp dockTile];
            [dockTile setBadgeLabel:[NSString stringWithFormat:@"%d", unreadmessage]];
            if (unreadmessage != numOfUnreadMessages) {
                [NSApp requestUserAttention:NSInformationalRequest];
            }
        }
        numOfUnreadMessages = unreadmessage < 0 ? 0 : unreadmessage ;
    }
}



#pragma mark -
#pragma mark Methods

- (void)enableLogging 
{
	// change message color to gray
    NSMutableString *script = [NSMutableString stringWithString:@"\
		var d = document.getElementsByClassName('decorated'); \
		for (var i = 0; i < d.length; i++) { \
			var p = d[i].getElementsByTagName('p'); \
			for (var j = 0; j < p.length; j++) { \
				p[j].style.color = 'DarkGray'; \
			} \
		} \
	"];

    // bgScroll
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"bgScroll"]) {
		[script appendString:@"lingr.ui.getActiveRoom = function() {};"];
	}
    
    // reset variables for counting unread message
    [script appendString:@"numOfUnreadMessage = 0;"];
     
    // evaluate javascript
	[[mainWebView windowScriptObject] evaluateWebScript:script];

    // enable to count unread messages
    bEnableCheking = YES;
}


- (void)disableLogging
{
    // bgScroll
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"bgScroll"]) {
        NSString *script = @"\
                           lingr.ui.getActiveRoom = function() {return extractId($$('#left .active')[0]);}; \
                           ";
        [[mainWebView windowScriptObject] evaluateWebScript:script];
    }

    // disable to count unread messages
    bEnableCheking = NO;
}


- (void)cancelSingleshotTimer 
{
    // cancel timer which has not invoked
    if (self.singleShotTimer != nil) {
        [self.singleShotTimer invalidate];
        [self.singleShotTimer release];
        self.singleShotTimer = nil;
    }
}

@end
