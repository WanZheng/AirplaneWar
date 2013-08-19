//
// Created by cos on 18/8/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Enemy.h"

#define kTextureScale (320.0f/480.0f)

@interface TextureConfig : NSObject
+ (TextureConfig *)instance;

- (NSArray *)framesForPlayerNormal;

- (NSArray *)framesForEnemy:(EnemyModel)model state:(EnemyState)state;
@end