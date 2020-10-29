//
//  DRLayout.h
//  drbox
//
//  Created by dr.box on 2020/7/24.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <yoga/Yoga.h>
#import <yoga/YGEnums.h>
#import <yoga/YGMacros.h>

YG_EXTERN_C_BEGIN

/// 构建点值
extern YGValue DRPointValue(CGFloat value);
/// 构建百分比值[0, 100]（按父视图尺寸的百分比计算）
extern YGValue DRPercentValue(CGFloat value);

YG_EXTERN_C_END

typedef NS_OPTIONS(NSInteger, DRSizeFlexibility) {
    DRSizeFlexibilityWidth = 1 << 0,
    DRSizeFlexibilityHeight = 1 << 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface DRLayout : NSObject

@property (nonatomic, assign, readonly) YGNodeRef node;

- (instancetype)initWithView:(UIView *)view;

- (instancetype)init
    __attribute__((unavailable("you are not meant to initialise DRLayout")));

/**
 Make default init unavailable, as it will not initialise YGNode which is
 required for the setters and getters of YGLayout's properties to work properly.
 */
+ (instancetype)new
    __attribute__((unavailable("you are not meant to initialise DRLayout")));

/**
  The property that decides if we should include this view when calculating
  layout. Defaults to YES.
 */
@property (nonatomic, readwrite, assign, setter=setIncludedInLayout:) BOOL isIncludedInLayout;

/**
 The property that decides during layout/sizing whether or not styling properties should be applied.
 Defaults to NO.
 */
@property (nonatomic, readwrite, assign, setter=setEnabled:) BOOL isEnabled;

@property (nonatomic, readwrite, assign) YGDirection direction;
@property (nonatomic, readwrite, assign) YGFlexDirection flexDirection;
@property (nonatomic, readwrite, assign) YGJustify justifyContent;
@property (nonatomic, readwrite, assign) YGAlign alignContent;
@property (nonatomic, readwrite, assign) YGAlign alignItems;
@property (nonatomic, readwrite, assign) YGAlign alignSelf;
@property (nonatomic, readwrite, assign) YGPositionType position;
@property (nonatomic, readwrite, assign) YGWrap flexWrap;
@property (nonatomic, readwrite, assign) YGOverflow overflow;
@property (nonatomic, readwrite, assign) YGDisplay display;

@property (nonatomic, readwrite, assign) CGFloat flex;
@property (nonatomic, readwrite, assign) CGFloat flexGrow;
@property (nonatomic, readwrite, assign) CGFloat flexShrink;
@property (nonatomic, readwrite, assign) YGValue flexBasis;

@property (nonatomic, readwrite, assign) YGValue left;
@property (nonatomic, readwrite, assign) YGValue top;
@property (nonatomic, readwrite, assign) YGValue right;
@property (nonatomic, readwrite, assign) YGValue bottom;
@property (nonatomic, readwrite, assign) YGValue start;
@property (nonatomic, readwrite, assign) YGValue end;

@property (nonatomic, readwrite, assign) YGValue marginLeft;
@property (nonatomic, readwrite, assign) YGValue marginTop;
@property (nonatomic, readwrite, assign) YGValue marginRight;
@property (nonatomic, readwrite, assign) YGValue marginBottom;
@property (nonatomic, readwrite, assign) YGValue marginStart;
@property (nonatomic, readwrite, assign) YGValue marginEnd;
@property (nonatomic, readwrite, assign) YGValue marginHorizontal;
@property (nonatomic, readwrite, assign) YGValue marginVertical;
@property (nonatomic, readwrite, assign) YGValue margin;

@property (nonatomic, readwrite, assign) YGValue paddingLeft;
@property (nonatomic, readwrite, assign) YGValue paddingTop;
@property (nonatomic, readwrite, assign) YGValue paddingRight;
@property (nonatomic, readwrite, assign) YGValue paddingBottom;
@property (nonatomic, readwrite, assign) YGValue paddingStart;
@property (nonatomic, readwrite, assign) YGValue paddingEnd;
@property (nonatomic, readwrite, assign) YGValue paddingHorizontal;
@property (nonatomic, readwrite, assign) YGValue paddingVertical;
@property (nonatomic, readwrite, assign) YGValue padding;

@property (nonatomic, readwrite, assign) CGFloat borderLeftWidth;
@property (nonatomic, readwrite, assign) CGFloat borderTopWidth;
@property (nonatomic, readwrite, assign) CGFloat borderRightWidth;
@property (nonatomic, readwrite, assign) CGFloat borderBottomWidth;
@property (nonatomic, readwrite, assign) CGFloat borderStartWidth;
@property (nonatomic, readwrite, assign) CGFloat borderEndWidth;
@property (nonatomic, readwrite, assign) CGFloat borderWidth;

@property (nonatomic, readwrite, assign) YGValue width;
@property (nonatomic, readwrite, assign) YGValue height;
@property (nonatomic, readwrite, assign) YGValue minWidth;
@property (nonatomic, readwrite, assign) YGValue minHeight;
@property (nonatomic, readwrite, assign) YGValue maxWidth;
@property (nonatomic, readwrite, assign) YGValue maxHeight;

// Yoga specific properties, not compatible with flexbox specification
@property (nonatomic, readwrite, assign) CGFloat aspectRatio;

/**
 Get the resolved direction of this node. This won't be YGDirectionInherit
 */
@property (nonatomic, readonly, assign) YGDirection resolvedDirection;

/**
 Returns the size of the view if no constraints were given. This could equivalent to calling [self
 sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
 */
@property (nonatomic, readonly, assign) CGSize intrinsicSize;

/**
 Returns the number of children that are using Flexbox.
 */
@property (nonatomic, readonly, assign) NSUInteger numberOfChildren;

/**
 Return a BOOL indiciating whether or not we this node contains any subviews that are included in
 Yoga's layout.
 */
@property (nonatomic, readonly, assign) BOOL isLeaf;

/**
 判断当前布局节点是否是脏节点（YES：在下次计算布局的时候，该节点会被重新计算）
 */
@property (nonatomic, readonly, assign) BOOL isDirty;

/**
 Mark that a view's layout needs to be recalculated. Only works for leaf views.
 */
- (void)markDirty;

@end

NS_ASSUME_NONNULL_END
