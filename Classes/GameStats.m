//
//  GameStats.m
//  HerdKing
//
//  Created by joao on 2010/05/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameStats.h"

static GameStats *sharedGameStats = nil;

@implementation GameStats

@synthesize nextLevel;
@synthesize allPlayingTime;
@synthesize totalHerdedSheeps;
@synthesize completedLevel;

// Singleton Design Pattern

+(GameStats *) sharedGameStats
{
    if (sharedGameStats == nil) {
        sharedGameStats = [[super allocWithZone:NULL] init];
    }
    
    return sharedGameStats;
}

+(id) allocWithZone:(NSZone *)zone
{
    return [self sharedGameStats];
}

- (id)copyWithZone:(NSZone *)zone {
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

// GameStats implementation

- (id)init
{
	if ((self=[super init])) {
        nextLevel = 1;
        completedLevel = NO;
        levelTime = 0;
        allPlayingTime = 0;
        totalHerdedSheeps = 0;
	}
	return self;
}

- (void)setLevelTime:(float)time {
    levelTime = time;
    allPlayingTime += time;
}

- (float)levelTime {
    return levelTime;
}

- (void)setCompletedLevel:(BOOL)completed {
    completedLevel = completed;
    nextLevel += 1;
}

- (void) dealloc
{
    [super dealloc];
}

@end
