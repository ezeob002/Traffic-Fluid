//
//  ECEParticleSystemSPH.m
//  ECE 595
//

#import "ECEParticleSystemSPH.h"
#import "ECEKernels.h"
#import "ECEParticle.h"
#import "ECEGridHashTable.h"
#import "ECEParticlesGrid.h"
#import "ECEFluidMaterial.h"
#import "ECEGlobal.h"
#import "ECEWaterFluidMaterial.h"
#import "ECELeapFrogIntegrator.h"
#import "ECESphere.h"

#import <OpenCL/OpenCL.h>

#define DEFAULT_CORE_RADIUS      0.2
#define DEFAULT_PARTICLE_DENSITY 0.01
#define GAS_CONSTANT_K           1.0

@interface ECEParticleSystemSPH ()
{
    /// Grid defined by the particles. This grid will be used to perform find-nearest-neighbours algorithms.
    ECEParticlesGrid *grid;
    
    /// The ID of the next particle to be created.
    NSInteger nextParticleToCreateID;
    
    /// The shape where the fluid can be contained.
    ECECollisionShape* collisionShape;
    
    /// YES, if all the particles have been created already. NO, otherwise.
    BOOL particlesAlreadyCreated;
}

- (void) computePressureOfParticle:(ECEParticle*)particle;

- (void) computePressureForceOverParticle:(ECEParticle*)particle
                        fromItsNeighbours:(NSMutableArray*)neighbours;

- (void) computeViscosityForceOverParticle:(ECEParticle*)particle
                         fromItsNeighbours:(NSMutableArray*)neighbours;

- (void) computeSurfaceTensionForParticle:(ECEParticle*)particle
                            andNeighbours:(NSMutableArray*)neighbours;

@end

@implementation ECEParticleSystemSPH

@synthesize fluidMaterial;

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
    [super resetInfo];
    
    // Setting water as the fluid material of the simulation.
    fluidMaterial = [[ECEFluidMaterial alloc] init];
    nextParticleToCreateID   = 0;
    collisionShape = [[ECECollisionShape alloc] init];
    particlesAlreadyCreated = NO;
    
    // Creating the grid. Here we use a Hash Table.
    grid = [[ECEGridHashTable alloc] initWithNumberOfParticles:self.numberOfParticles andFluidMaterial:fluidMaterial];
    
    // Setting some particle properties based on the fluid material chosen.
    for (int i=0; i<[particles count]; i++)
        ((ECEParticle*)particles[i]).density = DEFAULT_PARTICLE_DENSITY;
}

#pragma mark - Inits

/**
 * It generates the grid that will be used to perform find-nearest-neighbours.
 *
 * @param
 * @return
 */
- (void) generateGrid
{
    // Refreshing hash table.
    [grid resetWithParticles:particles];
}

/**
 * It returns the delta time of the fluid material set for this system.
 *
 * @param
 * @return
 */
- (double) getDeltaTime
{
    return fluidMaterial.deltaTime;
}

/**
 * It create a certain number of particles given by input "numOfPartclesToCreatePerDeltaTime" by using the initial position and velocity.
 *
 * @param numOfPartclesToCreatePerDeltaTime   The number of particles to be created.
 * @return
 */
