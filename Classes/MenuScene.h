//
//  MenuScene.h
//  HerdingKing
//
//  Created by joao on 2010/03/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CCScene.h"


@interface MenuScene : CCScene {

}

+(id) scene;

-(void) onPlay:(id)sender;
-(void) onSettings:(id)sender;
-(void) onAbout:(id)sender;

@end

@interface StettingsScene : CCScene {
    
}

@end

@interface AboutScene : CCScene {
    
}

-(void) onTouch:(id)sender;

@end