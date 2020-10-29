//
//  DRXMLParserViewController.m
//  drbox
//
//  Created by dr.box on 2020/7/24.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRXMLParserViewController.h"
#import "Drbox.h"

@interface DRXMLParserViewController ()

@end

@implementation DRXMLParserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"testXML" ofType:@"xml"];
    for (int i=1; i<15; i++) {
        NSString *selName = [NSString stringWithFormat:@"test%@:", @(i)];
        SEL sel = NSSelectorFromString(selName);
        if ([self respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:sel withObject:xmlPath];
#pragma clang diagnostic pop
        }
    }
}

// 默认解析xml方式
- (void)test1:(NSString *)path{
    NSDictionary *dic = [DRDictionaryParser dictionaryWithFile:path];
    NSLog(@"默认设置 xml字典：%@", dic);
}

// 保留xml注释内容
- (void)test2:(NSString *)path{
    DRDictionaryParser *parser = [[DRDictionaryParser alloc] init];
    parser.preserveComments = YES;
    NSDictionary *dic = [parser dictionaryWithFile:path];
    NSLog(@"preserveComments=YES xml字典：%@", dic);
}

// xml根节点名称包装根节点
- (void)test3:(NSString *)path {
    DRDictionaryParser *parser = [[DRDictionaryParser alloc] init];
    parser.wrapRootNode = NO;
    NSDictionary *dic = [parser dictionaryWithFile:path];
    NSLog(@"wrapRootNode=NO xml字典：%@", dic);
}

// collapseTextNodes测试
- (void)test4:(NSString *)path {
    DRDictionaryParser *parser = [[DRDictionaryParser alloc] init];
    parser.collapseTextNodes = NO;
    NSDictionary *dic = [parser dictionaryWithFile:path];
    NSLog(@"collapseTextNodes=NO xml字典：%@", dic);
}

// stripEmptyNodes测试
- (void)test5:(NSString *)path {
    DRDictionaryParser *parser = [[DRDictionaryParser alloc] init];
    parser.stripEmptyNodes = NO;
    NSDictionary *dic = [parser dictionaryWithFile:path];
    NSLog(@"stripEmptyNodes=NO xml字典：%@", dic);
}
// trimWhiteSpace测试
- (void)test6:(NSString *)path {
    DRDictionaryParser *parser = [[DRDictionaryParser alloc] init];
    parser.trimWhiteSpace = NO;
    NSDictionary *dic = [parser dictionaryWithFile:path];
    NSLog(@"trimWhiteSpace=NO xml字典：%@", dic);
}
// alwaysUseArrays测试
- (void)test7:(NSString *)path {
    DRDictionaryParser *parser = [[DRDictionaryParser alloc] init];
    parser.alwaysUseArrays = YES;
    NSDictionary *dic = [parser dictionaryWithFile:path];
    NSLog(@"alwaysUseArrays=YES xml字典：%@", dic);
}
// nodeNameMode测试
- (void)test8:(NSString *)path {
    DRDictionaryParser *parser = [[DRDictionaryParser alloc] init];
    parser.nodeNameMode = DRXMLNodeNameModeAlways;
    NSDictionary *dic = [parser dictionaryWithFile:path];
    NSLog(@"nodeNameMode=Always xml字典：%@", dic);
}
// nodeNameMode测试
- (void)test9:(NSString *)path {
    DRDictionaryParser *parser = [[DRDictionaryParser alloc] init];
    parser.nodeNameMode = DRXMLNodeNameModeRootOnly;
    NSDictionary *dic = [parser dictionaryWithFile:path];
    NSLog(@"nodeNameMode=RootOnly xml字典：%@", dic);
}
// attributesMode测试
- (void)test10:(NSString *)path {
    DRDictionaryParser *parser = [[DRDictionaryParser alloc] init];
    parser.attributesMode = DRXMLAttributesModeDiscard;
    NSDictionary *dic = [parser dictionaryWithFile:path];
    NSLog(@"attributesMode=Discard xml字典：%@", dic);
}
// attributesMode测试
- (void)test11:(NSString *)path {
    DRDictionaryParser *parser = [[DRDictionaryParser alloc] init];
    parser.attributesMode = DRXMLAttributesModeDictionary;
    NSDictionary *dic = [parser dictionaryWithFile:path];
    NSLog(@"attributesMode=Dictionary xml字典：%@", dic);
}
// attributesMode测试
- (void)test12:(NSString *)path {
    DRDictionaryParser *parser = [[DRDictionaryParser alloc] init];
    parser.attributesMode = DRXMLAttributesModePrefixed;
    NSDictionary *dic = [parser dictionaryWithFile:path];
    NSLog(@"attributesMode=Prefixed xml字典：%@", dic);
}

@end
