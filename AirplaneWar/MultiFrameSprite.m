//
// Created by cos on 19/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "MultiFrameSprite.h"


@interface MultiFrameSprite()
@property (nonatomic) BOOL isMultiFrame;
@property (nonatomic) NSArray *frames; // array of CCSpriteFrame
@property (nonatomic) NSUInteger index;
@property (nonatomic) ccTime delta;
@property (nonatomic) ccTime updateInterval;
@property (nonatomic) BOOL repeat;
@property (nonatomic, strong) void (^finishBlock)(MultiFrameSprite *);
@property (nonatomic) BOOL finished;
@end

@implementation MultiFrameSprite
- (void)setSingleFrame:(CCSpriteFrame *)frame {
    self.frames = nil;
    self.finishBlock = nil;

    self.isMultiFrame = NO;
    self.finished = NO;

    [self setDisplayFrame:frame];
}

- (void)setMultiFrame:(NSArray *)frames frequency:(CGFloat)frequency repeat:(BOOL)repeat finishBlock:(void (^)(MultiFrameSprite *))finishBlock {
    NSAssert(frequency > 0, @"invalid argument");
    NSAssert(frames.count > 1, @"invalid argument");

    self.frames = frames;
    self.updateInterval = 1.0f / frequency;
    self.repeat = repeat;
    self.finishBlock = finishBlock;

    self.isMultiFrame = YES;
    self.finished = NO;
    self.delta = 0;
    self.index = 0;

    [self setDisplayFrame:frames[0]];
}

- (void)onUpdate:(ccTime)delta {
    if (!self.isMultiFrame || self.finished) {
        return;
    }

    self.delta += delta;
    if (self.delta < self.updateInterval) {
        return;
    }

    NSUInteger oldIndex = self.index;
    while (self.delta >= self.updateInterval) {
        self.index ++;
        self.delta -= self.updateInterval;
    }

    if (!self.repeat && self.index >= self.frames.count) {
        [self.finishBlock self];
        return;
    }

    self.index %= self.frames.count;
    if (oldIndex != self.index) {
        [self setDisplayFrame:self.frames[self.index]];
    }
}

@end