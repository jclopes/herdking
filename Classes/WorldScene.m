//
// World
// Class that represents the level world map where all happens
//

#import "SCListener.h"

// Import the interfaces
#import "WorldScene.h"

#import "MenuScene.h"
#import "AI.h"
#import "Events.h"
#import "GameStats.h"

@implementation World

@synthesize levelTime;
@synthesize totalHerdedSheeps;
@synthesize completedLevel;
@synthesize level;

// World implementation

-(id) init
{
	if ((self=[super init])) {
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
        level = [GameStats sharedGameStats].nextLevel;
        MAX_LEVEL_TIME = 60;
        completedLevel = NO;
        levelTime = 0;
        totalHerdedSheeps = 0;
        
        idCounter = 0;
        actorsList = [NSMutableArray new];
        brainsList = [NSMutableArray new];
        
		CGSize wins = [[CCDirector sharedDirector] winSize];
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.position = CGPointMake(160, 240);
        [self addChild:background];
        
		cpInitChipmunk();
		
		cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
		space = cpSpaceNew();
		cpSpaceResizeStaticHash(space, 400.0f, 40);
		cpSpaceResizeActiveHash(space, 100, 600);
		
        space->damping = 0.6;
		space->gravity = CGPointZero;
        space->iterations = 30;
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
        
        timerText = [CCLabel labelWithString:[NSString stringWithFormat:@"%2.2f", MAX_LEVEL_TIME] fontName:@"Arial" fontSize:14];
        [timerText setPosition:CGPointMake(160, 470)];
        [self addChild:timerText];
        
        // Start mic listening
        [[SCListener sharedListener] listen];
	}
	
	return self;
}

- (void) dealloc
{
    [player release];
    [fence release];
    cpSpaceDestroy(space);
    [actorsList release];
    [brainsList release];
    [super dealloc];
}

-(void) load_level:(int)levelNumber
{
    NSString *levelName = [NSString stringWithFormat:@"lv%d", levelNumber];
    NSString *fullpath = [[NSBundle mainBundle]pathForResource:levelName ofType:@"plist"];
    NSDictionary *lv = [NSDictionary dictionaryWithContentsOfFile:fullpath];
    
    // Load Player Dog
    NSDictionary *dogPosition = [lv objectForKey:@"dog"];
    NSNumber *x = [dogPosition objectForKey:@"x"];
    NSNumber *y = [dogPosition objectForKey:@"y"];
    player = [[Dog alloc]initWithPosition:CGPointMake([x intValue], [y intValue])];
    [self addActor:player];
    
    // Load Sheeps
    NSArray *sheepList = [lv objectForKey:@"sheeps"];
    for (NSDictionary *sheepPosition in sheepList) {
        x = [sheepPosition objectForKey:@"x"];
        y = [sheepPosition objectForKey:@"y"];
        Actor *sheep = [[[Sheep alloc]initWithPosition:CGPointMake([x intValue], [y intValue])]autorelease];
        [self addActor:sheep];
        
        // AI for sheep
        StateMachine *sheepBrain = [[[StateMachine alloc] init] autorelease];
        State *st = [[SheepStateSnoozing alloc] initWithOwner:sheep];
        [sheepBrain addState:st];
        [sheepBrain setActiveStateByName:[st name]];
        st = [[[SheepStateRunning alloc] initWithOwner:sheep] autorelease];
        [sheepBrain addState:st];
        st = [[[SheepStateGrouping alloc] initWithOwner:sheep] autorelease];
        [sheepBrain addState:st];
        [brainsList addObject:sheepBrain];
    }
    
    NSArray *lineList = [lv objectForKey:@"lines"];
    for (NSDictionary *linePoints in lineList) {
        NSNumber *ax = [linePoints objectForKey:@"ax"];
        NSNumber *ay = [linePoints objectForKey:@"ay"];
        NSNumber *bx = [linePoints objectForKey:@"bx"];
        NSNumber *by = [linePoints objectForKey:@"by"];
        LineSegment *line = [[[LineSegment alloc]
                             initWithPointA:CGPointMake([ax intValue], [ay intValue])
                             andPointB:CGPointMake([bx intValue], [by intValue])]
                             autorelease];
        [self addActor:line];
    }
    
    // Load Fence
    fence = [[FenceSegment alloc]init];
    [self addActor:fence];
}

-(int) nextId
{
    idCounter += 1;
    return idCounter;
}

-(void) addActor:(Actor *)actor
{
    actor.world = self;
    actor.worldId = [self nextId];
    [actor addToSpace:space];
    [actorsList addObject:actor];
    [self addChild:actor];
}

-(void) removeActor:(Actor *)actor
{
    [actor removeFromSpace:space];
    [self removeChild:actor cleanup:YES];
    [actorsList removeObject:actor];
}

