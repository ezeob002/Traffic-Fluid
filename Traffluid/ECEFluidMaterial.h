//
//  ECEFluidMaterial.h
//  ECE595
//

#import <Foundation/Foundation.h>

@interface ECEFluidMaterial : NSObject

/// The density of the fluid in rest in Kg/m^3.
@property double restDensity;

/// The mss of each particle of the fluid in Kg.
@property double particlesMass;

/// The support radius for the kernels in m.
@property double supportRadius;

/// The gass stiffness constant of the fluid in J.
@property double gassConstant;

/// The viscosity coeficient of the fluid in Pa * s.
@property double viscocityCoef;

/// The surface tension coeficient of the fluid in N / m.
@property double surfaceTensionCoef;

/// The threshold used to calculate the surface tension for the particles.
@property double surfaceThreshold;

/// The delta time for the fluid simulation.
@property double deltaTime;

/// The volumne of the fluid.
@property double fluidVolume;

- (void) resetInfo;

@end
