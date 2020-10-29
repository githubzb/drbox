//
//  DRDictionaryParser.m
//  drbox
//
//  Created by dr.box on 2020/7/23.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import "DRDictionaryParser.h"

#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif

#define DRXMLAttributesKey  @"__attributes"
#define DRXMLCommentsKey    @"__comments"
#define DRXMLTextKey        @"__text"
#define DRXMLNodeNameKey    @"__name"
#define DRXMLAttrPrefixKey  @"_"

/// 获取节点中的属性，如果不存在返回nil
inline static NSDictionary<NSString *, NSString *> * attributesAtNode(NSDictionary<NSString *, id> * node){
    if (!node) return nil;
    NSDictionary<NSString *, NSString *> *attributes = node[DRXMLAttributesKey];
    if (attributes) {
        return attributes.count? attributes: nil;
    }
    NSMutableDictionary<NSString *, id> *filteredDict = [NSMutableDictionary dictionaryWithDictionary:node];
    // 删除节点中的其他属性，剩下的就是xml属性值
    [filteredDict removeObjectsForKeys:@[DRXMLCommentsKey, DRXMLTextKey, DRXMLNodeNameKey]];
    for (NSString *key in filteredDict.allKeys) {
        [filteredDict removeObjectForKey:key];
        if ([key hasPrefix:DRXMLAttrPrefixKey]) {
            // 属性名前存在前缀，将前缀去掉
            filteredDict[[key substringFromIndex:DRXMLAttrPrefixKey.length]] = node[key];
        }
    }
    return filteredDict.count? filteredDict: nil;
}
/// 获取节点的子节点
inline static NSDictionary * childNodesAtNode(NSDictionary<NSString *, id> * node){
    if (!node) return nil;
    NSMutableDictionary *filteredDict = [node mutableCopy];
    [filteredDict removeObjectsForKeys:@[DRXMLAttributesKey, DRXMLCommentsKey, DRXMLTextKey, DRXMLNodeNameKey]];
    for (NSString *key in filteredDict.allKeys) {
        if ([key hasPrefix:DRXMLAttrPrefixKey]) {
            [filteredDict removeObjectForKey:key];
        }
    }
    return filteredDict.count? filteredDict: nil;
}

/// 获取节点的注释
inline static NSArray * commentsAtNode(NSDictionary<NSString *, id> * node){
    if (!node) return nil;
    return node[DRXMLCommentsKey];
}

/// 获取节点名称
inline static NSString * nameAtNode(NSDictionary<NSString *, id> * node){
    if (!node) return nil;
    return node[DRXMLNodeNameKey];
}
/// 获取节点内的文本元素
inline static NSString * textAtNode(NSDictionary<NSString *, id> * node){
    if (!node) return nil;
    return node[DRXMLTextKey];
}


@interface DRDictionaryParser ()<NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *root;
@property (nonatomic, strong) NSMutableArray *stack;// 节点栈，因为XMLParser采用的是SAX解析方式，所以这里采用栈来存储节点
@property (nonatomic, strong) NSMutableString *text;

@end
@implementation DRDictionaryParser

- (instancetype)init{
    self = [super init];
    if (self) {
        _collapseTextNodes = YES;
        _stripEmptyNodes = YES;
        _trimWhiteSpace = YES;
        _alwaysUseArrays = NO;
        _preserveComments = NO;
        _wrapRootNode = YES;
        _attributesMode = DRXMLAttributesModeUnprefixed;
        _nodeNameMode = DRXMLNodeNameModeNever;
    }
    return self;
}

+ (NSDictionary<NSString *,id> *)dictionaryWithParser:(NSXMLParser *)parser{
    return [[[DRDictionaryParser alloc] init] dictionaryWithParser:parser];
}

+ (NSDictionary<NSString *,id> *)dictionaryWithData:(NSData *)data{
    return [[[DRDictionaryParser alloc] init] dictionaryWithData:data];
}

