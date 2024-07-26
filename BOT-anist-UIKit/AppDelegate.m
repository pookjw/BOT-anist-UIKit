//
//  AppDelegate.m
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/17/24.
//

#import "AppDelegate.h"
#import "SceneDelegate.h"
#import "ExplorationSceneDelegate.h"
#import <TargetConditionals.h>

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
#if TARGET_OS_VISION
    if ([options.userActivities.allObjects.firstObject.activityType isEqualToString:@"Exploration"]) {
        UISceneConfiguration *configuration = [connectingSceneSession.configuration copy];
        configuration.delegateClass = ExplorationSceneDelegate.class;
        return [configuration autorelease];
    }
#endif
    UISceneConfiguration *configuration = [connectingSceneSession.configuration copy];
    configuration.delegateClass = SceneDelegate.class;
    return [configuration autorelease];
}

@end
