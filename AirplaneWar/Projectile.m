//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Projectile.h"


@implementation Projectile

- (id)init
{
    self = [super initWithFile:@"projectile.png"];
    if (self) {
        _damage = 1;
    }
    return self;
}
@end