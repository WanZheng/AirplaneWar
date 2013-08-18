//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "PlayerSprite.h"
#import "TextureConfig.h"


@implementation PlayerSprite
- (id)init
{
    self = [super initWithFile:@"shoot.png" rect:CGRectMake(0, 99, 102, 126)];
    if (self) {
        self.scale = kTextureScale;

        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.position = ccp(winSize.width/2, 10 + self.contentSize.height/2);
    }
    return self;
}
@end