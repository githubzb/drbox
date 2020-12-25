//
//  DRDisplayLinkViewController.m
//  drbox
//
//  Created by DHY on 2020/12/22.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRDisplayLinkViewController.h"
#import "Drbox.h"

@interface DRDisplayLinkViewController ()

@end

@implementation DRDisplayLinkViewController

- (void)dealloc{
    NSLog(@"DRDisplayLinkViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self testScheduled];
    [self testDisplayLink];
}

- (void)testScheduled{
    [CADisplayLink dr_scheduledDisplayLinkWithTarget:self
                                            selector:@selector(scheduledHandle:)];
}
- (void)scheduledHandle:(CADisplayLink *)link{
    NSLog(@"scheduledHandle");
}

- (void)testDisplayLink{
    CADisplayLink *link = [CADisplayLink dr_displayLinkWithTarget:self selector:@selector(displayLinkHandle:)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)displayLinkHandle:(CADisplayLink *)link{
    NSLog(@"displayLinkHandle");
}

@end
