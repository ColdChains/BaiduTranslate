//
//  AppDelegate.m
//  BaiduTranslate
//
//  Created by lax on 2023/4/4.
//

#import "AppDelegate.h"
#import "TranslateViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [[TranslateViewController alloc] init];
    
    return YES;
}

@end
