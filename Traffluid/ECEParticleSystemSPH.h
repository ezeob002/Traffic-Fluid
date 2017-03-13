//
//  ECEParticleSystemSPH.h
//  ECE 595
//

#import <Foundation/Foundation.h>
#import "ECEParticleSystem.h"
#import "ECECollisionShape.h"

@interface ECEParticleSystemSPH : ECEParticleSystem

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

@end
