//
//  BeeminderAppDelegate.m
//  Beeminder
//
//  Created by Andy Brett on 6/17/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "BeeminderAppDelegate.h"
#import <CoreData/CoreData.h>
#import "CoreData+MagicalRecord.h"
#import "NSString+Base64.h"

@implementation BeeminderAppDelegate

NSString *const FBSessionStateChangedNotification =
@"com.beeminder.beeminder:FBSessionStateChangedNotification";

+ (UIButton *)standardGrayButtonWith:(UIButton *)button
{
    button.backgroundColor = [BeeminderAppDelegate grayButtonColor];
    [button.layer setBorderWidth:1.0f];
    [button.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    button.layer.cornerRadius = 5.0f;

    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    return button;
}

+ (UIColor *)grayButtonColor
{
    return [UIColor colorWithRed:184.0f/255.0 green:184.0f/255.0 blue:184.0f/255.0 alpha:1.0];
}

- (Goal *)sessionGoal
{
    if (!_sessionGoal) {
        self.sessionGoal = [Goal MR_createEntity];
    }
    return _sessionGoal;
}

+ (Goal *)sharedSessionGoal
{
    BeeminderAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    return delegate.sessionGoal;
}

+ (void)clearSessionGoal
{
    BeeminderAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.sessionGoal = nil;
}

+ (NSString *)slugFromTitle:(NSString *)title
{
    NSRegularExpression *whitespaceRegex = [NSRegularExpression regularExpressionWithPattern:@"[\\s]" options:0 error:nil];
    
    NSString *noSpaces = [whitespaceRegex stringByReplacingMatchesInString:title options:0 range:NSMakeRange(0, title.length) withTemplate:@"-"];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9\\-\\_]" options:0 error:nil];
    
    NSString *slug = [regex stringByReplacingMatchesInString:noSpaces options:0 range:NSMakeRange(0, noSpaces.length) withTemplate:@""];
    
    return slug;
}