- (void) createMoreParticles:(NSInteger)numOfPartclesToCreatePerDeltaTime
{
    if ( ! particlesAlreadyCreated)
    {
        double rangeOfPositioning;
        
        // init
        rangeOfPositioning = 0.25 * (1.0 / 50.0);
        if ([particles count] < self.numberOfParticles)
            numOfPartclesToCreatePerDeltaTime = MIN(10, self.numberOfParticles - [particles count]);
        
        for (int i=0; i<numOfPartclesToCreatePerDeltaTime; i++)
        {
            ECEParticle* particle;
            GLKVector3 particlePosition;
            
            // init
            particle = [[ECEParticle alloc] init];
            
            // Setting particle id.
            [particle setParticleID:nextParticleToCreateID];
            
            // Creating a position for the particle based on the initial position of the system.
            particlePosition = GLKVector3Make([ECEGlobal getRandomNumberBetween:-50 to:50] *rangeOfPositioning + self.particlesInitialPosition.x,
                                              [ECEGlobal getRandomNumberBetween:-50 to:50] * rangeOfPositioning + self.particlesInitialPosition.y,
                                              [ECEGlobal getRandomNumberBetween:-50 to:50] * rangeOfPositioning + self.particlesInitialPosition.z);
            
            // Set particle position
            particle.position = particlePosition;
            
            // Set particle velocity
            particle.velocity = self.particlesInitialVelocity;
            
            // Set particle density
            particle.density = DEFAULT_PARTICLE_DENSITY;
            
            // Setting particle color
            if (([ECEGlobal getRandomNumberBetween:0 to:100]) <= 30)
                particle.particleColor = GREEN_COLOR;
            else if (([ECEGlobal getRandomNumberBetween:0 to:100]) <= 30)
                particle.particleColor = RED_COLOR;
            else
                particle.particleColor = BLUE_COLOR;
            
            // Adding particle to the array of particles.
            [particles addObject:particle];
            
            nextParticleToCreateID++;
        }
    }
}

/**
 * It creates and position particles in a grid inside the container box given by input boxSize;
 *
 * @param numOfPartclesToCreatePerDeltaTime   The number of particles to be created.
 * @return
 */
- (void) createParticlesInGridInContainerSize:(GLKVector3)boxSize
{
    if (nextParticleToCreateID == 0)
    {
        double step = self.half_size_of_particles_sphere;
        double offset = 2.0;
        
        for (double y = boxSize.y/2.0 - 2 * step; y > - boxSize.y/2.0 - 2 * step; y-= self.half_size_of_particles_sphere  * offset)
        {
            for (double x = -boxSize.x/2.0 + 2 * step; x < boxSize.x/2.0 - 2 * step; x+= self.half_size_of_particles_sphere  * offset)
            {
                for (double z = -boxSize.z/2.0 + 2 * step; z < boxSize.z/2.0 - 2 * step; z+= self.half_size_of_particles_sphere * offset)
                {
                    if ([particles count] < self.numberOfParticles)
                    {
                        ECEParticle* particle;
                        GLKVector3 particlePosition;
                        double xx, yy, zz, cr;
                        
                        // init
                        particle = [[ECEParticle alloc] init];
                        cr = 0.0001;
                        xx = ([ECEGlobal getRandomNumberBetween:-50 to:50] / 50.0) * cr;
                        yy = ([ECEGlobal getRandomNumberBetween:-50 to:50] / 50.0) * cr;
                        zz = ([ECEGlobal getRandomNumberBetween:-50 to:50] / 50.0) * cr;
                        
                        // Setting particle id.
                        [particle setParticleID:nextParticleToCreateID];
                        
                        // Creating a position for the particle based on the initial position of the system.
                        particlePosition = GLKVector3Make(x + xx, y + yy, z + zz);
                        
                        // Set particle position
                        particle.position = particlePosition;
                        
                        // Set particle velocity
                        particle.velocity = self.particlesInitialVelocity;
                        
                        // Set particle density
                        particle.density = DEFAULT_PARTICLE_DENSITY;
                        
                        // Set particle's cube size.
                        particle.sphereRadius = self.half_size_of_particles_sphere;
                        
                        // Setting support radius
                        particle.supportRadius = fluidMaterial.supportRadius;
                        
                        // Setting particle color
                        if (([ECEGlobal getRandomNumberBetween:0 to:100]) <= 30)
                            particle.particleColor = GREEN_COLOR;
                        else if (([ECEGlobal getRandomNumberBetween:0 to:100]) <= 30)
                            particle.particleColor = RED_COLOR;
                        else
                            particle.particleColor = BLUE_COLOR;
                        
                        // Adding particle to the array of particles.
                        [particles addObject:particle];
                        
                        // Creating particle's cube
                        particle.cube = [[ECESphere alloc] initWithCenter:GLKVector3Make(0, 0, 0) andRadius:self.half_size_of_particles_sphere];
                        
                        nextParticleToCreateID++;
                        particlesAlreadyCreated = YES;
                    }
                }
            }
        }
    }
}

