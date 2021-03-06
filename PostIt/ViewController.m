//
//  ViewController.m
//  PostIt
//
//  Created by Akshat Singhal on 15/03/14.
//  Copyright (c) 2014 info. All rights reserved.
//

#import "ViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "ResultViewController.h"
#import "Instagram.h"


@interface ViewController ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textBox;
@property (weak, nonatomic) IBOutlet UIButton *changeImageButton;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIButton *removeImageButton;
@property (weak) ResultViewController *resultViewController;
@end
NSString *currentText;
BOOL FB;
BOOL TW;
BOOL IG;
UIImage *errorImage;
UIImagePickerController *imagePickerController;
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _accountStore   =   [[ACAccountStore alloc] init];
    errorImage  =   [UIImage imageNamed:@"error.png"];
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    
    FB  =   NO;
    TW  =   NO;
    IG  =   NO;
    [self removeImage:nil];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)postImageToTwitter:(UIImage *)image withStatus:(NSString *)status{
    ACAccountType *twitterType =    [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    SLRequestHandler requestHandler = ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData =    [NSJSONSerialization
                                                     JSONObjectWithData:responseData
                                                     options:NSJSONReadingMutableContainers
                                                     error:NULL];
                NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
                [_resultViewController updateResultForSite:[NSDictionary dictionaryWithObject:@"SUCCESS" forKey:@"TW"]];
            }
            else {
                NSLog(@"[ERROR] Server responded: status code %ld %@", (long)statusCode,
                      [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
                [_resultViewController updateResultForSite:[NSDictionary dictionaryWithObject:@"FAILED" forKey:@"TW"]];
            }
        }
        else {
            NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
            [_resultViewController updateResultForSite:[NSDictionary dictionaryWithObject:@"FAILED" forKey:@"TW"]];
        }
    };
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
    ^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [_accountStore accountsWithAccountType:twitterType];
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
            if (image == nil) {
                url = [NSURL URLWithString:@"https://api.twitter.com"
                       @"/1.1/statuses/update.json"];
            }
            NSDictionary *params = @{@"status" : status};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodPOST
                                                              URL:url
                                                       parameters:params];
            NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
            if (image!=nil) {
                [request addMultipartData:imageData withName:@"media[]"
                                     type:@"image/jpeg" filename:@"image.jpg"];
            }
            [request setAccount:[accounts lastObject]];
            [request performRequestWithHandler:requestHandler];
        }
        else {
            if ([error code] == ACErrorAccountNotFound) {
                NSLog(@"FaceBook Account Not Found");
            }
            else
            {
                NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                      [error localizedDescription]);
            }
        }
    };
    
    [_accountStore requestAccessToAccountsWithType:twitterType
                                           options:NULL
                                        completion:accountStoreHandler];
}

- (void)postImageToFacebook:(UIImage *)image withStatus:(NSString *)status {
    ACAccountType *facebookType =   [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    SLRequestHandler requestHandler = ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData =    [NSJSONSerialization
                                                     JSONObjectWithData:responseData
                                                     options:NSJSONReadingMutableContainers
                                                     error:NULL];
                NSLog(@"[SUCCESS!] Facebook Post with response %@",postResponseData);
                [_resultViewController updateResultForSite:[NSDictionary dictionaryWithObject:@"SUCCESS" forKey:@"FB"]];
            }
            else {
                NSLog(@"[ERROR] Server responded: status code %ld %@", (long)statusCode,
                      [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
                [_resultViewController updateResultForSite:[NSDictionary dictionaryWithObject:@"FAILED" forKey:@"FB"]];
            }
        }
        else {
            NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
            [_resultViewController updateResultForSite:[NSDictionary dictionaryWithObject:@"FAILED" forKey:@"FB"]];
        }
    };
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
    ^(BOOL granted, NSError *error) {
        if (granted) {
            ACAccount* facebookAccount = [[_accountStore accountsWithAccountType:facebookType] lastObject];
            NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me/photos"];
            NSDictionary *params = @{@"access_token":facebookAccount.credential.oauthToken,
                                     @"message" : status,@"picture" : @"image"};
            if (image == nil) {
                url = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
                params = @{@"access_token":facebookAccount.credential.oauthToken,
                                         @"message" : status};
                
            }
            
            
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodPOST
                                                              URL:url
                                                       parameters:params];
            if (image != nil) {
                NSData *imageData = UIImagePNGRepresentation(image);
                [request addMultipartData:imageData
                                 withName:@"source"
                                     type:@"multipart/form-data"
                                 filename:@"image"];
            }
            
            [request performRequestWithHandler:requestHandler];
        }
        else {
            if ([error code] == ACErrorAccountNotFound) {
                NSLog(@"Account Not Found");
            }
            else
            {
                NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                      [error localizedDescription]);
            }
            UIImageView *imageView  =   (UIImageView *)[self.view viewWithTag:201];
            imageView.highlightedImage =   errorImage;
        }
    };
    
    NSDictionary *options = @{
                              @"ACFacebookAppIdKey" : @"232220103650346",
                              @"ACFacebookPermissionsKey" : @[@"publish_actions"],
                              @"ACFacebookAudienceKey" : ACFacebookAudienceEveryone};
    
    [_accountStore requestAccessToAccountsWithType:facebookType
                                           options:options
                                        completion:accountStoreHandler];
}

