//
//  GameStats.h
//  HerdKing
//
//  Created by joao on 2010/05/03.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GameStats : NSObject {
    float levelTime;
    float allPlayingTime;
    int totalHerdedSheeps;
    BOOL completedLevel;
    int nextLevel;
}

@property (readonly) int nextLevel;
@property (readwrite) float levelTime;
@property (readonly) float allPlayingTime;
@property (readwrite) int totalHerdedSheeps;
@property (readwrite) BOOL completedLevel;

+ (GameStats *)sharedGameStats;

@end
