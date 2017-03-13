 //
//  ECETrafficSystem.m
//  ECE595
//

#import "ECETrafficParticleSystem.h"
#import "ECEParticlesGrid.h"
#import "ECEGridHashTable.h"
#import "ECELeapFrogIntegrator.h"
#import "ECECollisionOOBox.h"
#import "ECETrafficParticle.h"
#import "ECEKernels.h"
#import "ECESphere.h"
#import "ECEGlobal.h"
#import "ECEParticle.h"

#define NORMAL_VELOCITY_COEFICIENT_K     2.1
#define POSITION_COEFICIENT_K            2
#define TANGENT_VELOCITY_COEFICIENT_K    0.3
#define SPEED_LIMIT                      15

@interface ECETrafficParticleSystem ()
{
    /// Grid defined by the particles. This grid will be used to perform find-nearest-neighbours algorithms.
    ECEParticlesGrid *grid;
    
    /// The ID of the next particle to be created.
    NSInteger nextParticleToCreateID;
    
    /// The shape where the fluid can be contained.
    ECECollisionShape* collisionShape;
    
    /// The shape where the fluid can be contained.
    ECECollisionShape* collisionShape2;
    
    /// Box size of the container where the particles are
    GLKVector3 containerBoxSize;
    
    /// Damping force
    GLKVector3 dampingForce;
    
    /// YES, if all the particles have been created already. NO, otherwise.
    BOOL particlesAlreadyCreated;
    
    /// Normal vector
    GLKVector3 n;
    
    /// Tangent vector
    GLKVector3 t;
}

- (void) computeInternalForcesForParticle:(ECETrafficParticle*)particle
                            andNeighbours:(NSMutableArray*)neighbours;

- (void) computeSurfaceTensionForParticle:(ECEParticle*)particle
                            andNeighbours:(NSMutableArray*)neighbours;

@end

@implementation ECETrafficParticleSystem

@synthesize fluidMaterial, drawDensity, drawInternalForceAlongN, drawInternalForceAlongT, particlesAveragePosition;

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
    nextParticleToCreateID = 0;
    collisionShape = [[ECECollisionShape alloc] init];
    particlesAlreadyCreated = NO;
    drawInternalForceAlongN = YES;
    drawInternalForceAlongT = NO;
    n = GLKVector3Make(0, -1, 0);
    t = GLKVector3Make(1,  0, 0);
    
    // Creating the grid. Here we use a Hash Table.
    grid = [[ECEGridHashTable alloc] initWithNumberOfParticles:self.numberOfParticles andFluidMaterial:fluidMaterial];
    
    // Setting some particle properties based on the fluid material chosen.
    for (int i=0; i<[particles count]; i++)
        ((ECETrafficParticle*)particles[i]).density = DEFAULT_PARTICLE_DENSITY;
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
            ((ECETrafficParticle*)particles[i]).density = DEFAULT_PARTICLE_DENSITY;
    }
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
 * It creates and position particles in a grid inside the container box given by input boxSize;
 *
 * @param numOfPartclesToCreatePerDeltaTime   The number of particles to be created.
 * @return
 */
