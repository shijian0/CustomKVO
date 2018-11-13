//
//  NSObject+LYKVO.m
//  CusstomKVO
//
//  Created by LiYong on 2018/11/12.
//  Copyright © 2018 勇 李. All rights reserved.
//

#import "NSObject+LYKVO.h"
#import <objc/message.h>
#import <objc/runtime.h>
@implementation NSObject (LYKVO)
- (void)LY_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(LYKeyValueObservingOptions)options context:(nullable void *)context{
    //1.创建一个子类
    Class myClass = nil;
    if ([NSStringFromClass([self class]) hasPrefix:@"LYKVO_"]) {
        myClass = [self class];
    }else{
        NSString * newClassName = nil;
        do {
            newClassName = [NSString stringWithFormat:@"LYKVO_%@",NSStringFromClass(self.class)];
            myClass = NSClassFromString(newClassName);
        } while (myClass);//判断是否自定义了该子类；
        
        myClass = objc_allocateClassPair(self.class, newClassName.UTF8String, 0);
        //注册类
        objc_registerClassPair(myClass);
    }
    
    //2.重写setName方法(也就是添加一个方法)
    NSString * methodName = [NSString stringWithFormat:@"set%@:",[keyPath capitalizedString]];

    class_addMethod(myClass, NSSelectorFromString(methodName), (IMP)setMethod, "v@:i");
    
    //3.修改isa指针
    object_setClass(self, myClass);
    
    //4.讲观察者保存到当前对象
    NSMapTable * map = objc_getAssociatedObject(self, @"observerMap");
    if (!map) {
        map = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    LYKVOInfo * info = [[LYKVOInfo alloc]init];
    info.observer = observer;
    info->context = context;
    info.options = options;
    NSMutableArray * observers = [map objectForKey:keyPath];
    if (!observers) {
        observers = [NSMutableArray array];
        [map setObject:observers forKey:keyPath];
    }
    [observers addObject:info];
    
    objc_setAssociatedObject(self, @"observerMap", map, OBJC_ASSOCIATION_RETAIN);
}
void setMethod(id self,SEL _cmd,id newValue){
    NSLog(@"来了");
    //调用父类的setName方法
    Class class=[self class];//拿到当前类型
    object_setClass(self, class_getSuperclass(class));
    objc_msgSend(self,_cmd,newValue);
    
    NSMapTable * map = objc_getAssociatedObject(self, @"observerMap");
    NSString * methodMethod = NSStringFromSelector(_cmd);
    NSString * keyPath = [methodMethod substringWithRange:NSMakeRange(3, methodMethod.length-4)].lowercaseString;
    NSMutableArray * observers = [map objectForKey:keyPath];
    [observers enumerateObjectsUsingBlock:^(LYKVOInfo*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id observer = obj.observer;
        void * context = obj->context;
        LYKeyValueObservingOptions options = obj.options;
        
        if (options & LYKeyValueObservingOptionsPrior) {
            NSDictionary * change = [NSDictionary dictionaryWithObject:@YES forKey:@"notificationIsPrior"];
            ((void(*)(id,SEL,id,id,id,void*))objc_msgSend)(observer, @selector(observeValueForKeyPath:ofObject:change:context:),keyPath,self,change,context);
        }
        
        Ivar ivar = class_getInstanceVariable([self class], [[@"_" stringByAppendingString:keyPath] UTF8String]);
        id old = object_getIvar(self, ivar);
        id new = newValue;
        
        ((void(*)(id,SEL,id))objc_msgSend)(self, _cmd,newValue);
        
        NSMutableDictionary * change = [NSMutableDictionary dictionary];
        
        if (options & LYKeyValueObservingOptionsNew) {
            if (new) {
                [change setObject:new forKey:@"new"];
            }else {
                [change setObject:[NSNull null] forKey:@"new"];
            }
        }
        
        if (options & LYKeyValueObservingOptionsOld) {
            if (old) {
                [change setObject:old forKey:@"old"];
            }else {
                [change setObject:[NSNull null] forKey:@"old"];
            }
        }
        object_setClass(self, class);

        if (options & LYKeyValueObservingOptionsNew || options & LYKeyValueObservingOptionsOld) {
            ((void(*)(id,SEL,id,id,id,void*))objc_msgSend)(observer, @selector(observeValueForKeyPath:ofObject:change:context:),keyPath,self,change,context);
        }
    }];
}
- (void)ip_removeObserver:(nonnull NSObject *)object forKeyPath:(nonnull NSString *)keyPath {
    NSMapTable *mapTable = objc_getAssociatedObject(self, @"observerMap");
    NSMutableArray * observers = [mapTable objectForKey:keyPath];
    [[observers mutableCopy] enumerateObjectsUsingBlock:^(LYKVOInfo *  _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([info.observer isEqual:object]) {
            [observers removeObject:info];
        }
    }];
}
@end
