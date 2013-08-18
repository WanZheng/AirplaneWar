//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Bullet.h"


@implementation Bullet

- (id)init
{
    self = [super initWithFile:@"bullet.png"];
    if (self) {
        _damage = 1;
    }
    return self;
}
@end