- (void)postToInstagram {
    [Instagram postImage:_imageView.image withCaption:_textBox.text inView:self.view];
}


- (void)authorizeTwitterWithAlert:(UIAlertView *)alertBox {
    ACAccountType *twitterType =    [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
    ^(BOOL granted, NSError *error) {
        if (!granted) {
            TW  =   NO;
            [alertBox dismissWithClickedButtonIndex:0 animated:NO];
            [self showErrorForSiteWithTag:103];
        }
        else {
            [alertBox dismissWithClickedButtonIndex:0 animated:NO];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[[UIAlertView alloc]initWithTitle:@"Success" message:@"Success Accessing Account" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            }];
            [self removeErrorForSiteWithTag:103];
        }
    };
    [_accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:accountStoreHandler];
}

- (void)authorizeFacebookWithAlert:(UIAlertView *)alertBox {
    ACAccountType *facebookType =    [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
    ^(BOOL granted, NSError *error) {
        if (!granted) {
            FB  =   NO;
            [alertBox dismissWithClickedButtonIndex:0 animated:NO];
            [self showErrorForSiteWithTag:101];
        }
        else {
            [alertBox dismissWithClickedButtonIndex:0 animated:NO];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[[UIAlertView alloc]initWithTitle:@"Success" message:@"Success Accessing Account" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            }];
            [self removeErrorForSiteWithTag:101];
        }
    };
    NSDictionary *options = @{
                              @"ACFacebookAppIdKey" : @"232220103650346",
                              @"ACFacebookPermissionsKey" : @[@"email"  ],
                              @"ACFacebookAudienceKey" : ACFacebookAudienceEveryone};
    
    [_accountStore requestAccessToAccountsWithType:facebookType options:options
                                        completion:accountStoreHandler];
}

- (void)showErrorForSiteWithTag:(int)tag {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[[UIAlertView alloc]initWithTitle:@"Error" message:@"Error Accessing Account" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        UIImageView *errorImageView =   [[UIImageView alloc] initWithImage:errorImage];
        errorImageView.frame    =   [(UIImageView *)[self.view viewWithTag:tag+100] frame];
        errorImageView.tag  =   200 + tag;
        [self.view   addSubview:errorImageView];
        [(UIImageView *)[self.view viewWithTag:tag+100] setAlpha:0];
        [self removeSubViewWithTag:99];
    }];
}

- (void)removeSubViewWithTag:(int)tag {
    [[self.view viewWithTag:tag] removeFromSuperview];
}
- (void)removeErrorForSiteWithTag:(int)tag {
    [(UIImageView *)[self.view viewWithTag:tag+100] setAlpha:1];
    [self removeSubViewWithTag:tag+200];
    [self removeSubViewWithTag:99];
}

- (IBAction)postIt:(id)sender {
    if (IG && _imageView.image == nil) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Select Image for Instagram" delegate:self cancelButtonTitle:@"Skip Instagram" otherButtonTitles:@"Select Image", nil] show];
        return;
    }
    if ((int)FB + (int)TW + (int)IG == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Select Atleast One Account" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        return;
    }
    
    if (TW && _textBox.text.length > 140) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tweet Limit 140 Characters" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Truncate n Tweet", nil] show];
        TW = NO;
        return;
    }
    if (FB) {
        //        NSLog(@"FB");
        [self postImageToFacebook:_imageView.image withStatus:_textBox.text];
    }
    if (TW) {
        //        NSLog(@"TW");
        [self postImageToTwitter:_imageView.image withStatus:_textBox.text];
    }
    if (IG && !FB && !TW) {
        [self postToInstagram];
    }
    else {
        ResultViewController *resultViewController  =   [[ResultViewController alloc]init];
        resultViewController.delegate   =   self;
        _resultViewController   =   resultViewController;
        [self presentViewController:resultViewController animated:YES completion:^{
            [resultViewController showResultViewForSites:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%hhd",FB],@"FB",[NSString stringWithFormat:@"%hhd",TW],@"TW",[NSString stringWithFormat:@"%hhd",IG],@"IG",nil]];
        }];
    }
    
}



