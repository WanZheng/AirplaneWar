//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "MultiFrameSprite.h"

typedef NS_ENUM(NSInteger, EnemyModel) {
    kEnemyModel1 = 0,
    kEnemyModel2,
    kEnemyModel3,
    kNumberOfEnemyModel
};

typedef NS_ENUM(NSInteger, EnemyState) {
    kEnemyStateEmpty = 0,
    kEnemyStateNormal,
    kEnemyStateHit,
    kEnemyStateDown,
    kEnemyStateDied
};

@interface Enemy : MultiFrameSprite
@property (nonatomic, readonly) EnemyState state;

+ (Enemy *)enemyWithModel:(EnemyModel)model;

- (int)score;
- (BOOL)died;

- (void)didHitWithDamage:(int)damage;
@end