//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FightLayer.h"
#import "PlayerSprite.h"
#import "EnemySprite.h"
#import "Projectile.h"
#import "GameOverLayer.h"
#import "SimpleAudioEngine.h"


@interface FightLayer()
@property (nonatomic) BOOL gameIsOver;

// player
@property (nonatomic) PlayerSprite *player;
@property (nonatomic) CGPoint playerPositionWhenTouchBegin;
@property (nonatomic) CGPoint touchBeganPosition;
@property (nonatomic) CGPoint touchMovedPosition;

// enemies
@property (nonatomic) NSMutableArray *enemies; // array of EnemySprite

// projectile
@property (nonatomic) Projectile *projectile;
@end

@implementation FightLayer

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    FightLayer *layer = [FightLayer node];

    [scene addChild: layer];
    return scene;
}

#pragma mark - init
- (id)init
{
    self = [super initWithColor:ccc4(255, 255, 255, 255)];
    if (self) {
        _player = [[PlayerSprite alloc] init];
        [self addChild:_player];
        _playerPositionWhenTouchBegin = self.player.position;

        _enemies = [NSMutableArray array];
    }
    return self;
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];

    [self setTouchEnabled:TRUE];

    [self schedule:@selector(produceEnemy) interval:1];
    [self schedule:@selector(onUpdate)];

    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
}

#pragma mark - game logic
- (void)onUpdate
{
    if (! self.gameIsOver) {
        [self detectCollision];
        [self shoot];
    }

    [self updatePlayer];
}

- (void)detectCollision
{
    CGRect playerBox = self.player.boundingBox;
    CGRect projectileBox = self.projectile.boundingBox;
    NSUInteger hitIndex = NSUIntegerMax;
    NSUInteger count = self.enemies.count;

    for (NSUInteger i=0; i<count; i++) {
        EnemySprite *enemy = [self.enemies objectAtIndex:i];
        CGRect enemyBox = enemy.boundingBox;
        if (CGRectIntersectsRect(enemyBox, playerBox)) {
            [self onGameOver];
            return;
        }

        if (hitIndex != NSUIntegerMax || self.projectile == nil) {
            continue;
        }
        if (CGRectIntersectsRect(enemyBox, projectileBox)) {
            hitIndex = i;
        }
    }

    if (hitIndex != NSUIntegerMax) {
        EnemySprite *enemy = [self.enemies objectAtIndex:hitIndex];
        if ([enemy onHitWithDamage:self.projectile.damage]) {
            [enemy removeFromParent];
            [self.enemies removeObjectAtIndex:hitIndex];
        }

        [self.projectile removeFromParent];
        self.projectile = nil;
    }
}

- (void)updatePlayer
{
    self.player.position = ccpAdd(self.playerPositionWhenTouchBegin,
            ccpSub(self.touchMovedPosition, self.touchBeganPosition));
}

- (void)produceEnemy
{
    EnemySize size = SMALL_PLANE;
    int hp = arc4random() % 5 + 1;

    EnemySprite *enemy = [[EnemySprite alloc] initWithSize:size hp:hp];
    [self addChild:enemy];
    [self.enemies addObject:enemy];

    int minDuration = 2;
    int maxDuration = 4;
    int actualDuration = (arc4random() % (maxDuration - minDuration)) + minDuration;

    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:actualDuration
                                               position:ccp(enemy.position.x, -enemy.contentSize.height/2)];
    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node){
        [node removeFromParentAndCleanup:YES];
        [self.enemies removeObject:node];
    }];
    [enemy runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

- (void)shoot
{
    if (self.projectile) {
        return;
    }

    self.projectile = [[Projectile alloc] init];
    self.projectile.position = ccp(self.player.position.x, self.player.position.y + self.player.contentSize.height/2);
    [self addChild:self.projectile];

    CGSize winSize = [CCDirector sharedDirector].winSize;
    ccTime actualDuration = 0.3;
    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:actualDuration
                                               position:ccp(self.projectile.position.x, winSize.height+self.projectile.contentSize.height/2)];
    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node){
        [node removeFromParentAndCleanup:YES];
        self.projectile = nil;
    }];
    [self.projectile runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

- (void)onGameOver
{
    if (self.gameIsOver) {
        return;
    }
    self.gameIsOver = TRUE;

    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameOverLayer scene]]];
}

#pragma mark - touch input
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.touchBeganPosition = [self convertTouchToNodeSpace:touch];
    self.touchMovedPosition = self.touchBeganPosition;

    self.playerPositionWhenTouchBegin = self.player.position;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.touchMovedPosition = [self convertTouchToNodeSpace:touch];
}

@end