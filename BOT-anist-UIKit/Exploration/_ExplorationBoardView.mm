//
//  _ExplorationBoardView.mm
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/26/24.
//

#import "_ExplorationBoardView.h"

@implementation _ExplorationBoardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.systemCyanColor;
    }
    
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(200., 100.);
}

@end