- (IBAction)showImagePicker
{
    if (imagePickerController == nil) {
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = self;
    }
    [self presentViewController:imagePickerController animated:YES completion:nil];
    //    self.imagePickerController = imagePickerController;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
    }];
}

- (IBAction)addRemoveSites:(id)sender {
    UIButton *button    =   (UIButton *)sender;
    UIImageView *imageView  =   (UIImageView *)[self.view viewWithTag:button.tag+100];
    imageView.highlighted   =   !imageView.highlighted;
    if (imageView.highlighted) {
        UIActivityIndicatorView *loader =   [[UIActivityIndicatorView alloc] initWithFrame:self.view.frame];
        loader.tag  =   99;
        [loader setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:loader];
        [loader startAnimating];
    }
    switch (button.tag) {
        case 101:
            FB  =   imageView.highlighted;
            if (imageView.highlighted) {
                UIAlertView *alertBox = [[UIAlertView alloc] initWithTitle:@"Authorizing" message:@"Please Wait" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertBox show];
                [self authorizeFacebookWithAlert:alertBox];
            }
            else
                [self removeErrorForSiteWithTag:101];
            break;
        case 102:
            if (imageView.highlighted) {
                if ([Instagram isAppInstalled]) {
                    [self removeSubViewWithTag:99];
                    IG  =   imageView.highlighted;
                }
                else {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Instagram Not Installed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Install App", nil] show];
                    imageView.highlighted   =   !imageView.highlighted;
                }
            }
            
            
            break;
        case 103:
            if (imageView.highlighted) {
                if (_textBox.text.length > 140) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tweet Limit 140" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Truncate Text", nil] show];
                }
                else {
                    TW  =   YES;
                    UIAlertView *alertBox = [[UIAlertView alloc] initWithTitle:@"Authorizing" message:@"Please Wait" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertBox show];
                    [self authorizeTwitterWithAlert:alertBox];
                }
                    
            }
            else
                [self removeErrorForSiteWithTag:103];
            break;
        default:
            break;
    }
}



#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    imagePickerController   =   nil;
    _imageView.image= [info valueForKey:UIImagePickerControllerOriginalImage];
    _changeImageButton.alpha    =   1;
    _removeImageButton.alpha    =   1;
    _addImageButton.alpha   =   0;
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)removeImage:(id)sender {
    _imageView.image    =   nil;
    _changeImageButton.alpha    =   0;
    _removeImageButton.alpha    =   0;
    _addImageButton.alpha       =   1;
}


- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length > 140 && TW) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Tweet Limit 140 Characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Truncate", nil] show];
        return;
    }
    if ([textView.text isEqualToString:@""])
        [[self.view viewWithTag:1] setAlpha:1];
    else
        [[self.view viewWithTag:1] setAlpha:0];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    currentText =   _textBox.text;
    [self addEditButtons];
}

- (void)editCancelled {
    _textBox.text   =   currentText;
    if ([_textBox.text isEqualToString:@""])
        [[self.view viewWithTag:1] setAlpha:1];
    else
        [[self.view viewWithTag:1] setAlpha:0];
    [self editDone];
}

- (void)editDone {
    [_textBox resignFirstResponder];
    [self removeEditButtons];
}

- (void)addEditButtons {
    self.navigationItem.rightBarButtonItem  =   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editDone)];
    self.navigationItem.leftBarButtonItem  =   [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(editCancelled)];
    
}

- (void)removeEditButtons {
    self.navigationItem.rightBarButtonItem  =   nil;
    self.navigationItem.leftBarButtonItem   =   nil;
}

- (void)dismissResultView {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (IG) {
        [self performSelector:@selector(postToInstagram) withObject:nil afterDelay:1];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Skip Instagram"]) {
            IG = NO;
            UIButton *IGButton  =   (UIButton *)[self.view viewWithTag:102];
            [self addRemoveSites:IGButton];
            [self postIt:nil];
        }
        else
            return;
    }
    else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Truncate"] )
        _textBox.text   =   [_textBox.text substringToIndex:140];
    else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Truncate n Tweet"])
        [self postImageToTwitter:_imageView.image withStatus:[_textBox.text substringToIndex:140]];
    else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Truncate Text"])
    {
        _textBox.text   =   [_textBox.text substringToIndex:140];
        TW  =   YES;
        UIAlertView *alertBox = [[UIAlertView alloc] initWithTitle:@"Authorizing" message:@"Please Wait" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertBox show];
        [self authorizeTwitterWithAlert:alertBox];
    }
    else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Install App"]) {
        [self removeSubViewWithTag:99];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/in/app/instagram/id389801252?mt=8ign-msr=https%3A%2F%2Fwww.google.co.in%2F"]];
    }
    else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Select Image"])
        [self showImagePicker];
}

@end
