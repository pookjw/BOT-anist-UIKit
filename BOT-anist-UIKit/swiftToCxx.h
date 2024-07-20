//
//  swiftToCxx.h
//  BOT-anist-UIKit
//
//  Created by Jinwoo Kim on 7/19/24.
//

#if defined(__cplusplus)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnon-modular-include-in-framework-module"
// Allow user to find the header using additional include paths
#if __has_include(<swiftToCxx/_SwiftCxxInteroperability.h>)
#include <swiftToCxx/_SwiftCxxInteroperability.h>
// Look for the C++ interop support header relative to clang's resource dir:
//  '<toolchain>/usr/lib/clang/<version>/include/../../../swift/swiftToCxx'.
#elif __has_include(<../../../swift/swiftToCxx/_SwiftCxxInteroperability.h>)
#include <../../../swift/swiftToCxx/_SwiftCxxInteroperability.h>
#elif __has_include(<../../../../../lib/swift/swiftToCxx/_SwiftCxxInteroperability.h>)
//  '<toolchain>/usr/local/lib/clang/<version>/include/../../../../../lib/swift/swiftToCxx'.
#include <../../../../../lib/swift/swiftToCxx/_SwiftCxxInteroperability.h>
#else
#error "Cannot fund '_SwiftCxxInteroperability.h'"
#endif
#pragma clang diagnostic pop
#endif
