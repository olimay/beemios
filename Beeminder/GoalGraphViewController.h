//
//  GoalGraphViewController.h
//  Beeminder
//
//  Created by Andy Brett on 6/28/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoalGraphViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *graphImageView;
@property (strong, nonatomic) NSString *graphURL;

@end