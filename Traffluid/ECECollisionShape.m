//
//  ECECollision.m
//  ECE595
//

#import "ECECollisionShape.h"

@implementation ECECollisionShape

/**
 * It initializes with default values all the members of this class.
 *
 * @param
 * @return
 */
-(id) init
{
    self = [super init];
    if (self)
    {
        [self resetInfo];
    }
    return self;
}

/**
 * It gives the default value to all the members in this class.
 *
 * @param
 * @return
 */
- (void) resetInfo
{

}

#pragma mark - Utils

/**
 * It handles the collision of the input particle with the collision shape.
 *
 * @param
 * @return
 */
- (void) handleCollisionFor:(ECEParticle*)particle
{

}

/**
 * It handles the collision of the input particle with the collision shape.
 *
 * @param
 * @return
 */
- (void) handleCollisionWithNOBounginFor:(ECEParticle*)particle
{

}

@end
