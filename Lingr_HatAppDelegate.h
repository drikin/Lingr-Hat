//
//  Lingr_HatAppDelegate.h
//  Lingr Hat
//
//  Created by Kohichi Aoki on 11/2/10.
//  Copyright 2010 drikin.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface Lingr_HatAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    WebView *mainWebView;
@private
    NSTimer *timer;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *mainWebView;

@property (nonatomic, assign)  NSTimer *timer;

+ (void)initUserDefaults;
- (void)enableLogging;
- (void)disableLogging;
- (void)cancelTimer;
@end
