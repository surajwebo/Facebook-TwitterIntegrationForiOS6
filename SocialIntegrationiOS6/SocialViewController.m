//
//  ViewController.m
//  SocialIntegrationiOS6
//
//  Created by Suraj Mirajkar on 05/11/12.
//  Copyright (c) 2012 suraj. All rights reserved.
//

#import "SocialViewController.h"
#import "CheckIOSVersion.h"

@interface SocialViewController ()
#define FbClientID @"366509033392814"
#define clearText @""
@end

@implementation SocialViewController
@synthesize fbGraph;
@synthesize txtFieldUrlForSharing;
@synthesize txtFieldTextForSharing;
@synthesize bIsFromFacebook;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)facebookSharing:(id)sender {
    if ([txtFieldUrlForSharing.text length] !=0 && [txtFieldTextForSharing.text length] !=0) {
        if ([SocialViewController isSocialAvailable]) {
            bIsFromFacebook = YES;
            [self sharingViaFBandTW];
        } else {
            //create the instance of graph api
            fbGraph = [[FbGraph alloc]initWithFbClientID:FbClientID];
            //mark some permissions for your access token so that it knows what permissions it has
            [fbGraph authenticateUserWithCallbackObject:self andSelector:@selector(FBGraphResponse) andExtendedPermissions:@"user_photos,user_videos,publish_stream,offline_access,user_checkins,friends_checkins,publish_checkins,email"];
        }
    } else {
        [self alertMessage:@"Error":@"Please insert message and url to be posted"];
    }
}

- (void)FBGraphResponse
{
    @try
    {
        if (fbGraph.accessToken)
        {
            SBJSON *jsonparser = [[SBJSON alloc]init];
            
            FbGraphResponse *fb_graph_response = [fbGraph doGraphGet:@"me" withGetVars:nil];
            
            NSString *resultString = [NSString stringWithString:fb_graph_response.htmlResponse];
            NSDictionary *dict =  [jsonparser objectWithString:resultString];
            NSLog(@"Dict = %@",dict);
            
            NSMutableDictionary *variable = [[NSMutableDictionary alloc]initWithCapacity:1];
            
            [variable setObject:txtFieldUrlForSharing.text forKey:@"link"];
            [fbGraph doGraphPost:@"me/feed" withPostVars:variable];
            
            [self alertMessage:@"Yeah" :@"Posting Successfull"];
        }
    }
    @catch (NSException *exception) {
       [self alertMessage:@"Error" :@"Something went wrong while posting"];
    }
    
    txtFieldUrlForSharing.text = clearText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtFieldTextForSharing) 
        [txtFieldUrlForSharing becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)twitterSharing:(id)sender {
    if ([txtFieldUrlForSharing.text length] !=0 && [txtFieldTextForSharing.text length] !=0) {
       if ([SocialViewController isSocialAvailable]) {
           bIsFromFacebook = NO;
           [self sharingViaFBandTW];
        } else if ([SocialViewController isTwitterAvailable]){
            
            //first identify whether the device has twitter framework or not
            if (NSClassFromString(@"TWTweetComposeViewController")) {
                
                NSLog(@"Twitter framework is available on the device");
                //code goes here
                //create the object of the TWTweetComposeViewController
                TWTweetComposeViewController *twitterComposer = [[TWTweetComposeViewController alloc]init];
                //set the text that you want to post
                [twitterComposer setInitialText:txtFieldTextForSharing.text];
                
                //add Image
                [twitterComposer addImage:[UIImage imageNamed:@"SurajMirajkar.jpg"]];
                
                //add Link
                 [twitterComposer addURL:[NSURL URLWithString:txtFieldUrlForSharing.text]];
                
                //display the twitter composer modal view controller
                if ([CheckIOSVersion isGreaterThanOS6]) 
                    [self presentViewController:twitterComposer animated:YES completion:nil];
                else 
                    [self presentModalViewController:twitterComposer animated:YES];
                
                //check to update the user regarding his tweet
                twitterComposer.completionHandler = ^(TWTweetComposeViewControllerResult result){
                    
                    //if the posting is done successfully
                    if (result == TWTweetComposeViewControllerResultDone){
                        [self alertMessage:@"Yeah" :@"Posting Successfull"];
                    }
                    //if posting is done unsuccessfully
                    else if(result ==TWTweetComposeViewControllerResultCancelled){
                        [self alertMessage:@"Error" :@"Posting failed"];
                    } else {
                        [self alertMessage:@"Error" :@"Something went wrong while posting"];
                    }
                    //dismiss the twitter modal view controller.
                    if ([CheckIOSVersion isGreaterThanOS6])
                        [self dismissViewControllerAnimated:YES completion:nil];
                    else
                        [self dismissModalViewControllerAnimated:YES];
                    
                };
                //releasing the twiter composer object.
                [twitterComposer release];
            }
        }
        else {
            NSLog(@"Twitter framework is not available on the device");
            [self alertMessage:@"Error" :@"Something went wrong while posting"];
        }
    } else {
        [self alertMessage:@"Error":@"Please insert message and url to be posted"];
    }
}

+(BOOL)isTwitterAvailable {
    return NSClassFromString(@"TWTweetComposeViewController") != nil;
}

+(BOOL)isSocialAvailable {
    return NSClassFromString(@"SLComposeViewController") != nil;
}

-(void)sharingViaFBandTW {
    NSString *sLServiceType = NULL;
    if (bIsFromFacebook)
        sLServiceType = SLServiceTypeFacebook;
    else
        sLServiceType = SLServiceTypeTwitter;
    
    //simple check to see if the service of FB is available or not
    if ([SLComposeViewController isAvailableForServiceType:sLServiceType]){
        SLComposeViewController *objvc = [SLComposeViewController composeViewControllerForServiceType:sLServiceType];
        
        //setting the text to post
        [objvc setInitialText:txtFieldTextForSharing.text];
        
        //adding the image to FB post
        [objvc addImage:[UIImage imageNamed:@"SurajMirajkar.jpg"]];
        
        //adding the URL to FB post
        [objvc addURL:[NSURL URLWithString:txtFieldUrlForSharing.text]];
        
        //display the twitter composer modal view controller
        if ([CheckIOSVersion isGreaterThanOS6])
            [self presentViewController:objvc animated:YES completion:nil];
        else
            [self presentModalViewController:objvc animated:YES];
        
        objvc.completionHandler = ^(SLComposeViewControllerResult result)
        {
            if (result == SLComposeViewControllerResultDone) {
                [self alertMessage:@"Yeah" :@"Posting Successfull"];
            }
            else if (result == SLComposeViewControllerResultCancelled) {
                [self alertMessage:@"Error" :@"Posting failed"];
            } else {
                [self alertMessage:@"Error" :@"Something went wrong while posting"];
            }
            
            if ([CheckIOSVersion isGreaterThanOS6])
                [self dismissViewControllerAnimated:YES completion:nil];
            else
                [self dismissModalViewControllerAnimated:YES];
            
        };
    }
}

-(void)alertMessage: (NSString *)title: (NSString *)message {
    UIAlertView *alrtMsg = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alrtMsg show];
    [alrtMsg release];
}

- (void)dealloc {
    [txtFieldUrlForSharing release];
    [txtFieldTextForSharing release];
    [super dealloc];
}
@end
