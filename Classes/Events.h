//
//  Events.h
//  HerdKing
//
//  Created by joao on 2010/04/01.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject
{
    NSString *eventType;
    NSMutableDictionary *parameters;
}

@property (readonly) NSString *eventType;
@property (retain, readwrite) NSMutableDictionary *parameters;

-(id) initWithType:(NSString *)type;

@end


@interface EventManager : NSObject {
    NSMutableDictionary *listeners;
}

+ (EventManager *)sharedEventManager;

-(void) registerListener:(id)listener eventType:(id)type;
-(void) deregisterListener:(id)listener eventType:(id)type;
-(void) triggerEvent:(Event *)event;

@end


@protocol EventListener

// This method shuold store the event and return immediately
-(void) notify_event:(Event *)event;

@end
