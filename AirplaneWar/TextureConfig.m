//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TextureConfig.h"

@interface TextureConfig()
@property (nonatomic) CCTexture2D *texture;
@end

@implementation TextureConfig
+ (TextureConfig *)instance {
    static TextureConfig *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _texture = [[CCTextureCache sharedTextureCache] addImage:@"shoot.png"];
    }
    return self;
}

- (NSArray *)framesForPlayerNormal {
    static NSArray *frames;
    if (frames == nil) {
        frames = [NSArray arrayWithObjects:
                [CCSpriteFrame frameWithTexture:self.texture rect:CGRectMake(0, 99, 102, 126)],
                [CCSpriteFrame frameWithTexture:self.texture rect:CGRectMake(165, 360, 102, 126)],
                nil];
    }
    return frames;
}

- (CCSpriteFrame *)frameWithRect:(CGRect)rect {
    return [CCSpriteFrame frameWithTexture:self.texture rect:rect];
}

- (NSArray *)framesForEnemy:(EnemyModel)model state:(EnemyState)state {
    switch (model) {
        case kEnemyModel1:
            switch (state) {
                case kEnemyStateDown:
                {
                    static NSArray *frames;
                    if (frames == nil) {
                        frames = [NSArray arrayWithObjects:
                                [self frameWithRect:CGRectMake(267, 347, 57, 51)],
                                [self frameWithRect:CGRectMake(873, 697, 57, 51)],
                                [self frameWithRect:CGRectMake(267, 296, 57, 51)],
                                [self frameWithRect:CGRectMake(930, 69, 57, 51)],
                                nil];
                    }
                    return frames;
                }
                default:
                {
                    static NSArray *frames;
                    if (frames == nil) {
                        frames = [NSArray arrayWithObject:
                                [self frameWithRect:CGRectMake(534, 612, 57, 43)]];
                    }
                    return frames;
                }
            }

        case kEnemyModel2:
            switch (state) {
                case kEnemyStateDown:
                {
                    static NSArray *frames;
                    if (frames == nil) {
                        frames = [NSArray arrayWithObjects:
                                [self frameWithRect:CGRectMake(534, 655, 69, 95)],
                                [self frameWithRect:CGRectMake(603, 655, 69, 95)],
                                [self frameWithRect:CGRectMake(672, 653, 69, 95)],
                                [self frameWithRect:CGRectMake(741, 653, 69, 95)],
                                nil];
                    }
                    return frames;
                }
                case kEnemyStateHit:
                {
                    static NSArray *frames;
                    if (frames == nil) {
                        frames = [NSArray arrayWithObject:
                                [self frameWithRect:CGRectMake(432, 525, 69, 99)]];
                    }
                    return frames;
                }
                default:
                {
                    static NSArray *frames;
                    if (frames == nil) {
                        frames = [NSArray arrayWithObject:
                                [self frameWithRect:CGRectMake(0, 0, 69, 99)]];
                    }
                    return frames;
                }
            }

        case kEnemyModel3:
            switch (state) {
                case kEnemyStateDown:
                {
                    static NSArray *frames;
                    if (frames == nil) {
                        frames = [NSArray arrayWithObjects:
                                [self frameWithRect:CGRectMake(0, 486, 165, 261)],
                                [self frameWithRect:CGRectMake(0, 225, 165, 261)],
                                [self frameWithRect:CGRectMake(839, 748, 165, 260)],
                                [self frameWithRect:CGRectMake(165, 486, 165, 261)],
                                [self frameWithRect:CGRectMake(673, 748, 166, 260)],
                                [self frameWithRect:CGRectMake(0, 747, 166, 261)],
                                nil];
                    }
                    return frames;
                }
                case kEnemyStateNormal:
                {
                    static NSArray *frames;
                    if (frames == nil) {
                        frames = [NSArray arrayWithObjects:
                                [self frameWithRect:CGRectMake(335, 750, 169, 258)],
                                [self frameWithRect:CGRectMake(504, 750, 169, 258)],
                                nil];
                    }
                    return frames;
                }
                case kEnemyStateHit:
                default:
                {
                    static NSArray *frames;
                    if (frames == nil) {
                        frames = [NSArray arrayWithObject:
                                [self frameWithRect:CGRectMake(166, 750, 169, 258)]];
                    }
                    return frames;
                }
            }

        default:
            NSAssert(NO, @"Unkown model");
            return nil;
    }
}

@end