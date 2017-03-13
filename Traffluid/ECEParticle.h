//
//  ECEParticle.h
//  ECE 595
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ECESphere.h"

@interface ECEParticle : NSObject

/// The ID of the particle.
@property NSInteger    particleID;

/// The position of the particle.
@property GLKVector3    position;

/// The velocity of the particle.
@property GLKVector3    velocity;

/// The acceleration of the particle.
@property GLKVector3    acceleration;

/// The pressure of the particle.
@property float         pressure;

/// The density of the particle.
@property float         density;

/// The pressure force of the particle.
@property GLKVector3    pressureForce;

/// The viscosity force of the particle.
@property GLKVector3    viscosityForce;

/// The surface tension force of the particle.
@property GLKVector3    surfaceTensionForce;

/// The normal of the particle.
@property GLKVector3    normal;

/// This cube will represent the particle in OpenGL.
@property ECESphere* cube;

/// Radius of the sphere that will be draw to represent this particle.
@property float sphereRadius;

/// Color the particle will be drawn with.
@property GLKVector4 particleColor;

/// The support radius of the particle.
@property float   supportRadius;

/// Color the particle will be drawn with as a secondary option.
@property GLKVector4 secondaryParticleColor;

/// Color the particle will be drawn with as a secondary option.
@property int numOfNeighbours;

- (void) resetInfo;

- (void) draw;

- (void) drawVelocity;

- (void) drawArrowFrom:(GLKVector3)origin to:(GLKVector3)destination;

- (void) update:(double)deltaTime;

- (void) setParticlePosition:(GLKVector3)_position;

- (void) setParticlePosition:(GLKVector3)_position andRadius:(float)radius;

- (void) setTheParticleColor:(GLKVector4)_color;

- (void) resetSecondaryColor;

@end
