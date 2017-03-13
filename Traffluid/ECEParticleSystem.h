//
//  ECEParticleSystem.h
//  ECE 595
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ECEFluidMaterial.h"
#import "ECEParticle.h"

#define DEFAULT_PARTICLE_DENSITY         0.01

@interface ECEParticleSystem : NSObject
{
    /// Array that holds all the particles of the system.
    NSMutableArray* particles;
    
    /// Gravity vector of the system.
    GLKVector3 gravity;
}

/// Size of the spheres
@property CGFloat half_size_of_particles_sphere;

/// YES, if the simulation is pause. NO, otherwise.
@property BOOL isPause;

/// YES, if the density should be drawn. NO, otherwise.
@property BOOL drawDensity;

/// YES, if the grid should be drawn. NO, otherwise.
@property BOOL drawGrid;

/// The number of particles in the system.
@property NSInteger numberOfParticles;

/// The mass of the particles of the system.
@property float particleMass;

/// Color the particles will be drawn with.
@property GLKVector4 particlesColor;

/// The initial position of the particles.
@property  GLKVector3 particlesInitialPosition;

/// The initial velocity of the particles.
@property  GLKVector3 particlesInitialVelocity;

/// A object that holds the phisical parameters of the fluid to be simulated.
@property  ECEFluidMaterial* fluidMaterial;

- (void) resetInfo;

- (void) setParticlesInitialPositionsInAGrid;

- (void) createParticlesInGridInContainerSize:(GLKVector3)boxSize;

- (void) draw;

- (void) update;

- (void) addGravity;

- (void) removeParticles;

- (void) computeDensityOfParticle:(ECEParticle*)particle
                fromItsNeighbours:(NSMutableArray*)neighbours;

- (void) handleDebugModesForParticle:(ECEParticle*)particle
                       andNeighbours:(NSMutableArray*) neighbours;

- (ECEParticle*) rayIntersectsParticle:(GLKVector3)rayDirection andRayCenter:(GLKVector3)rayCenter;

@end
