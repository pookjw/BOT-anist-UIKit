//
//  MRUISize3D.h
//  MiscellaneousMRUIKit
//
//  Created by Jinwoo Kim on 6/29/24.
//

#import <TargetConditionals.h>

#if TARGET_OS_VISION

#import <CoreGraphics/CoreGraphics.h>

struct MRUISize3D {
    CGFloat width;
    CGFloat height;
    CGFloat depth;
};

static inline MRUISize3D MRUISize3DMake(CGFloat width, CGFloat height, CGFloat depth) {
    MRUISize3D size3D;
    size3D.width = width;
    size3D.height = height;
    size3D.depth = depth;
    return size3D;
}

#endif
