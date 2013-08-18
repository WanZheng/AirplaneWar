//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "EnemySprite.h"
#import "TextureConfig.h"

@interface EnemySprite()
@property (nonatomic) int hp;
@end

@implementation EnemySprite
- (id)initWithSize:(EnemySize)size hp:(int)hp
{
    NSString *file;
    CGRect rect;
    switch (size) {
        case SMALL_PLANE:
            file = @"shoot.png";
            rect = CGRectMake(534, 612, 57, 43);
            break;
        case MEDIUM_PLANE:
            file = @"shoot.png";
            rect = CGRectMake(0, 0, 69, 99);
            break;
        case BIG_PLANE:
        default:
            file = @"shoot.png";
            rect = CGRectMake(335, 750, 169, 258);
            break;
    }
    self = [super initWithFile:file rect:rect];

    if (self) {
        self.scale = kTextureScale;

        switch (size) {
            case SMALL_PLANE:
                _score = 1000;
                break;
            case MEDIUM_PLANE:
                _score = 6000;
            case BIG_PLANE:
            default:
                _score = 30000;
                break;
        }

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