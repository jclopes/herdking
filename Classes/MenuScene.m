//
//  MenuScene.m
//  HerdKing
//
//  Created by joao on 2010/03/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuScene.h"

#import "CCMenu.h"
#import "cocos2d.h"

#import "WorldScene.h"

@implementation MenuScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MenuScene *layer = [MenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


-(id) init
{
    self = [super init];
    if (self != nil) {
        [CCMenuItemFont setFontName:@"American Typewriter"];
        CCMenuItem *menuItem1 = [CCMenuItemFont itemFromString:@"Play" target:self selector:@selector(onPlay:)];
        CCMenuItem *menuItem2 = [CCMenuItemFont itemFromString:@"Settings" target:self selector:@selector(onSettings:)];
        CCMenuItem *menuItem3 = [CCMenuItemFont itemFromString:@"About" target:self selector:@selector(onAbout:)];
        CCMenu *menu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, nil];
        [menu alignItemsVertically];
        
        [self addChild:menu];
    }
    return self;
}

-(void) onPlay:(id)sender
{
    NSLog(@"on play");
    [[CCDirector sharedDirector] replaceScene:[World node]];
}

-(void) onSettings:(id)sender
{
    NSLog(@"on settings");
    [[CCDirector sharedDirector] replaceScene:[World node]];
}

-(void) onAbout:(id)sender
{
    NSLog(@"on about");
    [[CCDirector sharedDirector] replaceScene:[AboutScene node]];
}

@end


@implementation AboutScene

- (id) init
{
    self = [super init];
    
    if (self != nil) {
        CCSprite *background = [CCSprite spriteWithFile:@"about.png"];
        [background setPosition:CGPointMake(160, 240)];

        CCMenuItem *menuItem = [CCMenuItemSprite itemFromNormalSprite:background selectedSprite:nil target:self selector:@selector(onTouch:)];
        CCMenu *menu = [CCMenu menuWithItems:menuItem, nil];
        
        [self addChild:menu];
    }
    return self;
}

-(void) onTouch:(id) sender
{
    [[CCDirector sharedDirector] replaceScene:[MenuScene node]];
}

@end


@implementation TimeOutScene

- (id) init
{
    self = [super init];
    
    if (self != nil) {
        BOOL completedLevel = [[World sharedWorld] completedLevel];
        CCSprite *background;
        if (completedLevel) {
            background = [CCSprite spriteWithFile:@"victory.png"];
        }
        else {
            background = [CCSprite spriteWithFile:@"timeout.png"];
        }
        [background setPosition:CGPointMake(160, 240)];
        
        CCMenuItem *menuItem = [CCMenuItemSprite itemFromNormalSprite:background selectedSprite:nil target:self selector:@selector(onTouch:)];
        CCMenu *menu = [CCMenu menuWithItems:menuItem, nil];
        
        [self addChild:menu];
        
        CCLabel *totalTime = [CCLabel labelWithString:[NSString stringWithFormat:@"Total playing time: %2.2f",
                                                       [[World sharedWorld] allPlayingTime]]
                                             fontName:@"Arial"
                                             fontSize:20];
        [totalTime setPosition:CGPointMake(160, 270)];
        [self addChild:totalTime];
        CCLabel *numberOfSheeps = [CCLabel labelWithString:[NSString stringWithFormat:@"Score: %4d",
                                                            [[World sharedWorld] totalHerdedSheeps]]
                                                  fontName:@"Arial"
                                                  fontSize:20];
        [numberOfSheeps setPosition:CGPointMake(160, 230)];
        [self addChild:numberOfSheeps];
    }
    return self;
}

-(void) onTouch:(id) sender
{
    BOOL completedLevel = [[World sharedWorld] completedLevel];
    if (completedLevel) {
        [[CCDirector sharedDirector] replaceScene:[World node]];
    }
    else {
        [[CCDirector sharedDirector] replaceScene:[MenuScene node]];
    }
}

@end

