//
//  Actors.m
//  HerdKing
//
//  Created by joao on 2010/03/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Actors.h"

@implementation Actor

@synthesize worldId;
@synthesize name;
@synthesize body;

-(void) addToSpace:(cpSpace *)space
{
    cpSpaceAddBody(space, body);
    cpSpaceAddShape(space, shape);
}

-(void) removeFromSpace:(cpSpace *)space;
{
    cpSpaceRemoveBody(space, body);
    cpSpaceRemoveShape(space, shape);
}

-(void) dealloc
{
    cpBodyDestroy(body);
    [super dealloc];
}

@end


@implementation Dog

-(id) init
{
    self = [super init];
    if (self != nil) {
        eventQueue = [NSMutableArray new];
        type = @"player";
        radius = 6.0;
        mass = 5.0;
        impulse = 10;
        inertia = cpMomentForCircle(mass, 0, radius, CGPointZero);
        NSLog(@"inertia=%f", inertia);
        body = cpBodyNew(mass, inertia);
        cpBodySetPos(body, CGPointMake(60.0, 60.0));
        shape = cpCircleShapeNew(body, radius, CGPointZero);
        sprite = [CCSprite spriteWithFile:@"cao.png"];
        [sprite retain];

        shape->data = self;
        if (!sprite) {
            NSLog(@"sprite == nill !!!");
        }
        else {
            NSLog(@"sprite loaded !!!");
            [self addChild:sprite];
        }
        // Register to receive acceleration events
        [[EventManager sharedEventManager] registerListener:self eventType:@"accel_data"];
        [[EventManager sharedEventManager] registerListener:self eventType:@"touch_data"];
        [[EventManager sharedEventManager] registerListener:self eventType:@"peak_event"];
    }
    return self;
}

-(void) updateWithTime:(float)dt
{
    Event *e;
    for (e in eventQueue) {
        [self handleEvent:e];
    }
    [eventQueue removeAllObjects];
    [sprite setPosition:body->p];
}

//-(void) draw
//{
//    static const GLfloat vertices[] =
//    {
//        2.0, 2.0,
//        318.0, 478.0
//    };
//    static const GLubyte colors[] = {
//        255,   0,   0, 255,
//          0, 255, 255, 255
//    };
//    glDisable(GL_TEXTURE_2D);
//    glEnableClientState(GL_COLOR_ARRAY);
//
//    glTranslatef(0.0, 0.0, 10.0);
//    glLineWidth(1.0f);
//    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
//    glVertexPointer(2, GL_FLOAT, 0, vertices);
//    glDrawArrays(GL_LINES, 0, 2);
//
//    glDisableClientState(GL_COLOR_ARRAY);
//    glEnable(GL_TEXTURE_2D);
//    [super draw];
//}

-(void) notify_event:(Event *)event
{
    [eventQueue addObject:event];
}

-(void) handleEvent:(Event *)event
{
    if ([event eventType] == @"accel_data") {
        NSValue *value = [[event parameters] objectForKey:@"vector"];
        CGPoint vector = [value CGPointValue];

        cpBodyResetForces(body);
        cpBodyApplyForce(body, ccpMult(vector, 900), CGPointZero);
    }
    if ([event eventType] == @"touch_data") {
        Event *e = [[Event alloc] initWithType:@"bark_event"];

        NSValue *value = [NSValue valueWithCGPoint:body->p];
        [[e parameters] setObject:value forKey:@"origin"];
        [[EventManager sharedEventManager] triggerEvent:e];
    }
    if ([event eventType] == @"peak_event") {
        Event *e = [[Event alloc] initWithType:@"bark_event"];

        NSValue *value = [NSValue valueWithCGPoint:body->p];
        [[e parameters] setObject:value forKey:@"origin"];

        [[EventManager sharedEventManager] triggerEvent:e];
    }
}

-(void) dealloc
{
    [eventQueue release];
    cpShapeDestroy(shape);
    [type release];
    [sprite release];
    [super dealloc];
}

@end


@implementation Sheep

-(id) init
{
    self = [super init];
    if (self != nil) {
        eventQueue = [NSMutableArray new];
        type = @"sheep";
        radius = 12.0;
        mass = 10.0;
        impulse = 10;
        inertia = cpMomentForCircle(mass, 0, radius, CGPointZero);
        body = cpBodyNew(mass, inertia);
        cpBodySetPos(body, CGPointMake(120.0, 120.0));
        shape = cpCircleShapeNew(body, radius, CGPointZero);
        sprite = [CCSprite spriteWithFile:@"sheep.png"];
        [sprite retain];

        if (!sprite) {
            NSLog(@"sprite == nill !!!");
        }
        else {
            NSLog(@"sprite loaded !!!");
            [sprite setRotation:0.5];
            [self addChild:sprite];
        }
        shape->data = self;
        // AI
        brain = [[StateMachine alloc] init];
        State *st = [[SheepStateSnoozing alloc] init];
        [brain addState:st];
        [brain setActiveStateByName:[st name]];
    }
    [[EventManager sharedEventManager] registerListener:self eventType:@"bark_event"];

    return self;
}

