//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "EnemySprite.h"

@interface EnemySprite()
@property (nonatomic) int hp;
@end

@implementation EnemySprite
- (id)initWithSize:(EnemySize)size hp:(int)hp
{
    NSString *file;
    switch (size) {
        case SMALL_PLANE:
            file = @"enemy.png";
            break;
        case MEDIUM_PLANE:
            file = @"enemy.png";
            break;
        case BIG_PLANE:
            file = @"enemy.png";
            break;
    }
    self = [super initWithFile:file];

    if (self) {
        _hp = hp;

        CGSize winSize = [CCDirector sharedDirector].winSize;
        int x = (int)((arc4random() % (int)(winSize.width - self.contentSize.width)) + self.contentSize.width/2);
        self.position = ccp(x, winSize.height + self.contentSize.height/2);
    }

    return self;
}

- (BOOL)onHitWithDamage:(int)damage
{
    self.hp -= damage;
    return (self.hp <= 0);
}

@end