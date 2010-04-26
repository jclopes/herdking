//
//  Events.m
//  HerdKing
//
//  Created by joao on 2010/04/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Events.h"


@implementation Event

@synthesize eventType;
@synthesize parameters;

-(id) initWithType:(NSString *)type
{
    self = [super init];
    if (self != nil) {
        eventType = type;
        parameters = [NSMutableDictionary new];
    }
    return self;
}

-(void) dealloc
{
    [parameters release];
    [eventType release];
    [super dealloc];
}

@end

static EventManager *sharedEventManager = nil;

@implementation EventManager

// Singleton Design Pattern

+(EventManager *) sharedEventManager
{
    if (sharedEventManager == nil) {
        sharedEventManager = [[super allocWithZone:NULL] init];
    }
    
    return sharedEventManager;
}

+(id) allocWithZone:(NSZone *)zone
{
    return [self sharedEventManager];
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)init {
	if ([super init] == nil)
		return nil;
    
    listeners = [NSMutableDictionary new];
	return self;
}

- (id)retain {
	return self;
}

- (unsigned)retainCount {
	return UINT_MAX;
}

- (void)release {
	// Do nothing.
}

- (id)autorelease {
	return self;
}

// EventManager implementation

-(void) registerListener:(id)listener eventType:(id)type
{
    NSMutableArray *eventListeners = [listeners objectForKey:type];
    if (eventListeners == nil) {
        eventListeners = [NSMutableArray new];
        [listeners setObject:eventListeners forKey:type];
    }
    [eventListeners addObject:listener];
}

-(void) deregisterListener:(id)listener eventType:(id)type
{
    NSMutableArray *eventListeners = [listener objectForKey:type];
    if (eventListeners != nil) {
        [eventListeners removeObject:listener];
    }
}

-(void) triggerEvent:(Event *)event
{
    if (listeners != nil) {
        NSMutableArray *eventListeners = [listeners objectForKey:[event eventType]];
        if (eventListeners != nil) {
            for (id<EventListener> listener in eventListeners) {
                [listener notify_event:event];
            }
        }
    }
}

@end
