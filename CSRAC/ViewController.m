//
//  ViewController.m
//  RAC
//
//  Created by IMAC on 16/1/21.
//  Copyright © 2016年 ysc. All rights reserved.
//

#import "ViewController.h"
@import ReactiveCocoa;
#import "Person.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *passWordText;
@property (nonatomic, strong) Person *person;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;


@property (nonatomic) RACDelegateProxy *proxy;

@end

@implementation ViewController

- (Person *)person {

    if (!_person) {
        _person = [[Person alloc] init];
    }
    return _person;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self demoKvo];
    [self demoTextField];
    [self textFileCombination];
    [self buttonDemo];
    [self delegateDemo];
    [self notificationDemo];
}




- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.person.name = [NSString stringWithFormat:@"zhang %d",arc4random_uniform(100)];
}


#pragma -mark 通知
/**
 * 验证此函数：点击textFile时，系统键盘会发送通知，打印出通知的内容
 */
- (void)notificationDemo {
    
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil]
        subscribeNext:^(id x) {
            NSLog(@"notificationDemo : %@", x);
        }
     ];
}

#pragma -mark 代理方法
/**
 * 5、验证此函：nameText的输入字符时，输入回撤或者点击键盘的回车键使passWordText变为第一响应者（即输入光标移动到passWordText处）
 */
- (void)delegateDemo {
    
    @weakify(self)
    // 1. 定义代理
    self.proxy = [[RACDelegateProxy alloc] initWithProtocol:@protocol(UITextFieldDelegate)];
    // 2. 代理去注册文本框的监听方法
    [[self.proxy rac_signalForSelector:@selector(textFieldShouldReturn:)]
     subscribeNext:^(id x) {
         @strongify(self)
         if (self.nameText.hasText) {
             [self.passWordText becomeFirstResponder];
         }
     }];
    self.nameText.delegate = (id<UITextFieldDelegate>)self.proxy;
}


#pragma -mark 按钮监听
/**
 * 4、验证此函数：当loginButton可以点击时，点击button输出person的属性，实现监控的效果
 */
- (void)buttonDemo {
    @weakify(self);
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside]
       subscribeNext:^(id x) {
           @strongify(self);
           NSLog(@"person.name:  %@    person.password:  %@",self.person.name,self.person.password);
       }
     ];
}



#pragma -mark 文本信号组合

/**
 * 3、为了验证此函数，增加了一个passwordText和一个Button，监测nameText和passwordText
 * 根据状态是否enabled
 */
- (void)textFileCombination {

    id signals = @[[self.nameText rac_textSignal],[self.passWordText rac_textSignal]];
    
    @weakify(self);
    [[RACSignal
      combineLatest:signals]
      subscribeNext:^(RACTuple *x) {
          
          @strongify(self);
          NSString *name = [x first];
          NSString *password = [x second];
          
          if (name.length > 0 && password.length > 0) {
              
              self.loginButton.enabled = YES;
              self.person.name = name;
              self.person.password = password;
              
          } else  {
              self.loginButton.enabled = NO;
              
          }
      }];

}


#pragma -mark 文本框输入事件监听
/**
 * 2、为了测试此函数，增加了一个nameText；监听文本框的输入内容，并设置为self.person.name
 */
- (void)demoTextField {
    
    @weakify(self);
    [[self.nameText rac_textSignal]
     subscribeNext:^(id x) {
         @strongify(self);
         NSLog(@"%@",x);
         self.person.name = x;
     }];
}


/**
 * 1、为了测试此函数，增加了一个Person类 && 一个Label；点击屏幕则会等改Lable的值
 */
#pragma -mark KVO 监听
- (void)demoKvo {

    @weakify(self)
    [RACObserve(self.person, name)
        subscribeNext:^(id x) {
             @strongify(self)
            self.nameLabel.text = x;
        }];
}


- (void)dealloc {
    NSLog(@"如果我出现了，说明没有循环引用，否则请检查 @weakify(self) @strongify(self) 组合 %s",__FUNCTION__);
}
@end
