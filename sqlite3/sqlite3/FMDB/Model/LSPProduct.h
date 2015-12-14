//
//  LSPProduct.h
//  sqlite3
//
//  Created by mac on 15-12-1.
//  Copyright (c) 2015年 Lispeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSPProduct : NSObject
/**
 *  商品名称
 */
@property (copy,nonatomic) NSString *name;
/**
 *  商品价格
 */
@property (assign,nonatomic) double price;
@end
