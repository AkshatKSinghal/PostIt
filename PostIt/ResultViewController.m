//
//  ResultViewController.m
//  PostIt
//
//  Created by Akshat Singhal on 16/03/14.
//  Copyright (c) 2014 info. All rights reserved.
//

#import "ResultViewController.h"
#import "ViewController.h"

@interface ResultViewController ()
@property NSDictionary *sites;
@property NSMutableDictionary *pending;
@end

@implementation ResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self.view.backgroundColor   =   [UIColor whiteColor];
    [self addDoneButton];
    
    UIActivityIndicatorView *activityIndicator  =   [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    [activityIndicator startAnimating];
    activityIndicator.tag   =   99;
    [self.view addSubview:activityIndicator];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addDoneButton {
    UIButton *button    =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake((self.view.frame.size.width-270)/2, self.view.frame.size.height-100, 270, 40)];
    [button setTitle:@"        DONE        " forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [button setEnabled:NO];
    button.tag  =   100;
    [self.view addSubview:button];
}

- (void)dismiss {
    if ([_delegate respondsToSelector:@selector(dismissResultView)]) {
        [_delegate performSelector:@selector(dismissResultView)];
    }
}


- (void)showResultViewForSites:(NSDictionary *)sites {
    _pending    =   [[NSMutableDictionary alloc] init];
    _sites  =   sites;
    int startingPoint = 0;
    int counter = 0;
    for (id key in _sites) {
        counter ++;
        if ([_sites[key] isEqualToString:@"1"]) {
            if (![key isEqualToString:@"IG"]) {
                UILabel *label  =   [[UILabel alloc] initWithFrame:CGRectMake(30, self.view.frame.size.height/2 +  startingPoint, self.view.frame.size.width, 30)];
                label.text  =   [NSString stringWithFormat:@"%@  Working...",key];
                label.tag   =   counter;
                [self.view addSubview:label];
                startingPoint += 40;
            }
            else{
                UIButton *doneButton    =   (UIButton *)[self.view viewWithTag:100];
                [doneButton setTitle:@"Continue to Post on Instagram" forState:UIControlStateNormal];
            }
            [_pending setObject:@"1" forKey:key];
            
        }
        
    }
    [self changeButtonEnabled:YES];
}

- (void)updateResultForSite:(NSDictionary *)site {
    int counter   =   0;

    NSString *siteName  =   [[site allKeys] lastObject];
    [_pending removeObjectForKey:siteName];
    for (NSString *key in _sites) {
        counter++;
        if ([key isEqualToString:siteName]) {
            UILabel *label  =   (UILabel *)[self.view viewWithTag:counter];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                label.text  =   [NSString stringWithFormat:@"%@    %@",key,site[siteName]];
            }];
        }
    }
    
    [self changeButtonEnabled:YES];
    
}

- (void)changeButtonEnabled:(BOOL)enabled {
    if (_pending.count == 1 && [_pending[@"IG"] isEqualToString:@"1"]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[self.view viewWithTag:99] removeFromSuperview];
            UIButton *doneButton    =   (UIButton *)[self.view viewWithTag:100];
            [doneButton setEnabled:enabled];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    }
    if (_pending.count == 0) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[self.view viewWithTag:99] removeFromSuperview];
            UIButton *doneButton    =   (UIButton *)[self.view viewWithTag:100];
            [doneButton setEnabled:enabled];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
