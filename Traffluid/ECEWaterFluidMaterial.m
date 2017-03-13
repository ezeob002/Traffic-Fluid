//
//  ECEWaterFluidMaterial.m
//  ECE595
//

#import "ECEWaterFluidMaterial.h"

@implementation ECEWaterFluidMaterial

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
    super.restDensity        = 998.29;
    super.particlesMass      = 0.02;
    super.supportRadius      = 0.0457;
    super.gassConstant       = 3.0;
    super.viscocityCoef      = 3.5;
    super.surfaceTensionCoef = 0.0728;
    super.deltaTime          = 0.01;
}

@end
