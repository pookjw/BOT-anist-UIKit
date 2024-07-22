//
//  main.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/17/24.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "RobotData.hpp"
#import "BOT_anist_UIKit-Swift.h"

int main(int argc, char * argv[]) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    @autoreleasepool {
        BOT_anist_UIKit::mainHandler();
    }
    
    int result = UIApplicationMain(argc, argv, nil, NSStringFromClass(AppDelegate.class));
    [pool release];
    return result;
}
