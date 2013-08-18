//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "GameOverLayer.h"
#import "FightLayer.h"


@implementation GameOverLayer
+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    GameOverLayer *layer = [GameOverLayer node];

    [scene addChild: layer];
    return scene;
}

- (id)init
{
    self = [super initWithColor:ccc4(255, 255, 255, 255)];
    if (self) {
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Game Over"
                                               fontName:@"Arial"
                                               fontSize:32];
        label.color = ccc3(0, 0, 0);
        CGSize winSize = [CCDirector sharedDirector].winSize;
        label.position = ccp(winSize.width / 2, winSize.height / 2);
        [self addChild:label];

        [self runAction: [CCSequence actions:
                [CCDelayTime actionWithDuration:3],
                [CCCallBlockN actionWithBlock:^(CCNode *node) {
                    [[CCDirector sharedDirector] replaceScene:[FightLayer scene]];
                }],
                nil]];
    }
    return self;
}
@end