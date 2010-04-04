
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// Importing Chipmunk headers
#import "chipmunk.h"

// Import Actors
#import "Actors.h"


// World Layer
@interface World : CCLayer
{
    int idCounter;
    NSMutableArray *actorsList;
	cpSpace *space;
    Actor *player;
}

// returns a Scene that contains the World as the only child
-(int) nextId;
-(void) addActor:(Actor *) actor;
-(void) removeActor:(Actor *) actor;
-(void) onEnd:(ccTime) dt;
-(void) step:(ccTime) delta;
-(void) check_mic:(ccTime)delta;

@end