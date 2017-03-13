//
//  ECETrafficSystem.h
//  ECE595
//

#import <Foundation/Foundation.h>
#import "ECEParticleSystem.h"
#import "ECECollisionShape.h"

@interface ECETrafficParticleSystem : ECEParticleSystem

@property BOOL drawInternalForceAlongN;

@property BOOL drawInternalForceAlongT;

/// The Average position of the particles.
@property GLKVector3 particlesAveragePosition;

- (void) resetInfo;

- (void) removeParticles;

- (void) draw;

- (void) update;

- (void) generateGrid;

- (void) createParticlesInGridInContainerSize:(GLKVector3)boxSize;

- (void) computeAccelerations;

- (void) setTheFluidMaterial:(ECEFluidMaterial*)myfluidMaterial;

- (void) setTheCollisionShape:(ECECollisionShape*)_collisionShape;

- (double) getDeltaTime;

- (void) addOneMoreParticle;

@end
