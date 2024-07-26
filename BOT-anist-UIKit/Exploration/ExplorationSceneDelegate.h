//
//  ExplorationSceneDelegate.h
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/26/24.
//

#import <TargetConditionals.h>

#if TARGET_OS_VISION

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExplorationSceneDelegate : UIResponder <UIWindowSceneDelegate>
/*
 원래는 이렇게 하였으나
 
 ```objc
 NSUserActivity *userActivity = [[NSUserActivity alloc] initWithActivityType:@"Exploration"];
 userActivity.userInfo = @{@"robotData": self.robotData.getNSData()};
 ```
 
 문제는 FB으로 넘어가면서 NSData가 Archive되고, 원래 NSData는 dealloc 되면서 RobotData가 소멸되고, Scene이 연결되면서 소멸된 RobotData에 접근하는 문제가 있었다.
 따라서 +[ExplorationSceneDelegate robotDataByIdentifiers]에서 NSData를 retain하는 구조로 한다.
 */
@property (class, retain, nonatomic, readonly, direct) NSMutableDictionary<NSUUID *, NSData *> *robotDataByIdentifiers;

@property (strong, nonatomic) UIWindow *window;
@end

NS_ASSUME_NONNULL_END

#endif