+ (NSDictionary *)goalTypesInfo
{
    NSDictionary *fatLoser = [NSDictionary dictionaryWithObjectsAndKeys:kFatloserPrivate, kPrivateNameKey, kFatloserPublic, kPublicNameKey, kFatloserDetails, kDetailsKey, kFatloserInstructions, kInstructionsKey, [NSNumber numberWithInt:3], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    NSDictionary *hustler = [NSDictionary dictionaryWithObjectsAndKeys:kHustlerPrivate, kPrivateNameKey, kHustlerPublic, kPublicNameKey, kHustlerDetails, kDetailsKey, kHustlerInstructions, kInstructionsKey, [NSNumber numberWithInt:1], kSortPriorityKey, [NSNumber numberWithBool:YES], kKyoomKey, nil];
    
    NSDictionary *biker = [NSDictionary dictionaryWithObjectsAndKeys:kBikerPrivate, kPrivateNameKey, kBikerPublic, kPublicNameKey, kBikerDetails, kDetailsKey, kBikerInstructions, kInstructionsKey, [NSNumber numberWithInt:2], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    NSDictionary *inboxer = [NSDictionary dictionaryWithObjectsAndKeys:kInboxerPrivate, kPrivateNameKey, kInboxerPublic, kPublicNameKey, kInboxerDetails, kDetailsKey, kBikerInstructions, kInstructionsKey, [NSNumber numberWithInt:4], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    NSDictionary *custom = [NSDictionary dictionaryWithObjectsAndKeys:kCustomPrivate, kPrivateNameKey, kCustomPublic, kPublicNameKey, kCustomDetails, kDetailsKey, kCustomInstructions, kInstructionsKey, [NSNumber numberWithInt:6], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    NSDictionary *drinker = [NSDictionary dictionaryWithObjectsAndKeys:kDrinkerPrivate, kPrivateNameKey, kDrinkerPublic, kPublicNameKey, kDrinkerDetails, kDetailsKey, kDrinkerInstructions, kInstructionsKey, [NSNumber numberWithInt:5], kSortPriorityKey, [NSNumber numberWithBool:YES], kKyoomKey, nil];
    
    NSDictionary *fitbit = [NSDictionary dictionaryWithObjectsAndKeys:kFitbitPrivate, kPrivateNameKey, kFitbitPublic, kPublicNameKey, kFitbitDetails, kDetailsKey, kFitbitInstructions, kInstructionsKey, [NSNumber numberWithInt:6], kSortPriorityKey, [NSNumber numberWithBool:NO], kKyoomKey, nil];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:fatLoser, kFatloserPrivate, hustler, kHustlerPrivate, biker, kBikerPrivate, inboxer, kInboxerPrivate, drinker, kDrinkerPrivate, fitbit, kFitbitPrivate, custom, kCustomPrivate, nil];
}

// Begin Twitter Auth code
+ (AFHTTPRequestOperation *)reverseAuthTokenOperationForTwitterAccount:(ACAccount *)twitterAccount
{
    NSString *timestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];

    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSUInteger length = 32;
    NSMutableString *nonce = [NSMutableString stringWithCapacity: length];

    for (int i=0; i<length; i++) {
        [nonce appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }

    NSDictionary *baseParams = [NSDictionary dictionaryWithObjectsAndKeys: kTwitterConsumerKey, @"oauth_consumer_key", nonce, @"oauth_nonce", @"HMAC-SHA1", @"oauth_signature_method", timestamp, @"oauth_timestamp", @"1.0", @"oauth_version", @"reverse_auth", @"x_auth_mode", nil];

    NSString *paramString = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_version=%@&x_auth_mode=reverse_auth", [baseParams objectForKey:@"oauth_consumer_key"], [baseParams objectForKey:@"oauth_nonce"], [baseParams objectForKey:@"oauth_signature_method"], [baseParams objectForKey:@"oauth_timestamp"], [baseParams objectForKey:@"oauth_version"]];

    NSString *signatureBaseString = [NSString stringWithFormat:@"POST&https%%3A%%2F%%2Fapi.twitter.com%%2Foauth%%2Frequest_token&%@", AFURLEncodedStringFromStringWithEncoding(paramString, NSUTF8StringEncoding)];
    NSString *signingKey = [NSString stringWithFormat:@"%@&", kTwitterConsumerSecret];

    const char *cKey  = [signingKey cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [signatureBaseString cStringUsingEncoding:NSASCIIStringEncoding];

    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];

    NSString *signature = [NSString base64StringFromData:HMAC length:HMAC.length];

    NSString *headerString = [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature=\"%@\", oauth_signature_method=\"%@\", oauth_timestamp=\"%@\", oauth_version=\"%@\"", [baseParams objectForKey:@"oauth_consumer_key"], [baseParams objectForKey:@"oauth_nonce"], AFURLEncodedStringFromStringWithEncoding(signature, NSUTF8StringEncoding), [baseParams objectForKey:@"oauth_signature_method"], [baseParams objectForKey:@"oauth_timestamp"], [baseParams objectForKey:@"oauth_version"], nil];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"]];
    [request setHTTPBody:[@"x_auth_mode=reverse_auth" dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:headerString, @"Authorization", nil]];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    return operation;
}

+ (void)requestAccessToTwitterFromView:(UIView *)view withDelegate:(id<UIActionSheetDelegate, TwitterAuthDelegate>)delegate
{
    // Create an account store object.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
            delegate.twitterAccounts = twitterAccounts;
            if ([twitterAccounts count] == 1) {
                ACAccount *twitterAccount = [twitterAccounts objectAtIndex:0];
                delegate.selectedTwitterAccount = twitterAccount;
                [delegate getReverseAuthTokensForTwitterAccount:twitterAccount];
            }
            else if ([twitterAccounts count] > 1) {
                // ask the user which one they want to use
                UIActionSheet *sheet;
                switch ([twitterAccounts count]) {
                    case 2:
                        sheet = [[UIActionSheet alloc] initWithTitle:@"Choose Twitter Account" delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[[twitterAccounts objectAtIndex:0] username], [[twitterAccounts objectAtIndex:1] username], nil];
                        break;
                    case 3:
                        sheet = [[UIActionSheet alloc] initWithTitle:@"Choose Twitter Account" delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[[twitterAccounts objectAtIndex:0] username], [[twitterAccounts objectAtIndex:1] username], [[twitterAccounts objectAtIndex:2] username], nil];
                        break;
                        
                    case 4:
                        sheet = [[UIActionSheet alloc] initWithTitle:@"Choose Twitter Account" delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[[twitterAccounts objectAtIndex:0] username], [[twitterAccounts objectAtIndex:1] username], [[twitterAccounts objectAtIndex:2] username], [[twitterAccounts objectAtIndex:3] username], nil];
                        break;
                        
                    default:
                        sheet = [[UIActionSheet alloc] initWithTitle:@"Choose Twitter Account" delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[[twitterAccounts objectAtIndex:0] username], [[twitterAccounts objectAtIndex:1] username], [[twitterAccounts objectAtIndex:2] username], [[twitterAccounts objectAtIndex:3] username], [[twitterAccounts objectAtIndex:4] username], nil];
                        break;
                }
                // show the sheet on the main thread
                int64_t delayInSeconds = 0.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [sheet showInView:view];
                });
                
            }
            else {
                // no accounts found
            }
        }
        else {
            NSLog(@"not granted");
        }
    }];
}

/* Begin Facebook SDK code
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateChangedNotification object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"email", nil];
    return [FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:allowLoginUI completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
            [self sessionStateChanged:session state:state error:error];
        }];
}

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [MagicalRecord setupCoreDataStack];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // We need to properly handle activation of the application with regards to SSO
    // (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBSession.activeSession handleDidBecomeActive];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];    
    [MagicalRecord cleanUp];
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
