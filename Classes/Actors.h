//
//  Actors.h
//  HerdKing
//
//  Created by joao on 2010/03/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 Description:
 Actor are the intervening objects of the game.
 Actors have a body and shape for the physics simulation and a
 visual representation either a sprite or a drawing generated
 by the draw() function.
 They will have an update() function that sincronizes the visual
 representation with the physics simulation and also run the AI.
*/

#import <Foundation/Foundation.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "CCSprite.h"

// Importing Chipmunk headers
#import "chipmunk.h"

#import "Events.h"


@interface Actor : CCNode {
    int worldId;
    id name;
    NSString *type;
    float mass;
    float inertia;
    int impulse;
    cpBody *body;
    cpShape *shape;
    NSMutableDictionary *status;
}

@property (readwrite) int worldId;
@property (readonly) NSString *type;
@property (retain, readwrite) id name;
@property (readonly) cpBody *body;
@property (readonly) cpShape *shape;
@property (retain, readwrite) NSMutableDictionary *status;

-(void) updateWithTime:(float) dt;
-(void) addToSpace:(cpSpace *)space;
-(void) removeFromSpace:(cpSpace *)space;
-(void) move_direction:(CGPoint)direction speed:(float)s;

@end


@interface Dog : Actor <EventListener> {
    int radius;
    float MAX_SPEED;
    CCSprite *sprite;
    NSMutableArray *eventQueue;
}

-(id) initWithPosition:(CGPoint) p;
-(void) handleEvent:(Event *)event;

@end


@interface Sheep : Actor <EventListener> {
    int radius;
    
    CCSprite *sprite;
    
//    StateMachine *brain;
    
    NSMutableArray *eventQueue;
}

-(id) initWithPosition:(CGPoint) p;
-(void) handleEvent:(Event *)event;

@end


@interface FenceSegment : Actor {
    cpShape *shapeArray[2];
    cpBB bb;
    GLfloat vertices[8];    // 4x (X, Y)
    GLubyte colors[16];     // 4x (R, G, B, A)
}

@property (readonly)cpBB bb;

@end