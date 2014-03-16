//
//  ResultViewController.h
//  PostIt
//
//  Created by Akshat Singhal on 16/03/14.
//  Copyright (c) 2014 info. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultViewController : UIViewController
@property (weak) id delegate;
- (void)showResultViewForSites:(NSDictionary *)sites;
- (void)updateResultForSite:(NSDictionary *)site;
@end
