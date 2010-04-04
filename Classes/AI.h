//
//  AI.h
//  HerdingKing
//
//  Created by joao on 2010/03/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "chipmunk.h"

@interface State : NSObject {
    NSString *name;
    cpSpace *space; // space where the physics simulation happens
    cpShape *shape; // shape of the entity in the physics space
}
@property (readonly) NSString* name;
-(id) initWithName:(NSString *)n;
-(void) doActions;
-(NSString *) checkConditions;
-(void) entryActions;
-(void) exitActions;

@end

@interface StateMachine : NSObject {
    NSMutableDictionary *states;
    id activeState; // pointer to an Object that implements State protocol
}
-(id) addState:(State *)state;
-(id) setActiveStateByName:(NSString *)state;
-(id) think;

@end

@interface SheepStateSnoozing : State {
    int count;
}

@end

@interface SheepStateRunning : State {
    int count;
}

@end
