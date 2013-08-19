//
// Created by cos on 19/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface MultiFrameSprite : CCSprite
@property (nonatomic, readonly) BOOL framesFinished;

- (void)setSingleFrame:(CCSpriteFrame *)frame;

// frames: array of CCSpriteFrame
- (void)setMultiFrame:(NSArray *)frames frequency:(CGFloat)frequency repeat:(BOOL)repeat;

- (void)onUpdate:(ccTime)delta;
@end