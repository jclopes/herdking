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