+ (NSDictionary<NSString *,id> *)dictionaryWithString:(NSString *)string{
    return [[[DRDictionaryParser alloc] init] dictionaryWithString:string];
}

+ (NSDictionary<NSString *,id> *)dictionaryWithFile:(NSString *)path{
    return [[[DRDictionaryParser alloc] init] dictionaryWithFile:path];
}

- (NSDictionary<NSString *,id> *)dictionaryWithParser:(NSXMLParser *)parser{
    if (!parser) return nil;
    parser.delegate = self;
    [parser parse];
    return [_root copy];
}

- (NSDictionary<NSString *,id> *)dictionaryWithData:(NSData *)data{
    if (!data) return nil;
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    return [self dictionaryWithParser:parser];
}

- (NSDictionary<NSString *,id> *)dictionaryWithString:(NSString *)string{
    if (!string) return nil;
    NSData *xmlData = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self dictionaryWithData:xmlData];
}

- (NSDictionary<NSString *,id> *)dictionaryWithFile:(NSString *)path{
    if (!path) return nil;
    NSData *xmlData = [NSData dataWithContentsOfFile:path];
    return [self dictionaryWithData:xmlData];
}

#pragma mark - private
/// 追加文本
- (void)appendText:(NSString *)text{
    if (_text) {
        [_text appendString:text];
    }else{
        _text = [[NSMutableString alloc] initWithString:text];
    }
}

/// 获取栈顶元素
- (NSMutableDictionary<NSString *, id> *)stackTop{
    if (!_stack) return nil;
    return _stack.lastObject;
}

/// 将节点压入栈
- (void)stackPush:(NSMutableDictionary<NSString *, id> *)node{
    if (_stack) {
        [_stack addObject:node];
    } else {
        _stack = [NSMutableArray arrayWithObject:node];
    }
}

/// 节点出栈
- (NSMutableDictionary<NSString *, id> *)stackPop {
    NSMutableDictionary *dic = [self stackTop];
    [_stack removeLastObject];
    return dic;
}

/// 获取节点名称
- (NSString *)nameForNode:(NSDictionary<NSString *, id> *)node inDictionary:(NSDictionary<NSString *, id> *)dict{
    NSString *nodeName = nameAtNode(node);
    if (nodeName) {
        return nodeName;
    } else {
        for (NSString *name in dict) {
            id object = dict[name];
            if (object == node) {
                return name;
            } else if ([object isKindOfClass:[NSArray class]] && [(NSArray *)object containsObject:node]) {
                return name;
            }
        }
    }
    return nil;
}

