//
//  NSObject+LYKVO.h
//  CusstomKVO
//
//  Created by LiYong on 2018/11/12.
//  Copyright © 2018 勇 李. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYKVOInfo.h"

@interface NSObject (LYKVO)
- (void)LY_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(LYKeyValueObservingOptions)options context:(nullable void *)context;
- (void)LY_removeObserver:(nonnull NSObject *)object forKeyPath:(nonnull NSString *)keyPath ;

@end
