//
//  dr_base64.c
//  drbox
//
//  Created by DHY on 2021/8/4.
//  Copyright © 2021 @zb.drbox. All rights reserved.
//

#include "dr_base64.h"
#include <string.h>


const char * base64_charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789"
"+/";

/// 根据Base64编码后的十进制索引，获取Base64字符对应表中的字符
char _dr_getBase64Char(char c){
    return base64_charset[c]; // 由于base64对应的索引下标是由6位一组计算而来，所以索引最大值为：2^5+2^4+2^3+2^2+2^1+2^0 = 63，因此不会越界
}
/// 根据Base64字符，获取其十进制索引值
char _dr_getCharByBase64(char c){
    switch(c) {
        case 'A':
        case 'B':
        case 'C':
        case 'D':
        case 'E':
        case 'F':
        case 'G':
        case 'H':
        case 'I':
        case 'J':
        case 'K':
        case 'L':
        case 'M':
        case 'N':
        case 'O':
        case 'P':
        case 'Q':
        case 'R':
        case 'S':
        case 'T':
        case 'U':
        case 'V':
        case 'W':
        case 'X':
        case 'Y':
        case 'Z':
            return c-'A';
        case 'a':
        case 'b':
        case 'c':
        case 'd':
        case 'e':
        case 'f':
        case 'g':
        case 'h':
        case 'i':
        case 'j':
        case 'k':
        case 'l':
        case 'm':
        case 'n':
        case 'o':
        case 'p':
        case 'q':
        case 'r':
        case 's':
        case 't':
        case 'u':
        case 'v':
        case 'w':
        case 'x':
        case 'y':
        case 'z':
            return c-'a'+26;
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            return c-'0'+52;
        case '+':
            return 62;
        case '/':
            return 63;
    }
    return -1;
}

size_t dr_base64_length(size_t data_len){
    if (data_len <=0) return 0;
    int i = data_len*8%6; // 是否能被6整除，因为bas64的每个字符是6位一组计算而来。
    if (i == 0) {
        return data_len*8/6;
    }
    return data_len*8/6+1+(i==2?2:1);
}

size_t dr_data_length(const char *base64_data, size_t len){
    if (base64_data == NULL || len == 0) return 0;
    int count = 0;
    while (base64_data[len-1-count] == '=') {
        count++;
    }
    return (len - count)*6/8;
}


int dr_base64_encode(const char *data, size_t len, char *output){
    if (data == NULL || len <= 0 || output == NULL) return -1;
    size_t index = 0;
    while (len - index >= 3) { // 每三个字符为一组，编码出4个Base64的字符
        const char *p1 = data + index;
        const char *p2 = p1 + 1;
        const char *p3 = p2 + 1;
        
        char c1 = (*p1 & 0b11111100)>>2; // 由于&和>>操作符的优先级是一样的，但是它们的执行顺序为从右到左，因此这里使用一对儿小括号让前面先计算
        char c2 = (*p1 & 0b00000011)<<4 | (*p2 & 0b11110000)>>4;
        char c3 = (*p2 & 0b00001111)<<2 | (*p3 & 0b11000000)>>6;
        char c4 = *p3 & 0b00111111;
        
        *(output++) = _dr_getBase64Char(c1);
        *(output++) = _dr_getBase64Char(c2);
        *(output++) = _dr_getBase64Char(c3);
        *(output++) = _dr_getBase64Char(c4);
        
        index += 3;
    }
    
    int last = (int)(len-index);
    if(last==1){
        const char *p1 = data + index;
        char c1 = (*p1 & 0b11111100)>>2;
        char c2 = (*p1 & 0b00000011)<<4;
        
        *(output++) = _dr_getBase64Char(c1);
        *(output++) = _dr_getBase64Char(c2);
        *(output++) = '=';
        *(output++) = '=';
    }else if(last == 2){
        const char *p1 = data + index;
        const char *p2 = p1+1;
        
        char c1 = (*p1 & 0b11111100)>>2;
        char c2 = (*p1 & 0b00000011)<<4 | (*p2 & 0b11110000)>>4;
        char c3 = (*p2 & 0b00001111)<<2;
        
        *(output++) = _dr_getBase64Char(c1);
        *(output++) = _dr_getBase64Char(c2);
        *(output++) = _dr_getBase64Char(c3);
        *(output++) = '=';
    }
    return 0;
}

int dr_base64_decode(const char *data, size_t len, char *output){
    if (data == NULL || len <= 0 || output == NULL) return -1;
    int count = 0;
    while (data[len - 1 - count] == '=') { // 统计后面补充的字符'='个数
        count ++;
    }
    
    size_t realLen = len - count;
    size_t index = 0;
    while (realLen-index >= 4) {
        const char *p1 = data + index;
        const char *p2 = p1 + 1;
        const char *p3 = p2 + 1;
        const char *p4 = p3 + 1;
        
        char c1 = _dr_getCharByBase64(*p1);
        char c2 = _dr_getCharByBase64(*p2);
        char c3 = _dr_getCharByBase64(*p3);
        char c4 = _dr_getCharByBase64(*p4);
        
        *(output++) = c1 << 2 | (((c2 & 0b00110000)) >> 4);
        *(output++) = (c2 & 0b00001111) << 4 | (c3 & 0b00111100) >> 2;
        *(output++) = (c3 & 0b00000011) << 6 | (c4 & 0b00111111);
        
        index += 4;
    }
    int i = (int)(realLen - index);
    if (i == 2) { // AB==
        const char *p1 = data + index;
        const char *p2 = p1 + 1;
        
        char c1 = _dr_getCharByBase64(*p1);
        char c2 = _dr_getCharByBase64(*p2);
        
        *(output++) = c1 << 2 | (c2 & 0b00110000) >> 4;
    }else if (i == 3) { // ABC=
        const char *p1 = data + index;
        const char *p2 = p1 + 1;
        const char *p3 = p2 + 1;
        
        char c1 = _dr_getCharByBase64(*p1);
        char c2 = _dr_getCharByBase64(*p2);
        char c3 = _dr_getCharByBase64(*p3);
        
        *(output++) = c1 << 2 | (c2 & 0b00110000) >> 4;
        *(output++) = (c2 & 0b00001111) << 4 | (c3 & 0b00111100) >> 2;
    }
    return 0;
}
