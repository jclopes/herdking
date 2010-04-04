//
//  Actors.h
//  HerdingKing
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

#import "AI.h"
#import "Events.h"


@interface Actor : CCNode {
    int worldId;
    id name;
    NSString *type;
    cpBody *body;
    cpShape *shape;
}

@property (readwrite) int worldId;
@property (retain, readwrite) id name;
@property (readonly) cpBody *body;

-(void) draw;
-(void) updateWithTime:(float) dt;
-(void) addToSpace:(cpSpace *)space;
-(void) removeFromSpace:(cpSpace *)space;

@end


@interface Dog : Actor <EventListener> {
    int impulse;
    int radius;
    float mass;
    float inertia;
    CCSprite *sprite;
    NSMutableArray *eventQueue;
}

-(void) handleEvent:(Event *)event;

@end


@interface Sheep : Actor <EventListener> {
    int impulse;
    int radius;
    float mass;
    float inertia;
    CCSprite *sprite;
    StateMachine *brain;
    CGPoint barkOrigin;
    NSMutableArray *eventQueue;
}

-(void) handleEvent:(Event *)event;

@end


@interface FenceSegment : Actor {
    cpShape *shapeArray[2];
    cpBB bb;
    float mass;
    float inertia;
    GLfloat vertices[8];    // 4x (X, Y)
    GLubyte colors[16];     // 4x (R, G, B, A)
}

@end