//
//  main.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/17/24.
//

#import <UIKit/UIKit.h>
#import <TargetConditionals.h>
#import "AppDelegate.h"
#import "RobotData.hpp"
#import "BOT_anist_UIKit-Swift.h"

int main(int argc, char * argv[]) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    @autoreleasepool {
        BOT_anist_UIKit::mainHandler();
        
#if TARGET_OS_VISION
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.apple.UIKit"];
        
        [userDefaults setObject:@YES forKey:@"MRUIEnableOrnamentWindowDebugVis"];
        [userDefaults setObject:@YES forKey:@"MRUIEnableTextEffectstWindowDebugVis"];
        
        [userDefaults release];
#endif
    }
    
    int result = UIApplicationMain(argc, argv, nil, NSStringFromClass(AppDelegate.class));
    [pool release];
    return result;
}
