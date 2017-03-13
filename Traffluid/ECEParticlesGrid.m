//
//  ECEParticlesGrid.m
//  ECE595
//

#import "ECEParticlesGrid.h"

@implementation ECEParticlesGrid

@synthesize numberOfParticles;

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
    numberOfParticles = 0;
}

#pragma mark - Left To be Implemented by Child Classes

/**
 * It updates the grid with the particles positions found in input array "particles".
 *
 * @param particles     The particles which positions will update (refresh) the grid.
 * @return
 */
- (void) resetWithParticles:(NSMutableArray*)particles
{

}

/**
 * It returns an array with the nearest neighbours of input particle "particle" within the range defined by input "radius".
 *
 * @param particle     The particle which position the nearest neighbouts will be looked for.
 * @param radius       The range within the nearest neighbours will be looked for.
 * @return an array with the nearest neighbours of input particle "particle" within the range defined by input "radius".
 */
- (NSMutableArray*) findNearestNeighborsToPosition:(ECEParticle*)particle withRadius:(double)radius
{
    return nil;
}

- (void) removeParticle:(ECEParticle*)particle
{

}

#pragma mark - OpenGL

- (void) draw
{

}

@end
