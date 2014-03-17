//
//  ViewController.h
//  PostIt
//
//  Created by Akshat Singhal on 15/03/14.
//  Copyright (c) 2014 info. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIAlertViewDelegate>
- (void)dismissResultView;
@end
