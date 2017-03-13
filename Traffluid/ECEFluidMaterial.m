//
//  ECEFluidMaterial.m
//  ECE595
//

#import "ECEFluidMaterial.h"

@implementation ECEFluidMaterial

@synthesize restDensity, particlesMass, supportRadius, gassConstant, viscocityCoef, surfaceTensionCoef, deltaTime, fluidVolume, surfaceThreshold;

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
    restDensity        = 0;
    particlesMass      = 0;
    supportRadius      = 0;
    gassConstant       = 0;
    viscocityCoef      = 0;
    surfaceTensionCoef = 0.0728;
    surfaceThreshold   = 7.065;
    deltaTime          = 0.03;
    fluidVolume        = 0.25 * 0.05 * 0.25;
}

#pragma mark - Utils

@end
