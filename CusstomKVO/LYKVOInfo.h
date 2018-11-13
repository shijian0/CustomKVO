//
//  LYKVOInfo.h
//  CusstomKVO
//
//  Created by LiYong on 2018/11/12.
//  Copyright © 2018 勇 李. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, LYKeyValueObservingOptions) {
    LYKeyValueObservingOptionsNew = 0x01,
    LYKeyValueObservingOptionsOld = 0x02,
    LYKeyValueObservingOptionsInitial = 0x04,
    LYKeyValueObservingOptionsPrior = 0x08,
};

@interface LYKVOInfo : NSObject{
    @public void * context;
}
@property (nonatomic,weak)id observer;
@property (nonatomic,assign)LYKeyValueObservingOptions options;

@end
