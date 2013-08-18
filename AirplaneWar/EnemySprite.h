//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger , EnemySize) {
    SMALL_PLANE,
    MEDIUM_PLANE,
    BIG_PLANE
};

@interface EnemySprite : CCSprite
- (id)initWithSize:(EnemySize)size hp:(int)hp;

// Return:
//  YES: die
- (BOOL)onHitWithDamage:(int)damage;
@end