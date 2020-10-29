//
//  DRImageDrawDemo.m
//  drbox
//
//  Created by dr.box on 2020/8/16.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRImageDrawDemo.h"
#import "Drbox.h"

@implementation DRImageDrawDemo

- (void)drawRect:(CGRect)rect{
    [self.img dr_drawInRect:rect
            withContentMode:UIViewContentModeScaleAspectFit
              clipsToBounds:YES];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

@end
