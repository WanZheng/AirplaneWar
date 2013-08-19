//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Enemy.h"
#import "TextureConfig.h"

@interface Enemy ()
@property (nonatomic) int score;
@property (nonatomic) EnemyModel model;
@property (nonatomic) ccTime timeLastHit;
@property (nonatomic) ccTime timeSinceHit;
@property (nonatomic) int hp;
@end

@implementation Enemy
+ (Enemy *)enemyWithModel:(EnemyModel)model {
    int hp;
    int score;

    switch (model) {
        case kEnemyModel1:
            hp = 1;
            score = 1000;
            break;
        case kEnemyModel2:
            hp = 6;
            score = 6000;
            break;
        case kEnemyModel3:
            hp = 30;
            score = 30000;
            break;
        default:
            NSAssert(NO, @"unknown model: %d", model);
            return nil;
    }

    Enemy *enemy = [[Enemy alloc] initWithModel:model];
    enemy.hp = hp;
    enemy.score = score;

    return enemy;
}

- (id)initWithModel:(EnemyModel)model {
    self = [super init];

    if (self) {
        _model = model;
        self.scale = kTextureScale;
        [self transToState:kEnemyStateNormal];
    }

    return self;
}

- (int)score {
    return _score;
}

- (void)didHitWithDamage:(int)damage
{
    self.hp -= damage;
    if (self.hp > 0) {
        [self transToState:kEnemyStateHit];
        self.timeLastHit = self.timeSinceHit;
    }else{
        [self transToState:kEnemyStateDown];
    }
}

- (BOOL)died {
    return (self.state == kEnemyStateDied);
}

- (void)transToState:(EnemyState)state {
    if (self.state == state) {
        return;
    }

    _state = state;
    [self onEnterState:state];
}

- (void)onEnterState:(EnemyState)state {
    switch (state) {
        case kEnemyStateHit:
            self.timeSinceHit = 0;
            break;
        case kEnemyStateDied:
            [self setSingleFrame:nil];
            return;
        default:
            break;
    }

    NSArray *frames = [[TextureConfig instance] framesForEnemy:self.model state:self.state];
    if (frames.count == 1) {
        [self setSingleFrame:frames[0]];
    }else{
        if (state != kEnemyStateDown) {
            [self setMultiFrame:frames frequency:16 repeat:YES];
        }else{
            [self setMultiFrame:frames frequency:16 repeat:NO];
        }
    }
}

- (void)onUpdate:(ccTime)dt {
    switch (self.state) {
        case kEnemyStateHit:
            self.timeSinceHit += dt;
            if (self.timeSinceHit - self.timeLastHit > 0.5){
                [self transToState:kEnemyStateNormal];
            }
            break;
        case kEnemyStateDown:
            if (self.framesFinished) {
                [self transToState:kEnemyStateDied];
            }
            break;
        default:
            break;
    }

    [super onUpdate:dt];
}

@end