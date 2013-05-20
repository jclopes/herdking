//
//  MenuScene.h
//  HerdKing
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


@interface SettingsScene : CCScene {
    
}

@end


@interface AboutScene : CCScene {
    
}

-(void) onTouch:(id)sender;

@end


@interface HowtoPlayScene : CCScene {
    
}

-(void) onTouch:(id)sender;

@end


@interface TimeOutScene : CCScene {
    
}

-(void) onTouch:(id)sender;

@end


@interface VictoryScene : CCScene {
    
}

-(void) onTouch:(id)sender;

@end