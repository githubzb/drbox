//
//  dr_base64.h
//  drbox
//
//  Created by dr.box on 2021/8/4.
//  Copyright © 2021 @zb.drbox. All rights reserved.
//

#ifndef dr_base64_h
#define dr_base64_h

#include <stdio.h>

#endif /* dr_base64_h */

/**
 length of data convert to base64 data
 
 @param data_len    length of src data
 */
size_t dr_base64_length(size_t data_len);

/**
 length of base64 data convert to data
 
 @param base64_data     base64 data
 @param len                       length of base64 data
 */
size_t dr_data_length(const char *base64_data, size_t len);

/**
 base64 encode
 
 @param data        src data
 @param len          src data length
 @param output    dest data
 
 @return -1: fail; 0: success
 */
int dr_base64_encode(const char *data, size_t len, char *output);

/**
 base64 encode
 
 @param data        base64 data
 @param len          length of base64 data
 @param output   dest data
 
 @return -1: fail; 0: success
 */
int dr_base64_decode(const char *data, size_t len, char *output);
