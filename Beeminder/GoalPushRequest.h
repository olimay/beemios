//
//  GoalPushRequest.h
//  Beeminder
//
//  Created by Andy Brett on 6/30/12.
//  Copyright (c) 2012 Andy Brett. All rights reserved.
//

#import "Goal+Resource.h"

@interface GoalPushRequest : NSObject

typedef void(^CompletionBlock)();

+ (GoalPushRequest *)requestForGoal:(Goal *)goal;

+ (GoalPushRequest *)requestForGoal:(Goal *)goal withSuccessBlock:(CompletionBlock)successBlock;

+ (GoalPushRequest *)roadDialRequestForGoal:(Goal *)goal withSuccessBlock:(CompletionBlock)successBlock;

+ (GoalPushRequest *)requestForGoal:(Goal *)goal roadDial:(BOOL)roadDial withSuccessBlock:(CompletionBlock)successBlock withErrorBlock:(CompletionBlock)errorBlock;

@end
