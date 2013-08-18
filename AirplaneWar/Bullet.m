//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Bullet.h"
#import "TextureConfig.h"


@implementation Bullet

- (id)init
{
    self = [super initWithFile:@"shoot.png" rect:CGRectMake(1004, 987, 9, 21)];
    if (self) {
        self.scale = kTextureScale;
        _damage = 1;
    }
    return self;
}
@end