- (void) setTheFluidMaterial:(ECEFluidMaterial*)myfluidMaterial
{
    fluidMaterial = myfluidMaterial;
    
    // Creating the grid. Here we use a Hash Table.
    grid = [[ECEGridHashTable alloc] initWithNumberOfParticles:self.numberOfParticles andFluidMaterial:fluidMaterial];
}

- (void) setTheCollisionShape:(ECECollisionShape*)_collisionShape
{
    collisionShape = _collisionShape;
}

#pragma mark - Utils

/**
 * It computes the next state of the particle system in time.
 *
 * @param
 * @return
 */
- (void) update
{
    // Creating particles if necessary
    //if ([particles count] < self.numberOfParticles)
        //[self createMoreParticles:10];
    
    // Generating a new grid.
    [self generateGrid];
    
    // Computing accelerations for each particle
    [self computeAccelerations];
    
    if ( ! self.isPause)
    {
        for (int i=0; i<[particles count]; i++)
        {
            ECEParticle* particle;
            
            // Getting particle from array
            particle = particles[i];
            
            GLKVector3 newPosition;
            
            // Updating particle velocity
            particle.velocity = [ECELeapFrogIntegrator integrateVector:particle.acceleration withDeltaTime:fluidMaterial.deltaTime previousVectorValue:particle.velocity];
            
            // Updating particle position
            newPosition = [ECELeapFrogIntegrator integrateVector:particle.velocity withDeltaTime:fluidMaterial.deltaTime previousVectorValue:particle.position];
            
            // Updating particle position
            [particle setParticlePosition:newPosition];
            
            // Handling collisions with container
            if (collisionShape)
                [collisionShape handleCollisionFor:particle];
            
            // Floor collision handling
            if (newPosition.y <= 0)
            {
                 // Putting particle on the floor's surface
                 newPosition.v[1] = 0;
                 
                 // Changing velocity
                 particle.velocity.v[0] = particle.velocity.v[0] * 0.7;
                 particle.velocity.v[1] = particle.velocity.v[1] * 0.9 * (-1);
                 particle.velocity.v[2] = particle.velocity.v[2] * 0.7;
            }
        }
    }
}

/**
 * It jsut removes all the particles in the system.
 *
 * @param
 * @return
 */
- (void) removeParticles
{
    if (particles)
    {
        [particles removeAllObjects];
        nextParticleToCreateID = 0;
        particlesAlreadyCreated = NO;
        
        // Creating the grid. Here we use a Hash Table.
        grid = [[ECEGridHashTable alloc] initWithNumberOfParticles:self.numberOfParticles andFluidMaterial:fluidMaterial];
        
        // Setting some particle properties based on the fluid material chosen.
        for (int i=0; i<[particles count]; i++)
            ((ECEParticle*)particles[i]).density = DEFAULT_PARTICLE_DENSITY;
    }
}

#pragma mark - Physics

/**
 * It computes the acceleration of every particle in the system.
 *
 * @param
 * @return
 */
