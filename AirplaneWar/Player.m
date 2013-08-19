//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Player.h"
#import "TextureConfig.h"

@implementation Player
- (id)init
{
    self = [super init];
    if (self) {
        self.scale = kTextureScale;

        [self setMultiFrame:[TextureConfig instance].framesForPlayerNormal frequency:16 repeat:YES];
    }
    return self;
}

@end