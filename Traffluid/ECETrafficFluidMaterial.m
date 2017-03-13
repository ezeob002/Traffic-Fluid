//
//  ECETrafficFluidMaterial.m
//  ECE595
//

#import "ECETrafficFluidMaterial.h"

@implementation ECETrafficFluidMaterial

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
    self.restDensity        = 998.29;
    self.particlesMass      = 0.02;
    self.supportRadius      = 0.0457;
    self.gassConstant       = 3.0;
    self.viscocityCoef      = 3.5;
    self.surfaceTensionCoef = 0.0728;
    self.deltaTime          = 0.0005;//0.01;
}

@end
