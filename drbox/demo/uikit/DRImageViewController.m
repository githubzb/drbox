//
//  DRImageViewController.m
//  drbox
//
//  Created by dr.box on 2020/8/15.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRImageViewController.h"
#import "Drbox.h"
#import "DRImageDrawDemo.h"

@interface DRImageViewController ()

@property (nonatomic, readonly) UIView *contentView;

@end

@implementation DRImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentView dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionColumn;
    }];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"smallGif"
                                                     ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if ([UIImage dr_isAnimatedGIFData:data]) {
        UIImage *img = [UIImage dr_imageWithSmallGIFData:data scale:[UIScreen mainScreen].scale];
        
        UIView *v = [self cellViewWithTitle:@"imageWithSmallGIFData" image:img];
        [self.contentView addSubview:v];
    }
    
    NSString *pdfPath = [[NSBundle mainBundle] pathForResource:@"mypdf" ofType:@"pdf"];
    UIImage *pdfImg = [UIImage dr_imageWithPDF:pdfPath size:CGSizeMake(100, 148)];
    if (pdfImg) {
        UIView *v = [self cellViewWithTitle:@"imageWithPDF:size" image:pdfImg];
        [self.contentView addSubview:v];
    }
    
    UIImage *emoji = [UIImage dr_imageWithEmoji:@"😄" size:50];
    if (emoji) {
        UIView *v = [self cellViewWithTitle:@"imageWithEmoji:size" image:emoji usImgSize:YES];
        [self.contentView addSubview:v];
    }
    
    UIImage *colorImg = [UIImage dr_imageWithColor:[UIColor redColor] size:CGSizeMake(100, 100)];
    if (colorImg) {
        UIView *v = [self cellViewWithTitle:@"imageWithColor:size" image:colorImg usImgSize:YES];
        [self.contentView addSubview:v];
    }
    
    UIImage *drawImg = [UIImage dr_imageWithSize:CGSizeMake(200, 50)
                                       drawBlock:^(CGContextRef  _Nonnull context) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        UIFont *font = [UIFont systemFontOfSize:15];
        [dic setValue:font forKey:NSFontAttributeName];
        [dic setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSString *str = @"这里是绘制上的文字";
        CGSize s = [str dr_sizeForFont:font
                                  size:CGSizeMake(200, 50)
                                  mode:NSLineBreakByTruncatingTail];
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, 200, 50));
        [str drawWithRect:CGRectMake(8, 8, s.width, 50-16)
                           options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:dic
                           context:NULL];
    }];
    
    if (drawImg) {
        UIView *v = [self cellViewWithTitle:@"imageWithSize:drawBlock" image:drawImg usImgSize:YES];
        [self.contentView addSubview:v];
    }
    
    
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:@"img" ofType:@"png"];
    UIImage *img = [UIImage imageWithContentsOfFile:imgPath];
    if (img) {
        UIView *v = [self cellViewWithTitle:@"dr_drawInRect:withContentMode:clipsToBounds:"
                                 addSubView:^(UIView *rootView) {
            DRImageDrawDemo *imgV = [[DRImageDrawDemo alloc] init];
            imgV.img = img;
            imgV.backgroundColor = [UIColor greenColor];
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(280);
                layout.height = DRPointValue(100);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *resizeImg = [UIImage imageWithContentsOfFile:imgPath];
    if (resizeImg) {
        resizeImg = [resizeImg dr_imageByResizeToSize:CGSizeMake(100, 100)];
        UIView *v = [self cellViewWithTitle:@"imageByResizeToSize：" image:resizeImg usImgSize:YES];
        [self.contentView addSubview:v];
    }
    
    UIImage *resizeFitImg = [UIImage imageWithContentsOfFile:imgPath];
    if (resizeFitImg) {
        // 该方法会将整体尺寸压缩，如果不是按照比例，会变形
        resizeFitImg = [resizeFitImg dr_imageByResizeToSize:CGSizeMake(100, 100)
                                          contentMode:UIViewContentModeScaleAspectFit];
        
        UIView *v = [self cellViewWithTitle:@"imageByResizeToSize：contentMode："
                                 addSubView:^(UIView *rootView) {
            UIView *bv = [[UIView alloc] init];
            bv.backgroundColor = [UIColor greenColor];
            [bv dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.height = DRPointValue(resizeFitImg.size.height);
            }];
            [rootView addSubview:bv];
            
            UIImageView *imgV = [[UIImageView alloc] initWithImage:resizeFitImg];
            [bv addSubview:imgV];
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(resizeFitImg.size.width);
                layout.height = DRPointValue(resizeFitImg.size.height);
                layout.alignSelf = YGAlignCenter;
            }];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *cropImg = [UIImage imageWithContentsOfFile:imgPath];
    if (cropImg) {
        // 该方法只会截取当前图片指定矩形区域内的图片,12000已超出图片自身边界，超出部分忽略不计
        cropImg = [cropImg dr_imageByCropToRect:CGRectMake(120, 90, 12000, 120)];
        
        UIView *v = [self cellViewWithTitle:@"imageByCropToRect："
                                 addSubView:^(UIView *rootView) {
            UIView *bv = [[UIView alloc] init];
            bv.backgroundColor = [UIColor greenColor];
            [bv dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.height = DRPointValue(cropImg.size.height);
            }];
            [rootView addSubview:bv];
            
            UIImageView *imgV = [[UIImageView alloc] initWithImage:cropImg];
            [bv addSubview:imgV];
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(cropImg.size.width);
                layout.height = DRPointValue(cropImg.size.height);
                layout.alignSelf = YGAlignCenter;
            }];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *insetBorderImg = [UIImage imageWithContentsOfFile:imgPath];
    if (insetBorderImg) {
        UIEdgeInsets inset = UIEdgeInsetsMake(10, 10, 20, 20);
        insetBorderImg = [insetBorderImg dr_imageByBorderEdge:inset
                                                    withColor:[UIColor greenColor]];
        UIView *v = [self cellViewWithTitle:@"imageByBorderEdge:withColor:"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:insetBorderImg];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(150);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *roundImg1 = [UIImage imageWithContentsOfFile:imgPath];
    if (roundImg1) {
        roundImg1 = [roundImg1 dr_imageByRoundCornerRadius:20];
        UIView *v = [self cellViewWithTitle:@"imageByRoundCornerRadius:"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:roundImg1];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(150);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *roundImg2 = [UIImage imageWithContentsOfFile:imgPath];
    if (roundImg2) {
        roundImg2 = [roundImg2 dr_imageByRoundCornerRadius:20
                                               borderWidth:8
                                               borderColor:[UIColor greenColor]];
        UIView *v = [self cellViewWithTitle:@"imageByRoundCornerRadius:borderWidth:borderColor:"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:roundImg2];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(150);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *roundImg3 = [UIImage imageWithContentsOfFile:imgPath];
    if (roundImg3) {
        roundImg3 = [roundImg3 dr_imageByRoundCornerRadius:20
                                                   corners:UIRectCornerTopLeft | UIRectCornerTopRight
                                               borderWidth:8
                                               borderColor:[UIColor greenColor]
                                            borderLineJoin:kCGLineJoinBevel];
        UIView *v = [self cellViewWithTitle:@"imageByRoundCornerRadius:corners:borderWidth:borderColor:borderLineJoin:"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:roundImg3];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(150);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *rotateImg1 = [UIImage imageWithContentsOfFile:imgPath];
    if (rotateImg1) {
        rotateImg1 = [rotateImg1 dr_imageByRotate:DRDegreesToRadians(45) fitSize:YES];
        UIView *v = [self cellViewWithTitle:@"imageByRotate:fitSize:"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:rotateImg1];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(150);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *rotateImg2 = [UIImage imageWithContentsOfFile:imgPath];
    if (rotateImg2) {
        rotateImg2 = [rotateImg2 dr_imageByRotate:DRDegreesToRadians(-90) fitSize:NO];
        UIView *v = [self cellViewWithTitle:@"imageByRotate:fitSize:"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:rotateImg2];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(150);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *flipImg1 = [UIImage imageWithContentsOfFile:imgPath];
    if (flipImg1) {
        flipImg1 = [flipImg1 dr_imageByFlipVertical];
        UIView *v = [self cellViewWithTitle:@"imageByFlipVertical"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:flipImg1];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(150);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *flipImg2 = [UIImage imageWithContentsOfFile:imgPath];
    if (flipImg2) {
        flipImg2 = [flipImg2 dr_imageByFlipHorizontal];
        UIView *v = [self cellViewWithTitle:@"imageByFlipHorizontal"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:flipImg2];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(150);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *flipImg3 = [UIImage imageWithContentsOfFile:imgPath];
    if (flipImg3) {
        flipImg3 = [flipImg3 dr_imageByRotate180];
        UIView *v = [self cellViewWithTitle:@"imageByRotate180"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:flipImg3];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(150);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    NSString *tintPath = [[NSBundle mainBundle] pathForResource:@"tint" ofType:@"png"];
    UIImage *tintImg = [UIImage imageWithContentsOfFile:tintPath];
    if (tintImg) {
        UIView *v = [self cellViewWithTitle:@"imageByTintColor"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:tintImg];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(66);
                layout.height = DRPointValue(66);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
            
            UIImage *tintImg1 = [tintImg dr_imageByTintColor:[UIColor blueColor]];
            UIImageView *imgV2 = [[UIImageView alloc] initWithImage:tintImg1];
            imgV2.contentMode = UIViewContentModeScaleAspectFit;
            [imgV2 dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(66);
                layout.height = DRPointValue(66);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV2];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *grayImg = [UIImage imageWithContentsOfFile:imgPath];
    if (grayImg) {
        grayImg = [grayImg dr_imageByGrayscale];
        UIView *v = [self cellViewWithTitle:@"imageByGrayscale"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:grayImg];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(150);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    NSString *blurPath = [[NSBundle mainBundle] pathForResource:@"blur" ofType:@"png"];
    UIImage *blurImg1 = [UIImage imageWithContentsOfFile:blurPath];
    if (blurImg1) {
        blurImg1 = [blurImg1 dr_imageByBlurSoft];
        UIView *v = [self cellViewWithTitle:@"imageByBlurSoft"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:blurImg1];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(251);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *blurImg2 = [UIImage imageWithContentsOfFile:blurPath];
    if (blurImg2) {
        blurImg2 = [blurImg2 dr_imageByBlurLight];
        UIView *v = [self cellViewWithTitle:@"imageByBlurLight"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:blurImg2];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(251);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *blurImg3 = [UIImage imageWithContentsOfFile:blurPath];
    if (blurImg3) {
        blurImg3 = [blurImg3 dr_imageByBlurExtraLight];
        UIView *v = [self cellViewWithTitle:@"imageByBlurExtraLight"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:blurImg3];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(251);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *blurImg4 = [UIImage imageWithContentsOfFile:blurPath];
    if (blurImg4) {
        blurImg4 = [blurImg4 dr_imageByBlurDark];
        UIView *v = [self cellViewWithTitle:@"imageByBlurDark"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:blurImg4];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(251);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *blurImg5 = [UIImage imageWithContentsOfFile:blurPath];
    if (blurImg5) {
        blurImg5 = [blurImg5 dr_imageByBlurWithTint:[UIColor whiteColor]];
        UIView *v = [self cellViewWithTitle:@"imageByBlurWithTint"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:blurImg5];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(251);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    NSString *maskPath = [[NSBundle mainBundle] pathForResource:@"mask" ofType:@"png"];
    UIImage *blurImg6 = [UIImage imageWithContentsOfFile:blurPath];
    UIImage *maskImg = [UIImage imageWithContentsOfFile:maskPath];
    if (blurImg6 && maskImg) {
        blurImg6 = [blurImg6 dr_imageByBlurRadius:40
                                        tintColor:DRColorFromRGBA(255, 255, 255, 0.4)
                                         tintMode:kCGBlendModeNormal
                                       saturation:0
                                        maskImage:maskImg];
        UIView *v = [self cellViewWithTitle:@"imageByBlurRadius:tintColor:tintMode:saturation:maskImage:"
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:blurImg6];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(251);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
    
    UIImage *blurB = [UIImage imageWithContentsOfFile:blurPath];
    UIImage *imgUp = [UIImage imageWithContentsOfFile:imgPath];
    if (blurB && imgUp) {
        UIEdgeInsets inset = UIEdgeInsetsMake(50, 50, 150, 50);
        UIImage *img = [[blurB dr_imageByBlurDark] dr_imageByCoverImage:imgUp
                                                             edgeInsets:inset];
        UIView *v = [self cellViewWithTitle:@"imageByCoverImage：edgeInsets："
                                 addSubView:^(UIView *rootView) {
            UIImageView *imgV = [[UIImageView alloc] initWithImage:img];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
            [imgV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
                layout.width = DRPointValue(200);
                layout.height = DRPointValue(251);
                layout.alignSelf = YGAlignCenter;
            }];
            [rootView addSubview:imgV];
        }];
        [self.contentView addSubview:v];
    }
}

- (void)loadView{
    self.view = [[UIScrollView alloc] init];
}

- (UIView *)contentView{
    return ((UIScrollView *)self.view).dr_contentView;
}

- (UIView *)cellViewWithTitle:(NSString *)title image:(UIImage *)img{
    UIView *v = [[UIView alloc] init];
    [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionColumn;
    }];
    UIView *topV = [[UIView alloc] init];
    topV.backgroundColor = [UIColor orangeColor];
    [topV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionRow;
        layout.padding = DRPointValue(8);
    }];
    [v addSubview:topV];
    UILabel *lb = [[UILabel alloc] init];
    lb.textColor = [UIColor whiteColor];
    lb.font = [UIFont systemFontOfSize:14];
    lb.text = title;
    lb.numberOfLines = 0;
    [lb dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
    }];
    [topV addSubview:lb];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    [imgView dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.aspectRatio = 1.5;
    }];
    [v addSubview:imgView];
    return v;
}

- (UIView *)cellViewWithTitle:(NSString *)title image:(UIImage *)img usImgSize:(BOOL)us{
    UIView *v = [[UIView alloc] init];
    [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionColumn;
    }];
    UIView *topV = [[UIView alloc] init];
    topV.backgroundColor = [UIColor orangeColor];
    [topV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionRow;
        layout.padding = DRPointValue(8);
    }];
    [v addSubview:topV];
    UILabel *lb = [[UILabel alloc] init];
    lb.textColor = [UIColor whiteColor];
    lb.font = [UIFont systemFontOfSize:14];
    lb.text = title;
    lb.numberOfLines = 0;
    [lb dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
    }];
    [topV addSubview:lb];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    [imgView dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        if (us) {
            layout.width = DRPointValue(img.size.width);
            layout.height = DRPointValue(img.size.height);
        }else{
            layout.aspectRatio = 1.5;
        }
    }];
    [v addSubview:imgView];
    return v;
}

- (UIView *)cellViewWithTitle:(NSString *)title addSubView:(void(^)(UIView *rootView))addBlock{
    UIView *v = [[UIView alloc] init];
    [v dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionColumn;
    }];
    UIView *topV = [[UIView alloc] init];
    topV.backgroundColor = [UIColor orangeColor];
    [topV dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
        layout.flexDirection = YGFlexDirectionRow;
        layout.padding = DRPointValue(8);
    }];
    [v addSubview:topV];
    UILabel *lb = [[UILabel alloc] init];
    lb.textColor = [UIColor whiteColor];
    lb.font = [UIFont systemFontOfSize:14];
    lb.text = title;
    lb.numberOfLines = 0;
    [lb dr_makeLayoutWithBlock:^(DRLayout * _Nonnull layout) {
    }];
    [topV addSubview:lb];
    
    if (addBlock) {
        addBlock(v);
    }
    return v;
}

@end