- (void) computeAccelerations
{
    // 1st cyle to calculate densities, pressures and nearest neighbours.
    for (int i=0; i<[particles count]; i++)
    {
        NSMutableArray* neighbours;
        ECEParticle *particle;
        
        // Getting current particle
        particle = particles[i];
        
        if (particle)
        {
            // Getting particle's neighbours
            [grid findNearestNeighborsToPosition:particle withRadius:fluidMaterial.supportRadius];
            neighbours = lastNeighbours;
            //neighbours = particles;
            
            // Handling debugging
            [self handleDebugModesForParticle:particle andNeighbours:neighbours];
            
            // Computing particle's density.
            [self computeDensityOfParticle:particle fromItsNeighbours:neighbours];
            
            // Computing particle's pressure.
            [self computePressureOfParticle:particle];
        }
    }
    
    // 2do cyle to calculate the forces.
    for (int i=0; i<[particles count]; i++)
    {
        NSMutableArray* neighbours;
        ECEParticle *particle;
        
        // Getting current particle
        particle = particles[i];
        
        if (particle)
        {
            GLKVector3 forces;
            
            // Getting particle's neighbours
            [grid findNearestNeighborsToPosition:particle withRadius:fluidMaterial.supportRadius];
            neighbours = lastNeighbours;
            //neighbours = particles;
            
            // Reseting forces to zero vector
            forces = GLKVector3Make(0.0, 0.0, 0.0);
            
            // Computing the pressure force acting over the particle.
            [self computePressureForceOverParticle:particle fromItsNeighbours:neighbours];
            
            // Computing the pressure force acting over the particle.
            [self computeViscosityForceOverParticle:particle fromItsNeighbours:neighbours];
            
            // Adding Surface Tension
            [self computeSurfaceTensionForParticle:particle andNeighbours:neighbours];
            
            // Adding the gravity force
            forces = GLKVector3Add(forces, GLKVector3MultiplyScalar(gravity, particle.density));
            
            // Adding the pressure force
            forces = GLKVector3Add(forces, particle.pressureForce);
            
            // Adding the viscosity force
            forces = GLKVector3Add(forces, particle.viscosityForce);
            
            // Adding surface tension force
            forces = GLKVector3Add(forces, [particle surfaceTensionForce]);
            
            // Dividing the sum of all the forces by the mass of the particle in order to get the final acceleration.
            particle.acceleration = GLKVector3DivideScalar(forces, particle.density);
        }
    }
}

/**
 * It calculates the density of the input particle "particle" by interpolating the densities of the particle's neighbours found in input "neighbours".
 *
 * @param particle      The particle which density will be calculated.
 * @param neighbours    The neighbours of the input particle.
 * @return
 */
- (void) computeDensityOfParticle:(ECEParticle*)particle
                fromItsNeighbours:(NSMutableArray*)neighbours
{
    double density;
    GLKVector3 diff;
    
    // init
    density = 0;
    
    for (int i=0; i<[neighbours count]; i++)
    {
        // Getting the substraction vector
        diff = GLKVector3Subtract(particle.position, ((ECEParticle*)neighbours[i]).position);
        
        // Getting density
        density += [ECEKernels usePolyKernel:diff];
    }
    
    particle.density = density * [fluidMaterial particlesMass];
}

/**
 * It calculates the pressure of the input particle "particle".
 *
 * @param particle      The particle which pressure will be calculated.
 * @return
 */
- (void) computePressureOfParticle:(ECEParticle*)particle
{
    particle.pressure = fluidMaterial.gassConstant * (particle.density - fluidMaterial.restDensity);
}

/**
 * It computes the pressure force that is acting over the input particle "particle".
 *
 * @param particle      The particle which pressure will be calculated.
 * @return
 */
- (void) computePressureForceOverParticle:(ECEParticle*)particle
                        fromItsNeighbours:(NSMutableArray*)neighbours
{
    GLKVector3 pressureForce, kernelPart, diff;
    double nonKernelPart;
    ECEParticle* neigh;
    
    // init
    pressureForce = GLKVector3Make(0, 0, 0);
    
    for (int i=0; i<[neighbours count]; i++)
    {
        // Getting neighbour i
        neigh = ((ECEParticle*)neighbours[i]);        
        
        if ([particle particleID] != [neigh particleID])
        {
            // Calculating the non-kernel part.
            //auxiliar = (particle.pressure + neigh.pressure) / (2 * neigh.density);
            nonKernelPart = (particle.pressure / (particle.density * particle.density)) +
                            (neigh.pressure    / (neigh.density * neigh.density));
            
            // Getting the position vector
            diff = GLKVector3Subtract(particle.position, neigh.position);
            
            // Getting gradient
            kernelPart = [ECEKernels useGradiantOfSpikyKernel:diff];
            
            // Adding to pressure force
            pressureForce = GLKVector3Add(pressureForce, GLKVector3MultiplyScalar(kernelPart, nonKernelPart));
        }
    }
    
    // Setting calculated density to the particle.
    particle.pressureForce = GLKVector3MultiplyScalar(pressureForce, (- 1) * [fluidMaterial particlesMass] * [particle density]);
}