-(Actor *) nearets_actor_type:(NSString *)type to_actor:(Actor *)actor
{
    Actor *res = nil;
    float minDist = 0;
    CGPoint position = actor.body->p;
    
    for (Actor *a in actorsList) {
        if ([a type] == type && a != actor) {
            float dist = cpvlengthsq(cpvsub(position, [a body]->p));
            if ((minDist == 0) || (minDist > dist)) {
                res = a;
            }
        }
    }
    return res;
}

-(BOOL) check_end:(ccTime)delta
{
    BOOL res = NO;
    int sheepsOutside = 0;
    
    if (levelTime >= MAX_LEVEL_TIME) {
        NSLog(@"GAME OVER");
        res = YES;
    }
    for (Actor *a in actorsList) {
        if (a.type == @"sheep") {
            if( cpBBcontainsBB([fence bb], a.shape->bb) ) {
                [self removeActor:a];
                totalHerdedSheeps += 1;
            }
            else {
                sheepsOutside += 1;
            }
        }
    }
    if (sheepsOutside == 0) {
        [GameStats sharedGameStats].totalHerdedSheeps += totalHerdedSheeps;
        [GameStats sharedGameStats].levelTime = levelTime;
        [GameStats sharedGameStats].completedLevel = YES;
        completedLevel = YES;
        res = YES;
    }
    return res;
}

-(void) onEnter
{
	[super onEnter];
    
	NSLog(@"!!! ENTER WORLD !!!");
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    completedLevel = NO;
    [self load_level:level];
    
    // Start accelerometer
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 40)];
    
    // disable screensaver
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Run step method every frame
    [self schedule: @selector(step:)];
    // Run check_mic every 0.33 second
    [self schedule: @selector(check_mic:) interval: 1.0/3];
}

-(void) onEnd:(ccTime)dt
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[SCListener sharedListener] stop];
    [[CCDirector sharedDirector] replaceScene:[TimeOutScene node]];
}

-(void) check_mic:(ccTime)delta
{
    float soundPeak = [[SCListener sharedListener] peakPower];
    if (soundPeak > 0.5) {
        Event *e = [[Event alloc] initWithType:@"peak_event"];
        NSNumber *value = [NSNumber numberWithFloat:soundPeak];
        [[e parameters] setObject:value forKey:@"peak_volume"];
        [[EventManager sharedEventManager] triggerEvent:e];
        [e release];
    }
}

-(void) step:(ccTime)delta
{
    [timerText setString:[NSString stringWithFormat:@"%2.3f", MAX_LEVEL_TIME - levelTime]];
    if (!([self check_end:delta])) {
        for (Actor *actor in actorsList) {
            [actor updateWithTime:delta];
        }
        for (StateMachine *brain in brainsList) {
            [brain think];
        }
        levelTime += delta;
    
        cpSpaceStep(space, 1.0/59.0);
    }
    else {
        [self onEnd:delta];
    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for( UITouch *touch in touches ) {
        CGPoint vector = [touch locationInView: [touch view]];
        NSValue *value = [NSValue valueWithCGPoint:vector];

        vector = [[CCDirector sharedDirector] convertToGL: vector];
        Event *e = [[Event alloc] initWithType:@"touch_data"];
        
        [[e parameters] setObject:value forKey:@"vector"];
        [[EventManager sharedEventManager] triggerEvent:e];
        [e release];
    }
}

// Use the accelerometer data to control the player movement
-(void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
    //Lowpass filter
	static float prevX=0, prevY=0;
	
#define kFilterFactor 0.1f
#define kAttenuation 3.0f
#define kMinStep 0.02f
    
	float baseAccelX = ((float) acceleration.x * kFilterFactor) + (prevX * (1.0 - kFilterFactor));
	float baseAccelY = ((float) acceleration.y * kFilterFactor) + (prevY * (1.0 - kFilterFactor));
    
	prevX = baseAccelX;
	prevY = baseAccelY;

    float dx = clampf(abs(baseAccelX - acceleration.x)/kMinStep - 1.0, 0.0, 1.0);
    float dy = clampf(abs(baseAccelY - acceleration.y)/kMinStep - 1.0, 0.0, 1.0);
    
    float alphaX = (1. - dx) * kFilterFactor/kAttenuation + dx * kFilterFactor;
    float alphaY = (1. - dy) * kFilterFactor/kAttenuation + dy * kFilterFactor;
    float resAccelX = acceleration.x * alphaX + baseAccelX * (1. - alphaX);
    float resAccelY = acceleration.y * alphaY + baseAccelY * (1. - alphaY);
    
	CGPoint vector = CGPointMake(resAccelX, resAccelY);
    NSValue *value = [NSValue valueWithCGPoint:vector];
    
    EventManager *em = [EventManager sharedEventManager];
	Event *e = [[Event alloc] initWithType:@"accel_data"];
    [[e parameters] setObject:value forKey:@"vector"];
    [em triggerEvent:e];
    [e release];
}

@end