- (void) createParticlesInGridInContainerSize:(GLKVector3)boxSize
{
    containerBoxSize = boxSize;
    
    if (nextParticleToCreateID == 0)
    {
        double h = self.half_size_of_particles_sphere;
        int color = 0;
        int num_of_colors = 3;
        
        for (double y = boxSize.y/2.0 - 2 * h; y > - boxSize.y/2.0 - 2 * h; y -= h * 2.0)
        {        
            for (double x = -boxSize.x/2.0 + 2 * h; x < boxSize.x/2.0 - 2 * h; x += h * 2.0)
            {
//double x = 0;
                double z = 0;
                
                if ([particles count] < self.numberOfParticles)
                {
                    ECETrafficParticle* particle;
                    GLKVector3 particlePosition;
                    double velCoef = - 3.0;
                    
                    // init
                    particle = [[ECETrafficParticle alloc] init];
                    
                    // Setting particle id.
                    [particle setParticleID:nextParticleToCreateID];
                    
                    // Creating a position for the particle based on the initial position of the system.
                    particlePosition = GLKVector3Make(x, y, z);
                    
                    // Set particle position
                    particle.position = particlePosition;
                    
                    // Set particle velocity
                    particle.velocity = GLKVector3Make(0, velCoef * (1 + (((float)[ECEGlobal getRandomNumberBetween:1 to:10]) / 10.0)), 0);
                    
                    // Set particle density
                    particle.density = DEFAULT_PARTICLE_DENSITY;
                    
                    // Set particle's cube size.
                    particle.sphereRadius = self.half_size_of_particles_sphere;
                    
                    // Setting support radius
                    particle.supportRadius = fluidMaterial.supportRadius;
                    
                    // Setting particle color
                    int colorID = color % num_of_colors;
                    color++;
                    
                    if (PARTICLE_TO_TEST_ID >= 0)
                    {
                        // ONLY for debugging: drawing all the particles black except the one selected for testing.
                        if (particle.particleID == PARTICLE_TO_TEST_ID)
                            particle.particleColor = RED_COLOR;
                        else
                            particle.particleColor = BLACK_COLOR;
                    }
                    else
                    {
                        if (colorID == 0)
                            particle.particleColor = GREEN_COLOR;
                        else if (colorID == 1)
                            particle.particleColor = RED_COLOR;
                        else if (colorID == 2)
                            particle.particleColor = BLUE_COLOR;
                    }
                    
                    // Adding particle to the array of particles.
                    [particles addObject:particle];
                    
                    // Creating particle's sphere
                    particle.cube = [[ECESphere alloc] init];
                    
                    nextParticleToCreateID++;
                    particlesAlreadyCreated = YES;
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
    
    collisionShape2 = [[ECECollisionOOBox alloc] initWithCenter:GLKVector3Make(0, 0, 0) axisU:GLKVector3Make(1, 0, 0) axisV:GLKVector3Make(0, 1, 0) axisW:GLKVector3Make(0, 0, 1) halfU:containerBoxSize.x * 0.2 halfV:containerBoxSize.y * 0.2 halfW:containerBoxSize.z * 0.5];
}

- (NSMutableArray*) getNeighboursAlongNFromArray:(NSMutableArray*)neighbours
                                     andParticle:(ECEParticle*)particle
{
    NSMutableArray* r;
    float length;
    
    // init
    r = [[NSMutableArray alloc] init];
    length = GLKVector3Length(n);
    
    for (int i=0; i<[neighbours count]; i++)
    {
        if (GLKVector3DotProduct([((ECEParticle*)neighbours[i]) position], [particle position]) == length)
        {
            [r addObject:neighbours[i]];
        }
    }
        
    return r;
}

#pragma mark - Utils

/**
 * It adds a default gravity force to the system.
 *
 * @param
 * @return
 */
- (void) addGravity
{
    [super addGravity];
    
    dampingForce = GLKVector3Make(0, (-1) * 0.99 * gravity.y, 0);
}

- (void) addOneMoreParticle
{
     ECECollisionOOBox* ooBox;
    
     ooBox = (ECECollisionOOBox*) collisionShape;
    
     if(ooBox)
     {
         double aux    = (2 * ooBox.halfU) / fluidMaterial.supportRadius;
         double offset = [ECEGlobal getRandomNumberBetween:0 to:aux] * fluidMaterial.supportRadius;
         
         double x =  (ooBox.center.x - ooBox.halfU) + fluidMaterial.supportRadius + offset;
         double y =  (ooBox.center.y + ooBox.halfV) - fluidMaterial.supportRadius;
         double z = 0;
                 
         ECETrafficParticle* particle;
         GLKVector3 particlePosition;
         
         // init
         particle = [[ECETrafficParticle alloc] init];
         
         // Setting particle id.
         [particle setParticleID:nextParticleToCreateID];
         
         // Creating a position for the particle based on the initial position of the system.
         particlePosition = GLKVector3Make(x, y, z);
         
         // Set particle position
         particle.position = particlePosition;
         
         // Set particle velocity
         particle.velocity = self.particlesInitialVelocity;
         
         // Set particle density
         particle.density = DEFAULT_PARTICLE_DENSITY;
         
         // Set particle's cube size.
         particle.sphereRadius = self.half_size_of_particles_sphere;
         
         // Setting particle color
         int colorID = [ECEGlobal getRandomNumberBetween:0 to:100];
         if (colorID < 33)
             particle.particleColor = ORANGE_COLOR;
         else if (colorID < 66)
             particle.particleColor = RED_COLOR;
         else if (colorID < 100)
             particle.particleColor = BLUE_COLOR;
         
         // Adding particle to the array of particles.
         [particles addObject:particle];
         
         // Creating particle's cube
         particle.cube = [[ECESphere alloc] init];
         
         nextParticleToCreateID++;
         particlesAlreadyCreated = YES;
     }
}

#pragma mark - Physics

/**
 * It computes the next state of the particle system in time.
 *
 * @param
 * @return
 */
- (void) update
{
    // Creating particles if necessary
    /* if ([particles count] < self.numberOfParticles)
    {
        if ([ECEGlobal getRandomNumberBetween:0 to:100] < 8)
            [self addOneMoreParticle];
    }*/
    
    // Generating a new grid.
    [self generateGrid];
    
    // Computing accelerations for each particle
    [self computeAccelerations];
    
    if ( ! self.isPause)
    {
        // init average position
        particlesAveragePosition = GLKVector3Make(0, 0, 0);
        
        for (int i=0; i<[particles count]; i++)
        {
            ECETrafficParticle* particle;
            
            // Getting particle from array
            particle = particles[i];
            
            if ([particle enabled])
            {
                GLKVector3 newPosition;
                
                // Updating particle velocity with Implicit Euler
                particle.velocity = GLKVector3Add(particle.velocity, GLKVector3MultiplyScalar(particle.acceleration, fluidMaterial.deltaTime));
                
                // Updating particle position
                newPosition = GLKVector3Add(particle.position, GLKVector3MultiplyScalar(particle.velocity, fluidMaterial.deltaTime));
                
                // Updating particle position
                [particle setParticlePosition:newPosition andRadius:fluidMaterial.supportRadius * 0.5];
                
                // Calculating average position of particles
                particlesAveragePosition = GLKVector3Add(particlesAveragePosition, newPosition);
                
                // Floor collision handling
                if ([collisionShape isKindOfClass:[ECECollisionOOBox class]])
                {
                    GLKVector3 aux;
                    
                    // Getting the vector down.
                    aux = GLKVector3MultiplyScalar(((ECECollisionOOBox*)collisionShape).v, ((ECECollisionOOBox*)collisionShape).halfV);
                    
                    if (newPosition.y <= ((ECECollisionOOBox*)collisionShape).center.y - aux.y)
                    {
                        // Putting particle on the floor's surface
                        newPosition.v[1] = ((ECECollisionOOBox*)collisionShape).center.y - aux.y;
                        
                        // Changing velocity
                        particle.velocity = GLKVector3MultiplyScalar(particle.velocity, 0);
                        
                        // Removing particle from the particles array
                        [particles removeObject:particle];
                        [grid removeParticle:particle];
                    }
                }
                
                // Handling collisions with container
                if (collisionShape)
                    [collisionShape handleCollisionWithNOBounginFor:particle];
                
                //if (collisionShape2)
                   // [collisionShape2 handleOutsideCollisionFor:particle];
            }
        }
        
        // Calculating average position of particles
        particlesAveragePosition = GLKVector3DivideScalar(particlesAveragePosition, [particles count]);
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
    // 1ST CYCLE: Calculating densities, pressures and nearest neighbours.
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
    
    // 2ND CYCLE: Calculating the forces.
    for (int i=0; i<[particles count]; i++)
    {
        NSMutableArray* neighbours;
        ECETrafficParticle *particle;
        
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
            
            // Computing particle's internal forces
            [self computeInternalForcesForParticle:particle andNeighbours:neighbours];
            
            // Adding Surface Tension
            [self computeSurfaceTensionForParticle:particle andNeighbours:neighbours];
            
            // Adding the internal forces
            forces = GLKVector3Add(forces, particle.internalForceAlongN);
            forces = GLKVector3Add(forces, particle.internalForceAlongT);
            
            // Checking if speed is above the speed limit
            if (ABS(particle.velocity.y) > SPEED_LIMIT)
                forces = GLKVector3Add(forces, dampingForce);
                
            // Adding the gravity force
            forces = GLKVector3Add(forces, GLKVector3MultiplyScalar(gravity, particle.density));
            
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
    particle.pressure = fluidMaterial.gassConstant * (particle.density);
}

- (void) computeInternalForcesForParticle:(ECETrafficParticle*)particle
                            andNeighbours:(NSMutableArray*)neighbours
{
    if (particle)
    {
        float posResult, veloResult;
        
        // init
        posResult  = 0;
        veloResult = 0;
        
        // neighbours = [self getNeighboursAlongNFromArray:neighbours andParticle:particle];
        
        // Going through all the particle's neighbours
        for (int i=0; i<[neighbours count]; i++)
        {
            float velocityDiff, positionDiff;
            float kernelGradientResult;;
            ECETrafficParticle *neigh;
            
            // Getting neighbour from array
            neigh = neighbours[i];   
            
            if ([neigh particleID] != [particle particleID])
            {
                // (1) Computing position component of the internal force
                //
                //    (1.a)  Calculating the difference in positions.
                positionDiff = (-1) * ([neigh position].y - [particle position].y);
                //
                //    (1.b)  Diff position / density.
                positionDiff = positionDiff / [neigh density];
                //
                //    (1.c)  Evaluating the kernel.
                kernelGradientResult = [ECEKernels useLaplacianOfViscosityKernel:GLKVector3Subtract([particle position], [neigh position])];
                //
                //    (2.c)  Getting final result
                posResult += kernelGradientResult * positionDiff;
                
                // (2) Computing velocity component of the internal force
                //
                //    (2.a)  Calculating the relative velocity.
                //velocityDiff = ([neigh velocity].y - [particle velocity].y);
                velocityDiff = ([neigh velocity].y    / (neigh.density    * neigh.density)) -
                               ([particle velocity].y / (particle.density * particle.density));
                //
                //    (2.b)  Relative velocity / density.
                //velocityDiff = velocityDiff / [neigh density];
                //
                //    (2.c)  Getting final result
                veloResult += kernelGradientResult * velocityDiff;
            }
        }
        
        // Dividing results by the particle mass
        posResult  = posResult /  fluidMaterial.particlesMass;
        veloResult = veloResult / fluidMaterial.particlesMass;
        
        // Gradient * N * coeffitient
        //gradientPositionTimesN = GLKVector3MultiplyScalar(n, posResult * POSITION_COEFICIENT_K);
        //gradientVelocityTimesN = GLKVector3DotProduct(veloResult, n) * NORMAL_VELOCITY_COEFICIENT_K;
        //gradientVelocityTimesT = GLKVector3DotProduct(veloResult, n) * TANGENT_VELOCITY_COEFICIENT_K;
        
        // Setting particle's internal forces.
        particle.internalForceAlongN = GLKVector3MultiplyScalar(n, - veloResult * NORMAL_VELOCITY_COEFICIENT_K);
       // particle.internalForceAlongN = GLKVector3Make(0, gradientPositionTimesN, 0);
        /*particle.internalForceAlongN = GLKVector3Add(GLKVector3Make(0, gradientVelocityTimesN, 0),
                                                     GLKVector3Make(0, gradientPositionTimesN, 0));*/
        particle.internalForceAlongT = GLKVector3MultiplyScalar(t, fabs(veloResult) * TANGENT_VELOCITY_COEFICIENT_K);
        
        GLKVector3 pressureForce, kernelPar, diff, kernelPart;
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
        particle.internalForceAlongN = GLKVector3Make(0, GLKVector3MultiplyScalar(pressureForce, (- 1) * [fluidMaterial particlesMass] * [particle density]).y, 0);
        
        particle.internalForceAlongT = GLKVector3Add(particle.internalForceAlongT, GLKVector3Make(GLKVector3MultiplyScalar(pressureForce, (- 0.3) * [fluidMaterial particlesMass] * [particle density]).x * 0.5, 0, 0));
    }
}

- (void) computeSurfaceTensionForParticle:(ECEParticle*)particle andNeighbours:(NSMutableArray*)neighbours
{
    GLKVector3 normal, diff;
    double tensionForceKernelPart, normalLength;
    ECEParticle* neigh;
    
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
    for (int i=0; i<[particles count]; i++)
    {
        [((ECEParticle*)particles[i]) draw];
        
        if (PARTICLE_TO_TEST_ID == [((ECEParticle*)particles[i]) particleID])
        {
            // Draw internal force along N
            if (drawInternalForceAlongN)
                [((ECETrafficParticle*)particles[i]) drawInternalForceAlongN];
            // Draw internal force along T
            else if (drawInternalForceAlongT)
                [((ECETrafficParticle*)particles[i]) drawInternalForceAlongT];
            // Draw velocity
            else
                [((ECEParticle*)particles[i]) drawVelocity];
        }
    }
    
    // Drawing grid.
    if (self.drawGrid)
        [grid draw];
}

@end
