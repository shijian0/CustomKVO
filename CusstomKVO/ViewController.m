//
//  ViewController.m
//  CusstomKVO
//
//  Created by LiYong on 2018/11/12.
//  Copyright © 2018 勇 李. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "NSObject+LYKVO.h"
@interface ViewController ()
@property (nonatomic,strong)Person*person;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.person = [Person new];
    [self.person LY_addObserver:self forKeyPath:@"name" options:LYKeyValueObservingOptionsNew|LYKeyValueObservingOptionsOld context:nil];

    [self.person LY_addObserver:self forKeyPath:@"age" options:LYKeyValueObservingOptionsOld|LYKeyValueObservingOptionsNew context:nil];

    // Do any additional setup after loading the view, typically from a nib.
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"%@:age=%@",NSStringFromClass([self class]),self.person.age);
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.person.age = @"19";

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
