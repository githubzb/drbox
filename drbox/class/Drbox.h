//
//  Drbox.h
//  drbox
//
//  Created by dr.box on 2020/7/14.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<drbox/Drbox.h>)

FOUNDATION_EXPORT double drboxVersionNumber;
FOUNDATION_EXPORT const unsigned char drboxVersionString[];

#import <drbox/DrboxMacro.h>
// cateogries
#import <drbox/NSObject+drbox.h>
#import <drbox/NSData+drbox.h>
#import <drbox/NSString+drbox.h>
#import <drbox/NSNumber+drbox.h>
#import <drbox/NSArray+drbox.h>
#import <drbox/NSDictionary+drbox.h>
#import <drbox/NSDate+drbox.h>
#import <drbox/NSNotificationCenter+drbox.h>
#import <drbox/NSKeyedArchiver+drbox.h>
#import <drbox/NSKeyedUnarchiver+drbox.h>
#import <drbox/NSTimer+drbox.h>
#import <drbox/NSInvocation+drbox.h>
#import <drbox/NSBundle+drbox.h>
#import <drbox/UIColor+drbox.h>
#import <drbox/UIImage+drbox.h>
#import <drbox/UIView+drbox.h>
#import <drbox/UIControl+drbox.h>
#import <drbox/UIBarButtonItem+drbox.h>
#import <drbox/UIGestureRecognizer+drbox.h>
#import <drbox/UITextField+drbox.h>
#import <drbox/UIDevice+drbox.h>

// tools
#import <drbox/DRDictionaryParser.h>
#import <drbox/DRThreadPool.h>
#import <drbox/DRLock.h>
#import <drbox/DRDeallocHook.h>
#import <drbox/DRCGTools.h>
#import <drbox/DRDelegateProxy.h>
#import <drbox/DRBlockDescription.h>
#import <drbox/DRKeyChainStore.h>

// cache
#import <drbox/DRCache.h>

// layout
#import <drbox/UIView+DRLayout.h>
#import <drbox/UIScrollView+DRLayout.h>
#import <drbox/DRTableView.h>

// capture
#import <drbox/DRCaptureDevice.h>

#else

#import "DrboxMacro.h"
// cateogries
#import "NSObject+drbox.h"
#import "NSData+drbox.h"
#import "NSString+drbox.h"
#import "NSNumber+drbox.h"
#import "NSArray+drbox.h"
#import "NSDictionary+drbox.h"
#import "NSDate+drbox.h"
#import "NSNotificationCenter+drbox.h"
#import "NSKeyedArchiver+drbox.h"
#import "NSKeyedUnarchiver+drbox.h"
#import "NSTimer+drbox.h"
#import "NSInvocation+drbox.h"
#import "NSBundle+drbox.h"
#import "UIColor+drbox.h"
#import "UIImage+drbox.h"
#import "UIView+drbox.h"
#import "UIControl+drbox.h"
#import "UIBarButtonItem+drbox.h"
#import "UIGestureRecognizer+drbox.h"
#import "UITextField+drbox.h"
#import "UIDevice+drbox.h"

// tools
#import "DRDictionaryParser.h"
#import "DRThreadPool.h"
#import "DRLock.h"
#import "DRDeallocHook.h"
#import "DRCGTools.h"
#import "DRDelegateProxy.h"
#import "DRBlockDescription.h"
#import "DRKeyChainStore.h"

// cache
#import "DRCache.h"

// layout
#import "UIView+DRLayout.h"
#import "UIScrollView+DRLayout.h"
#import "DRTableView.h"

// capture
#import "DRCaptureDevice.h"

#endif
