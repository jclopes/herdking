//
//  AI.m
//  HerdingKing
//
//  Created by joao on 2010/03/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AI.h"


@implementation StateMachine

-(id) init
{
    if (!(self = [super init])) {
        return nil;
    }
    states = [[NSMutableDictionary alloc] init];
    activeState = nil;
    return self;
}

-(void) dealloc
{
    NSLog(@"dealloc StateMachine: %d", [states count]);
    [states removeAllObjects];
    [states release];
    [super dealloc];
}

-(id) addState:(State *)state
{
    [states setObject:state forKey:[state name]];
    NSLog(@"adding state: %@", [state name]);
    return state;
}

-(id) setActiveStateByName:(NSString *)name
{
    activeState = [states objectForKey:name];
    return activeState;
}

-(id) think
{
    NSString *newStateName;
    if (activeState == nil) {
        return nil;
    }
    [activeState doActions];
    newStateName = [activeState checkConditions];
    if (newStateName) {
        [self setActiveStateByName:newStateName];
    }
    return activeState;
}

@end

@implementation State

@synthesize name;

-(id) initWithName:(NSString *)stateName{
    self = [super init];
    if (self) {
        name = stateName;
    }
    return self;
}

@end

@implementation SheepStateSnoozing

-(id) init
{
    self = [super initWithName:@"SheepStateSnoozing"];
    if (self) {
        count = 0;
    }
    return self;
}

-(void) entryActions
{
    const int MAX_COUNT = 50;
    count = MAX_COUNT;
}

-(void) exitActions
{
    ;
}

-(void) doActions
{
    count -= 1;
}

-(NSString *) checkConditions
{
    if (count <= 0) {
        ;
    }
    return name;
}

@end

@implementation SheepStateRunning

-(id) init
{
    self = [super initWithName:@"SheepStateRunning"];
    if (self) {
        count = 0;
    }
    return self;
}

-(void) entryActions
{
    const int MAX_COUNT = 50;
    count = MAX_COUNT;
    //TODO: Run away from bark origin
}

-(void) exitActions
{
    ;
}

-(void) doActions
{
    count -= 1;
}

-(NSString *) checkConditions
{
    if (count <= 0) {
        return @"SheepStateSnoozing";
    }
    return name;
}

@end
