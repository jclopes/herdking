//
// cocos2d World example
// http://www.cocos2d-iphone.org
//

#import "SCListener.h"

// Import the interfaces
#import "WorldScene.h"

#import "MenuScene.h"
#import "Events.h"

// World implementation
@implementation World

-(id) init
{
	if( (self=[super init])) {
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
        idCounter = 0;
        actorsList = [NSMutableArray new];
        
		CGSize wins = [[CCDirector sharedDirector] winSize];
		cpInitChipmunk();
		
		cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
		space = cpSpaceNew();
		cpSpaceResizeStaticHash(space, 400.0f, 40);
		cpSpaceResizeActiveHash(space, 100, 600);
		
        space->damping = 0.6;
		space->gravity = ccp(0, 0);
		space->elasticIterations = space->iterations;
		
        // Creates Map boundaries
		cpShape *shape;
		
		// bottom
		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(wins.width,0), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// top
		shape = cpSegmentShapeNew(staticBody, ccp(0,wins.height), ccp(wins.width,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// left
		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(0,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// right
		shape = cpSegmentShapeNew(staticBody, ccp(wins.width,0), ccp(wins.width,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
        
        // Run step method every frame
		[self schedule: @selector(step:)];
        // Run check_mic every 0.1 second
        [self schedule:@selector(check_mic:)];
	}
	
	return self;
}

-(int) nextId
{
    idCounter += 1;
    return idCounter;
}

-(void) addActor:(Actor *)actor
{
    [actor setWorldId:[self nextId]];
    [actor addToSpace:space];
    [actorsList addObject:actor];
    [self addChild:actor];
}

-(void) removeActor:(Actor *)actor
{
// TODO:    [actor removeFromSpace:space];
    [self removeChild:actor cleanup:YES];
}

-(void) onEnter
{
	[super onEnter];
    
	NSLog(@"!!! ENTER WORLD !!!");
    
    // Add dynamic and static actors
    Actor *dog = [[Dog alloc]init];
    [self addActor:dog];
    player = dog;
    
    Actor *sheep = [[Sheep alloc]init];
    [self addActor:sheep];
    
    Actor *fence = [[FenceSegment alloc]init];
    [self addActor:fence];
    
    // Start accelerometer
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
    
    // Start mic listening
    [[SCListener sharedListener] listen];
}

-(void) onEnd:(ccTime)dt
{
    [[SCListener sharedListener] stop];
    [[CCDirector sharedDirector] replaceScene:[MenuScene node]];
}

-(void) check_mic:(ccTime)delta
{
    float soundPeak = [[SCListener sharedListener] peakPower];
    if (soundPeak > 0.5) {
        Event *e = [[Event alloc] initWithType:@"peak_event"];
        NSNumber *value = [NSNumber numberWithFloat:soundPeak];
        [[e parameters] setObject:value forKey:@"peak_volume"];
        [[EventManager sharedEventManager] triggerEvent:e];
    }
}

-(void) step:(ccTime)delta
{
    for (Actor *actor in actorsList) {
        [actor updateWithTime:delta];
    }
    
    cpSpaceStep(space, delta);
    
//	cpSpaceHashEach(space->activeShapes, &eachShape, &delta);
//	cpSpaceHashEach(space->staticShapes, &eachShape, &delta);
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for( UITouch *touch in touches ) {
        CGPoint vector = [touch locationInView: [touch view]];
        NSValue *value = [NSValue valueWithCGPoint:vector];

//        vector = [[CCDirector sharedDirector] convertToGL: vector];
        EventManager *em = [EventManager sharedEventManager];
        Event *e = [[Event alloc] initWithType:@"touch_data"];
        
        [[e parameters] setObject:value forKey:@"vector"];
        [em triggerEvent:e];
    }
}

// Use the accelerometer data to control the player movement
-(void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
#define kFilterFactor 0.05f
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	CGPoint vector = CGPointMake(accelX, accelY);
    NSValue *value = [NSValue valueWithCGPoint:vector];
    
    EventManager *em = [EventManager sharedEventManager];
	Event *e = [[Event alloc] initWithType:@"accel_data"];
    
    [[e parameters] setObject:value forKey:@"vector"];
    [em triggerEvent:e];
}

@end
