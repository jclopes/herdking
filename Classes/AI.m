//
//  AI.m
//  HerdKing
//
//  Created by joao on 2010/03/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//import the world
#import "WorldScene.h"

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

-(void) addState:(State *)state
{
    [states setObject:state forKey:[state name]];
    NSLog(@"adding state: %@", [state name]);
}

-(void) setActiveStateByName:(NSString *)name
{
    State *newState = [states objectForKey:name];
    if (newState) {
        [activeState exitActions];
        activeState = newState;
        [activeState entryActions];
    }
}

-(void) think
{
    NSString *newStateName;
    if (activeState != nil) {
        [activeState doActions];
        newStateName = [activeState checkConditions];
        if (newStateName) {
            [self setActiveStateByName:newStateName];
        }
    }
}

@end


@implementation State

@synthesize name;

-(id) initWithName:(NSString *)stateName owner:(id)object {
    self = [super init];
    if (self) {
        name = stateName;
        owner = object;
    }
    return self;
}

@end


@implementation SheepStateSnoozing

-(id) initWithOwner:(id)ownerPtr
{
    self = [super initWithName:@"SheepStateSnoozing" owner:ownerPtr];
    if (self) {
        MAX_COUNT = 50;
        count = MAX_COUNT;
        owner = ownerPtr;
    }
    return self;
}

-(void) entryActions
{
    NSLog(@"SNOOZING STATE");
    count = MAX_COUNT;
}

-(void) exitActions
{
}

-(void) doActions
{
    count -= 1;
}

-(NSString *) checkConditions
{
    NSMutableDictionary *st = [owner status];
    NSValue *barkOrigin = [st objectForKey:@"heard_bark"];
    if (barkOrigin) {
        return @"SheepStateRunning";
    }
    if (count <= 0) {
        return @"SheepStateGrouping";
    }
    return nil;
}

@end


@implementation SheepStateRunning

-(id) initWithOwner:(id)ownerPtr
{
    self = [super initWithName:@"SheepStateRunning" owner:ownerPtr];
    if (self) {
        MAX_HEARING_DIST = 150;
        MAX_COUNT = 150;
        count = MAX_COUNT;
        owner = ownerPtr;
    }
    return self;
}

-(void) entryActions
{
    NSLog(@"RUNNING STATE");
    count = MAX_COUNT;
}

-(void) exitActions
{
    // clear the heard_bark status
    NSMutableDictionary *st = [owner status];
    [st removeObjectForKey:@"heard_bark"];
}

-(void) doActions
{
    count -= 1;
    NSMutableDictionary *st = [owner status];
    NSValue *barkValue = [st objectForKey:@"heard_bark"];
    CGPoint direction = cpvsub(owner.body->p, [barkValue CGPointValue]);

    float dist = cpvlength(direction);
    direction = cpvnormalize(direction);
    dist = MIN(dist, MAX_HEARING_DIST);
    float speed = 1.0 - (dist/MAX_HEARING_DIST);
    [owner move_direction:direction speed:speed];
}

-(NSString *) checkConditions
{
    if (count <= 0) {
        return @"SheepStateGrouping";
    }
    return nil;
}

@end


@implementation SheepStateGrouping

-(id) initWithOwner:(id)ownerPtr
{
    self = [super initWithName:@"SheepStateGrouping" owner:ownerPtr];
    if (self) {
        MAX_COUNT = 150;
        count = MAX_COUNT;
        owner = ownerPtr;
    }
    return self;
}

-(void) entryActions
{
    NSLog(@"GROUPING STATE");
    count = MAX_COUNT;
}

-(void) exitActions
{
}

-(void) doActions
{
    count -= 1;
    
    Actor * nearestSheep = [[World sharedWorld] nearets_actor_type:@"sheep" to_actor:owner];
    if (nearestSheep) {
        CGPoint direction = cpvsub(nearestSheep.body->p, owner.body->p);
        [owner move_direction:cpvnormalize(direction) speed:0.3];
    }
}

-(NSString *) checkConditions
{
    NSMutableDictionary *st = [owner status];
    NSValue *barkOrigin = [st objectForKey:@"heard_bark"];
    if (barkOrigin) {
        return @"SheepStateRunning";
    }
    if (count <= 0) {
        return @"SheepStateSnoozing";
    }
    return nil;
}

@end
