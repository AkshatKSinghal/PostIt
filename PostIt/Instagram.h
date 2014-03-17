//
//  ViewController.m
//  PostIt
//
//  Created by Akshat Singhal on 16/03/14.
//  Copyright (c) 2014 info. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Instagram : NSObject <UIDocumentInteractionControllerDelegate>

extern NSString* const kInstagramAppURLString;
extern NSString* const kInstagramOnlyPhotoFileName;

+ (void) setPhotoFileName:(NSString*)fileName;
+ (NSString*) photoFileName;


+ (BOOL) isAppInstalled;

+ (BOOL) isImageCorrectSize:(UIImage*)image;

+ (void) postImage:(UIImage*)image inView:(UIView*)view;

+ (void) postImage:(UIImage*)image withCaption:(NSString*)caption inView:(UIView*)view;
+ (void) postImage:(UIImage*)image withCaption:(NSString*)caption inView:(UIView*)view delegate:(id<UIDocumentInteractionControllerDelegate>)delegate;

@end