- (void)endText{
    if (_trimWhiteSpace) {
        _text = [[_text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
    }
    if (_text.length > 0) {
        NSMutableDictionary *top = [self stackTop];
        id existing = top[DRXMLTextKey];
        if ([existing isKindOfClass:[NSArray class]]) {
            [existing addObject:_text];
        } else if (existing) {
            top[DRXMLTextKey] = [@[existing, _text] mutableCopy];
        } else {
            top[DRXMLTextKey] = _text;
        }
    }
    _text = nil;
}

#pragma mark - NSXMLParserDelegate
/// 解析到开始节点元素<node>
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(nullable NSString *)namespaceURI
 qualifiedName:(nullable NSString *)qName
    attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
    [self endText];
    
    /**
     
     rootOnly {__name : elementName}
     */
    // 创建新的节点
    NSMutableDictionary<NSString *, id> *node = [NSMutableDictionary dictionary];
    switch (_nodeNameMode) {
        case DRXMLNodeNameModeRootOnly: {
            if (!_root) {
                node[DRXMLNodeNameKey] = elementName;
            }
            break;
        }
        case DRXMLNodeNameModeAlways: {
            node[DRXMLNodeNameKey] = elementName;
            break;
        }
        case DRXMLNodeNameModeNever: {
            break;
        }
    }
    
    // xml节点属性
    if (attributeDict.count > 0) {
        switch (_attributesMode) {
            case DRXMLAttributesModePrefixed: {
                for (NSString *key in attributeDict) {
                    /**
                     {__name: elementName, _key: attrVal}
                     */
                    node[[DRXMLAttrPrefixKey stringByAppendingString:key]] = attributeDict[key];
                }
                break;
            }
            case DRXMLAttributesModeDictionary: {
                /**
                 {__name: elementName, __attributes: attributeDict}
                 */
                node[DRXMLAttributesKey] = attributeDict;
                break;
            }
            case DRXMLAttributesModeUnprefixed: {
                /**
                 {__name: elementName, key: attrVal}
                 */
                [node addEntriesFromDictionary:attributeDict];
                break;
            }
            case DRXMLAttributesModeDiscard: {
                break;
            }
        }
    }
    
    if (!_root) {
        // xml中的根节点
        _root = node;
        // 将根节点压入栈
        [self stackPush:node];
        if (_wrapRootNode) {
            _root = [NSMutableDictionary dictionaryWithObject:_root forKey:elementName];
            [_stack insertObject:_root atIndex:0];
        }
    } else {
        // 处理子节点
        NSMutableDictionary<NSString *, id> *top = [self stackTop];
        id existing = top[elementName]; // 当前节点名称是否跟上一个节点相同
        if ([existing isKindOfClass:[NSArray class]]) {
            // 相同，并且已经存在，直接添加
            [(NSMutableArray *)existing addObject:node];
        } else if (existing) {
            // 相同，将当前节点放入数组中
            top[elementName] = [@[existing, node] mutableCopy];
        } else if (_alwaysUseArrays) {
            // 不相同，并且总是存放在数组中
            top[elementName] = [NSMutableArray arrayWithObject:node];
        } else {
            // 不相同
            top[elementName] = node;
        }
        //将当前节点压入栈
        [self stackPush:node];
    }
}

/// 解析到结束节点元素</node>
- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(nullable NSString *)namespaceURI
 qualifiedName:(nullable NSString *)qName{
    [self endText];
    NSMutableDictionary<NSString *, id> *top = [self stackPop];
    if (!attributesAtNode(top) && !childNodesAtNode(top) && !commentsAtNode(top)) {
        NSMutableDictionary<NSString *, id> *newTop = [self stackTop];
        NSString *nodeName = [self nameForNode:top inDictionary:newTop];
        if (nodeName) {
            id parentNode = newTop[nodeName];
            NSString *innerText = textAtNode(top);// 获取当前节点的文本
            if (innerText && _collapseTextNodes) {
                if ([parentNode isKindOfClass:[NSArray class]]) {
                    parentNode[[parentNode count] - 1] = innerText;
                } else {
                    newTop[nodeName] = innerText;
                }
            } else if (!innerText) {
                if (_stripEmptyNodes) {
                    // 删除空文本的节点
                    if ([parentNode isKindOfClass:[NSArray class]]) {
                        [(NSMutableArray *)parentNode removeLastObject];
                    } else {
                        [newTop removeObjectForKey:nodeName];
                    }
                } else if (!_collapseTextNodes) {
                    top[DRXMLTextKey] = @"";
                }
            }
        }
    }
}

/// 解析到节点内容元素<node>内容元素</node>
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [self appendText:string];
}

/// 解析到CDATA元素
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock{
    NSString *text = [[NSString alloc] initWithData:CDATABlock
                                           encoding:NSUTF8StringEncoding];
    [self appendText:text];
}

/// 解析到xml注释
- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment{
    if (_preserveComments){
        NSMutableDictionary<NSString *, id> *top = [self stackTop];
        NSMutableArray<NSString *> *comments = top[DRXMLCommentsKey];
        if (!comments){
            comments = [@[comment] mutableCopy];
            top[DRXMLCommentsKey] = comments;
        }else{
            [comments addObject:comment];
        }
    }
}

@end

#undef DRXMLAttributesKey
#undef DRXMLCommentsKey
#undef DRXMLTextKey
#undef DRXMLNodeNameKey
#undef DRXMLAttrPrefixKey
