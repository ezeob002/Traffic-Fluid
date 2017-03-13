//
//  ECETrafficParticle.h
//  ECE595
//

#import <Foundation/Foundation.h>
#import "ECEParticle.h"

@interface ECETrafficParticle : ECEParticle

/// The pressure force of the particle.
@property GLKVector3    internalForceAlongN;

/// The viscosity force of the particle.
@property GLKVector3    internalForceAlongT;

/// The viscosity force of the particle.
@property BOOL          enabled;

/// The
@property BOOL          draw;

- (void) setParticlePosition:(GLKVector3)_position;

- (void) setParticlePosition:(GLKVector3)_position andRadius:(float)radius;

- (void) drawInternalForceAlongN;

- (void) drawInternalForceAlongT;

@end
