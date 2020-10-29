//
//  DrboxCommonMacro.h
//  drbox
//
//  Created by dr.box on 2020/7/16.
//  Copyright © 2020 @zb.drbox. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DrboxCommonMacro_h
#define DrboxCommonMacro_h

// 参考：https://blog.csdn.net/u012234115/article/details/43272441
#ifdef __cplusplus // __cplusplus是cpp中的自定义宏
#define DR_EXTERN_C_BEGIN  extern "C" { // extern "C"为了兼容c语言
#define DR_EXTERN_C_END  }
#else
#define DR_EXTERN_C_BEGIN
#define DR_EXTERN_C_END
#endif

// 用于添加@语法糖
#if DEBUG
#define dr_keywordify   autoreleasepool {}
#else
#define dr_keywordify   try {} @catch (...) {}
#endif

// 拼接两个变量
#define drmacro_concat(A, B) \
        drmacro_concat_(A, B)
#define drmacro_concat_(A, B) A ## B

#endif /* DrboxCommonMacro_h */
