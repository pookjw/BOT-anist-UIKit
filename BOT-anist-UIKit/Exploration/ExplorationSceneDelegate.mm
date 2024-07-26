//
//  ExplorationSceneDelegate.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/26/24.
//

#import "ExplorationSceneDelegate.h"

#if TARGET_OS_VISION

#import "ExplorationViewController.h"

NSMutableDictionary<NSUUID *, NSData *> *_robotDataByIdentifiers = [NSMutableDictionary new];

@implementation ExplorationSceneDelegate

+ (NSMutableDictionary<NSUUID *,NSData *> *)robotDataByIdentifiers {
    return _robotDataByIdentifiers;
}

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:reinterpret_cast<UIWindowScene *>(scene)];
    
    NSUUID *robotDataIdentifier = connectionOptions.userActivities.allObjects.firstObject.userInfo[@"robotDataIdentifier"];
    
    NSData *robotData_NSData = ExplorationSceneDelegate.robotDataByIdentifiers[robotDataIdentifier];
    
    const RobotData robotData = RobotData::getRobotDataFromNSData(robotData_NSData);
    
    [ExplorationSceneDelegate.robotDataByIdentifiers removeObjectForKey:robotDataIdentifier];
    
    ExplorationViewController *rootViewController = [[ExplorationViewController alloc] initWithRobotData:robotData];
    window.rootViewController = rootViewController;
    [rootViewController release];
    
    self.window = window;
    [window makeKeyAndVisible];
    [window release];
}

@end

#endif
