//
//  AI.h
//  HerdKing
//
//  Created by joao on 2010/03/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "chipmunk.h"
#import "Actors.h"


@interface State : NSObject {
    NSString *name;
    Actor *owner; // Reference to the Object that has this AI
    cpSpace *space; // space where the physics simulation happens
    cpShape *shape; // shape of the entity in the physics space
}

@property (readonly) NSString* name;

-(id) initWithName:(NSString *)n owner:(id)object;
-(void) doActions;
-(NSString *) checkConditions;
-(void) entryActions;
-(void) exitActions;

@end


@interface StateMachine : NSObject {
    NSMutableDictionary *states;
    id activeState; // pointer to an Object that implements State protocol
}
-(void) addState:(State *)state;
-(void) setActiveStateByName:(NSString *)state;
-(void) think;

@end


@interface SheepStateSnoozing : State {
    int MAX_COUNT;
    int count;
}

-(id) initWithOwner:(id)object;

@end


@interface SheepStateGrouping : State {
    int MAX_COUNT;
    int count;
}

-(id) initWithOwner:(id)object;

@end


@interface SheepStateRunning : State {
    int MAX_HEARING_DIST;
    int MAX_COUNT;
    int count;
}

-(id) initWithOwner:(id)object;

@end