-(void) updateWithTime:(float)dt
{
    Event *e;
    for (e in eventQueue) {
        [self handleEvent:e];
    }
    [eventQueue removeAllObjects];
    [sprite setPosition:body->p];
}

-(void) notify_event:(Event *)event
{
    [eventQueue addObject:event];
}

-(void) handleEvent:(Event *)event
{
    // Bark Event
    if ([event eventType] == @"bark_event") {
        NSValue *value = [[event parameters] objectForKey:@"origin"];
        barkOrigin = [value CGPointValue];
    }
}

-(void) dealloc
{
    cpShapeDestroy(shape);
    [type release];
    [brain release];
    [sprite release];
    [super dealloc];
}

@end


@implementation FenceSegment

-(id) init
{
    self = [super init];
    if (self != nil) {
        type = @"fence";
        vertices[0] = 120.0; vertices[1] = 480.0;
        vertices[2] = 120.0; vertices[3] = 400.0;
        vertices[4] = 200.0; vertices[5] = 480.0;
        vertices[6] = 200.0; vertices[7] = 400.0;
        colors[0] = 255; colors[1] = 100; colors[2] = 100; colors[3] = 255;
        colors[4] = 255; colors[5] = 100; colors[6] = 100; colors[7] = 255;
        colors[8] = 255; colors[9] = 100; colors[10] = 100; colors[11] = 255;
        colors[12] = 255; colors[13] = 100; colors[14] = 100; colors[15] = 255;

        body = cpBodyNew(INFINITY, INFINITY);
        cpBodySetPos(body, CGPointMake(0.0, 0.0));
        cpShape *l1 = cpSegmentShapeNew(body, CGPointMake(vertices[0], vertices[1]),
                                        CGPointMake(vertices[2], vertices[3]), 4.0);
        l1->e = 0.6;
        cpShape *l2 = cpSegmentShapeNew(body, CGPointMake(vertices[4], vertices[5]),
                                        CGPointMake(vertices[6], vertices[7]), 4.0);
        l2->e = 0.6;
        shapeArray[0] = l1;
        shapeArray[1] = l2;
        bb = cpBBNew(120.0, 400.0, 200.0, 480.0);
    }
    return self;
}

-(void) addToSpace:(cpSpace *)space
{
    cpSpaceAddStaticShape(space, shapeArray[0]);
    cpSpaceAddStaticShape(space, shapeArray[1]);
}

-(void) removeFromSpace:(cpSpace *)space;
{
//    cpSpaceRemoveBody(space, body);
    cpSpaceRemoveShape(space, shapeArray[0]);
    cpSpaceRemoveShape(space, shapeArray[1]);
}

-(void) draw
{
    BOOL texture2dEnabled = glIsEnabled(GL_TEXTURE_2D);
    if (texture2dEnabled) {
        glDisable(GL_TEXTURE_2D);
    }
    BOOL colorArrayEnabled = glIsEnabled(GL_COLOR_ARRAY);
    if (!colorArrayEnabled) {
        glEnableClientState(GL_COLOR_ARRAY);
    }

    BOOL vertexArrayEnabled = glIsEnabled(GL_VERTEX_ARRAY);
    if (!vertexArrayEnabled) {
        glEnableClientState(GL_VERTEX_ARRAY);
    }

//    glTranslatef(60.0, 1.0, 0.0);
    glLineWidth(2.0f);

    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    glVertexPointer(2, GL_FLOAT, 0, vertices);

    glDrawArrays(GL_LINES, 0, 4);

    if (!vertexArrayEnabled) {
        glDisableClientState(GL_VERTEX_ARRAY);
    }
    if (!colorArrayEnabled) {
        glDisableClientState(GL_COLOR_ARRAY);
    }
    if (texture2dEnabled) {
        glEnable(GL_TEXTURE_2D);
    }
}

-(void) updateWithTime:(float)dt
{
    NSLog(@"FenceSegment upddateWithTime: This function shuld not be called !!");
}

- (void) dealloc
{
    cpShapeDestroy(shapeArray[0]);
    cpShapeDestroy(shapeArray[1]);
    [type release];
    [super dealloc];
}

@end
