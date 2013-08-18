//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FightLayer.h"
#import "PlayerSprite.h"
#import "EnemySprite.h"
#import "Bullet.h"
#import "GameOverLayer.h"
#import "SimpleAudioEngine.h"


@interface FightLayer()
@property (nonatomic) BOOL gameIsOver;
@property (nonatomic) BOOL mute;

// player
@property (nonatomic) PlayerSprite *player;
@property (nonatomic) CGPoint playerPositionWhenTouchBegin;
@property (nonatomic) CGPoint touchBeganPosition;
@property (nonatomic) CGPoint touchMovedPosition;

// enemies
@property (nonatomic) NSMutableArray *enemies; // array of EnemySprite

// bullet
@property (nonatomic) Bullet *bullet;

// background
//   TODO: 用两个sprite实现滚动背景。 有更好的方法吗?
@property (nonatomic) NSMutableArray *backgrounds; // Two CCSprint
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
        [self setupBackground];

        _player = [[PlayerSprite alloc] init];
        [self addChild:_player];
        _playerPositionWhenTouchBegin = self.player.position;

        _enemies = [NSMutableArray array];

        _mute = YES;
    }
    return self;
}

- (void)setupBackground {
    CGSize winSize = [CCDirector sharedDirector].winSize;

    self.backgrounds = [NSMutableArray arrayWithCapacity:2];
    for (int i=0; i<2; i++) {
        CCSprite *background = [CCSprite spriteWithFile:@"shoot_background.png" rect:CGRectMake(0, 75, 480, 852)];
        background.anchorPoint = ccp(0, 0);
        background.scale = winSize.width / background.contentSize.width;
        background.position = ccp(0, i * background.contentSize.height * background.scale);
        [self addChild:background];

        [self.backgrounds addObject:background];
    }
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];

    [self setTouchEnabled:TRUE];

    [self schedule:@selector(produceEnemy) interval:1];
    [self schedule:@selector(onUpdate)];

    if (! self.mute) {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"game_music.mp3"];
    }
}

#pragma mark - game logic
- (void)onUpdate
{
    if (! self.gameIsOver) {
        [self detectCollision];
        [self shoot];
    }

    [self updatePlayer];

    [self scrollBackground];
}

- (void)detectCollision
{
    CGRect playerBox = self.player.boundingBox;
    CGRect bulletBox = self.bullet.boundingBox;
    NSUInteger hitIndex = NSUIntegerMax;
    NSUInteger count = self.enemies.count;

    for (NSUInteger i=0; i<count; i++) {
        EnemySprite *enemy = [self.enemies objectAtIndex:i];
        CGRect enemyBox = enemy.boundingBox;
        if (CGRectIntersectsRect(enemyBox, playerBox)) {
            [self onGameOver];
            return;
        }

        if (hitIndex != NSUIntegerMax || self.bullet == nil) {
            continue;
        }
        if (CGRectIntersectsRect(enemyBox, bulletBox)) {
            hitIndex = i;
        }
    }

    if (hitIndex != NSUIntegerMax) {
        EnemySprite *enemy = [self.enemies objectAtIndex:hitIndex];
        if ([enemy onHitWithDamage:self.bullet.damage]) {
            [enemy removeFromParent];
            [self.enemies removeObjectAtIndex:hitIndex];
        }

        [self.bullet removeFromParent];
        self.bullet = nil;
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
    if (self.bullet) {
        return;
    }

    self.bullet = [[Bullet alloc] init];
    self.bullet.position = ccp(self.player.position.x, self.player.position.y + self.player.contentSize.height/2);
    [self addChild:self.bullet];

    CGSize winSize = [CCDirector sharedDirector].winSize;
    ccTime actualDuration = 0.3;
    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:actualDuration
                                               position:ccp(self.bullet.position.x, winSize.height+self.bullet.contentSize.height/2)];
    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node){
        [node removeFromParentAndCleanup:YES];
        self.bullet = nil;
    }];
    [self.bullet runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];

    if (! self.mute) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"bullet.mp3"];
    }
}

- (void)scrollBackground {
    for (CCSprite *background in self.backgrounds) {
        CGFloat y = background.position.y;
        y -= 1;
        if (y < -background.boundingBox.size.height) {
            y += 2 * background.boundingBox.size.height;
        }
        background.position = ccp(0, y);
    }
}

- (void)onGameOver
{
    if (self.gameIsOver) {
        return;
    }
    self.gameIsOver = TRUE;

    if (! self.mute) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"game_over.mp3"];
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    }
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