/**
 * It computes the viscosity force that is acting over the input particle "particle".
 *
 * @param particle      The particle which viscosity will be calculated.
 * @return
 */
- (void) computeViscosityForceOverParticle:(ECEParticle*)particle
                        fromItsNeighbours:(NSMutableArray*)neighbours
{
    GLKVector3 viscosityForce, diff;
    double distance, laplacian;
    GLKVector3 velocities;
    ECEParticle* neigh;
    
    // init
    distance = 0;
    viscosityForce = GLKVector3Make(0, 0, 0);
    
    for (int i=0; i<[neighbours count]; i++)
    {
        if ([particle particleID] != [neigh particleID])
        {
            // Getting neighbour i
            neigh = ((ECEParticle*)neighbours[i]);
            
            // Calculating distance between particles
            diff = GLKVector3Subtract(particle.position, neigh.position);
            
            // Getting gradient
            laplacian = [ECEKernels useLaplacianOfViscosityKernel:diff];
            
            // Calculating densities
            velocities = GLKVector3DivideScalar(GLKVector3Subtract(neigh.velocity, particle.velocity), (neigh.density));
            
            // Adding to pressure force
            viscosityForce = GLKVector3Add(viscosityForce, GLKVector3MultiplyScalar(velocities, laplacian));
        }
    }
    
    // Setting calculated density to the particle.
    particle.viscosityForce = GLKVector3MultiplyScalar(viscosityForce, [fluidMaterial particlesMass] * [fluidMaterial viscocityCoef]);
}

- (void) computeSurfaceTensionForParticle:(ECEParticle*)particle andNeighbours:(NSMutableArray*)neighbours
{
    GLKVector3 normal, diff;
    double tensionForceKernelPart, normalLength;
    ECEParticle* neigh;
    
    // init
    tensionForceKernelPart = 0;
    
    for (int i=0; i<[neighbours count]; i++)
    {
        // Getting neighbour i
        neigh = ((ECEParticle*)neighbours[i]);
        
        if ([particle particleID] != [neigh particleID])
        {
            // Getting the position vector
            diff = GLKVector3Subtract(particle.position, neigh.position);
            
            // Calculating color normal
            normal = GLKVector3Add(normal, GLKVector3DivideScalar([ECEKernels useGradiantOfPolyKernel:diff], [neigh density]));
            
            // Calculating part of the tension force
            tensionForceKernelPart += [ECEKernels useLaplacianOfPolyKernel:diff] / [neigh density];
        }
    }
    
    // Normal = normal * mass
    normal = GLKVector3MultiplyScalar(normal, [fluidMaterial particlesMass]);
    
    // normal = - normal (inward normal)
    [particle setNormal:GLKVector3MultiplyScalar(normal, -1)];
    
    // tensionForceKernelPart = tensionForceKernelPart * mass
    tensionForceKernelPart = tensionForceKernelPart * [fluidMaterial particlesMass];
    
    // Getting normal length
    normalLength = GLKVector3Length(normal);
    
    if (normalLength > [fluidMaterial surfaceThreshold])
        particle.surfaceTensionForce = GLKVector3DivideScalar(GLKVector3MultiplyScalar(normal, - [fluidMaterial surfaceTensionCoef]),
                                                              normalLength * tensionForceKernelPart);
    else
        particle.surfaceTensionForce = GLKVector3Make(0, 0, 0);
}

#pragma mark - openGL

- (void) draw
{
    [super draw];
    
    // Drawing grid.
    if (self.drawGrid)
        [grid draw];
}

@end
