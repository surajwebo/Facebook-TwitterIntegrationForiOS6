//
//  ViewController.h
//  SocialIntegrationiOS6
//
//  Created by Suraj Mirajkar on 05/11/12.
//  Copyright (c) 2012 suraj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "FbGraph.h"
#import "SBJSON.h"

@interface SocialViewController : UIViewController <UITextFieldDelegate> {
    FbGraph *fbGraph;
    BOOL bIsFromFacebook;
}
@property (retain, nonatomic) FbGraph *fbGraph;
@property (retain, nonatomic) IBOutlet UITextField *txtFieldUrlForSharing;
@property (retain, nonatomic) IBOutlet UITextField *txtFieldTextForSharing;
@property (nonatomic) BOOL bIsFromFacebook;

- (IBAction)facebookSharing:(id)sender;
- (IBAction)twitterSharing:(id)sender;
- (void)FBGraphResponse;
+(BOOL)isTwitterAvailable;
+(BOOL)isSocialAvailable;
-(void)sharingViaFBandTW;
-(void)alertMessage: (NSString *)title: (NSString *)message;

@end
