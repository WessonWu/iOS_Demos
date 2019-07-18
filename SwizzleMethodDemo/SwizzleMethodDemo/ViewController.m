//
//  ViewController.m
//  SwizzleMethodDemo
//
//  Created by wuweixin on 2019/7/18.
//  Copyright © 2019 cn.wessonwu. All rights reserved.
//

#import "ViewController.h"
#import "Test.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"ViewController: %@", NSStringFromSelector(_cmd));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"ViewController: %@", NSStringFromSelector(_cmd));
}


- (void)viewDidAppear:(BOOL)animated {
    
}

- (IBAction)doTest:(id)sender {
    [Test doSomething];
}

@end
