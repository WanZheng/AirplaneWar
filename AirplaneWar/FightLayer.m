//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "FightLayer.h"
#import "Player.h"
#import "Enemy.h"
#import "Bullet.h"
#import "GameOverLayer.h"
#import "SimpleAudioEngine.h"

const int kZOrderBackground = 0;
const int kZOrderBullet = 20;
const int kZOrderEnemy = 30;
const int kZOrderPlayer = 40;
const int kZOrderScoreLabel = 50;

@interface FightLayer()
@property (nonatomic) BOOL gameIsOver;
@property (nonatomic) BOOL mute;

// player
@property (nonatomic) Player *player;
@property (nonatomic) CGPoint playerPositionWhenTouchBegin;
@property (nonatomic) CGPoint touchBeganPosition;
@property (nonatomic) CGPoint touchMovedPosition;

// enemies
@property (nonatomic) NSMutableArray *enemies; // array of Enemy

// bullet
@property (nonatomic) Bullet *bullet;

// score
@property (nonatomic) int score;
@property (nonatomic) CCLabelBMFont *scoreLabel;

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

        _player = [[Player alloc] init];
        _player.zOrder = kZOrderPlayer;
        CGSize winSize = [CCDirector sharedDirector].winSize;
        _player.position = ccp(winSize.width/2, 10 + _player.contentSize.height/2);
        [self addChild:_player];
        _playerPositionWhenTouchBegin = self.player.position;

        _enemies = [NSMutableArray array];

        [self setupScoreLabel];

        _mute = YES;
    }
    return self;
}

- (void)setupScoreLabel {
    CGSize winSize = [CCDirector sharedDirector].winSize;

    _scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"font.fnt"];
    _scoreLabel.color = ccc3(50, 50, 50);
    _scoreLabel.opacity = 128;
    _scoreLabel.alignment = kCCTextAlignmentLeft;
    _scoreLabel.zOrder = kZOrderScoreLabel;
    _scoreLabel.scale = 0.4f;
    _scoreLabel.anchorPoint = ccp(0, 0);
    _scoreLabel.position = ccp(20, winSize.height - _scoreLabel.contentSize.height - 20);

    [self addChild:_scoreLabel];
}

- (void)setupBackground {
    CGSize winSize = [CCDirector sharedDirector].winSize;

    self.backgrounds = [NSMutableArray arrayWithCapacity:2];
    for (int i=0; i<2; i++) {
        CCSprite *background = [CCSprite spriteWithFile:@"shoot_background.png" rect:CGRectMake(0, 75, 480, 852)];
        background.zOrder = kZOrderBackground;
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
    [self schedule:@selector(onUpdate:)];

    if (! self.mute) {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"game_music.mp3"];
    }
}

#pragma mark - game logic
- (void)onUpdate:(ccTime)dt
{
    // collision and shoot
    if (! self.gameIsOver) {
        [self detectCollision];
        [self shoot];
    }

    // enemy
    NSMutableArray *diedEnemy = [NSMutableArray array];
    for (Enemy *enemy in self.enemies) {
        if (! enemy.died) {
            [enemy onUpdate:dt];
            continue;
        }

        self.score += enemy.score;
        self.scoreLabel.string = [NSString stringWithFormat:@"%d", self.score];

        [enemy removeFromParent];
        [diedEnemy addObject:enemy];
    }
    for (Enemy *enemy in diedEnemy) {
        [self.enemies removeObject:enemy];
    }

    // player
    [self updatePlayer:dt];

    // background
    [self scrollBackground];
}

- (void)detectCollision
{
    CGRect playerBox = self.player.boundingBox;
    // 撞了机翼没事
    playerBox.origin.x += playerBox.size.width / 4;
    playerBox.size.width /= 2;

    CGRect bulletBox = self.bullet.boundingBox;
    NSUInteger hitIndex = NSUIntegerMax;
    NSUInteger count = self.enemies.count;

    for (NSUInteger i=0; i<count; i++) {
        Enemy *enemy = [self.enemies objectAtIndex:i];
        if (enemy.state >= kEnemyStateDown) {
            continue;
        }

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
        Enemy *enemy = [self.enemies objectAtIndex:hitIndex];
        [enemy didHitWithDamage:self.bullet.damage];

        [self.bullet removeFromParent];
        self.bullet = nil;
    }
}

- (void)updatePlayer:(ccTime)dt {
    self.player.position = ccpAdd(self.playerPositionWhenTouchBegin,
            ccpSub(self.touchMovedPosition, self.touchBeganPosition));
    [self.player onUpdate:dt];
}

- (void)produceEnemy
{
    EnemyModel model = (EnemyModel) (arc4random() % kNumberOfEnemyModel);

    Enemy *enemy = [Enemy enemyWithModel:model];
    enemy.zOrder = kZOrderEnemy;

    [self addChild:enemy];
    [self.enemies addObject:enemy];

    CGSize winSize = [CCDirector sharedDirector].winSize;
    int x = (int)((arc4random() % (int)(winSize.width - enemy.contentSize.width)) + enemy.contentSize.width/2);
    enemy.position = ccp(x, winSize.height + enemy.contentSize.height/2);

    int minDuration = 3;
    int maxDuration = 5;
    int actualDuration = (arc4random() % (maxDuration - minDuration)) + minDuration;

    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:actualDuration
                                               position:ccp(enemy.position.x, -enemy.contentSize.height/2)];
    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node){
        [node removeFromParentAndCleanup:YES];
        [self.enemies removeObject:node];
    }];
    CCAction *action = [CCSequence actions:actionMove, actionMoveDone, nil];
    action.tag = 1;
    [enemy runAction:action];
}

- (void)shoot
{
    if (self.bullet) {
        return;
    }

    self.bullet = [[Bullet alloc] init];
    self.bullet.zOrder = kZOrderBullet;
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