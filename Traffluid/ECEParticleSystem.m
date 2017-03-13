//
//  ECEParticleSystem.m
//  ECE 595
//

#import "ECEParticleSystem.h"
#import "ECEParticle.h"
#import "ECEGlobal.h"
#import "ECECube.h"
#import "ECEKernels.h"
#import "ECEGridHashTable.h"
#import "ECEWaterFluidMaterial.h"
#import "ECETrafficFluidMaterial.h"

#define GRAVITY_DEFAULT_MAGNITUDE -9.8

NSInteger NUM_OF_PARTICLES_DEFAULT_VALUE     = 1500;
NSInteger PARTICLE_MASS_DEFAULT_VALUE        = 0.1;
float     INITIAL_SPACE_BETWEEN_PARTICLES    = 0.5;

@interface ECEParticleSystem ()
{

}

@end

@implementation ECEParticleSystem

@synthesize numberOfParticles, particleMass, particlesColor, particlesInitialPosition, particlesInitialVelocity, fluidMaterial, isPause, drawDensity, half_size_of_particles_sphere, drawGrid;

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
    numberOfParticles        = NUM_OF_PARTICLES_DEFAULT_VALUE;
    particleMass             = PARTICLE_MASS_DEFAULT_VALUE;
    particlesColor           = GREEN_COLOR;
    gravity                  = GLKVector3Make(0.0, 0.0, 0.0);
    particlesInitialPosition = GLKVector3Make(0, 0, 0);
    particlesInitialVelocity = GLKVector3Make(0, 0, 0);
    fluidMaterial            = [[ECEFluidMaterial alloc] init];
    isPause                  = YES;
    drawDensity              = YES;
    drawGrid                 = NO;
    half_size_of_particles_sphere = 0.015;
    
    // Creating the particles
    particles = [[NSMutableArray alloc] init];
}

#pragma mark - Utils

/**
 * It gives the particles their initial position.
 *
 * @param
 * @return
 */
- (void) setParticlesInitialPositionsInAGrid
{
    NSInteger gridDistance;
    float initX, initY, sqRoot;
    
    // init some values needed to create the grid.
    sqRoot       = sqrt(numberOfParticles);
    gridDistance = INITIAL_SPACE_BETWEEN_PARTICLES * (sqRoot - 1);
    initX        = - sqRoot * INITIAL_SPACE_BETWEEN_PARTICLES * 0.5 + particlesInitialPosition.x;
    initY        = - sqRoot * INITIAL_SPACE_BETWEEN_PARTICLES * 0.5 + particlesInitialPosition.y;
    
    // Giving a initial position for every particle in the system.
    for (int i=0; i<[particles count]; i++)
    {
        double col, row;
        
        // Getting the row and column of the particle in the initial grid.
        col = fmod(i, sqRoot);
        row = floor(i / sqRoot);
        
        // Setting particle color
        [((ECEParticle*)particles[i]) setParticleColor:GREEN_COLOR];
        
        // Setting particle i inital position.
        [((ECEParticle*)particles[i]) setParticlePosition:GLKVector3Make(initX + col * INITIAL_SPACE_BETWEEN_PARTICLES,
                                                                        initY + row * INITIAL_SPACE_BETWEEN_PARTICLES,
                                                                        [ECEGlobal getRandomNumberBetween:0 to:100]/100.0)];
    }
}

/**
 * It computes the next state of the particle system in time.
 *
 * @param
 * @return
 */
- (void) update
{
    for (int i=0; i<[particles count]; i++)
        // Updating particle
        [particles[i] update:fluidMaterial.deltaTime];
}

/**
 * It adds a default gravity force to the system.
 *
 * @param
 * @return
 */
- (void) addGravity
{
    gravity = GLKVector3Make(0, GRAVITY_DEFAULT_MAGNITUDE, 0);
}

/**
 * Returns the intersected particle by the input ray.
 *
 * @param rayDirection  Direction of the ray.
 * @param rayCenter     Center of the ray.
 * @return the intersected particle by the input ray.
 */
- (ECEParticle*) rayIntersectsParticle:(GLKVector3)rayDirection andRayCenter:(GLKVector3)rayCenter
{
    ECEParticle* r;
    double kEpsilon, tmin;
    
    // init
    kEpsilon = 0.000001;
    tmin     = 9999999999999999;
    
    for (int i=0; i<[particles count]; i++)
    {
        ECEParticle* particle;
        double t, a, b, c, disk, tminAux;
        GLKVector3 temp;
        bool hit;
        
        // init
        tminAux = tmin;
        hit = false;
        particle = particles[i];
        
        // Getting temp vector
        temp = GLKVector3Subtract(rayCenter, particle.position);
        
        // Getting a, b, c and disk
        a = GLKVector3DotProduct(rayDirection, rayDirection);
        b = 2.0 * GLKVector3DotProduct(temp, rayDirection);
        c = GLKVector3DotProduct(temp, temp) - particle.sphereRadius * particle.sphereRadius;
        disk = b * b - 4 * a * c;
        
        if (disk >= 0.0)
        {
            double e, denom;
            
            // init
            e = sqrt(disk);
            denom = 2.0 * a;
            t = (- b - e) / denom;      // Smaller root
            
            // Hitting test
            if (t > kEpsilon)
            {
                tminAux = t;
                hit = true;
            }
            
            t = (- b + e) / denom;     // Larger root
            
            // Hitting test
            if (t > kEpsilon)
            {
                tminAux = t;
                hit = true;
            }
        }
        
        // Adding particle to array if the particle was hit by the ray.
        if (hit && tminAux < tmin)
        {
            tmin = tminAux;
            r = particle;
        }
    }
    
    return r;
}

- (void) handleDebugModesForNeighbours:(NSMutableArray*) neighbours
{
    if (PARTICLE_TO_TEST_ID >=0)
    {
        for (int i=0; i<[particles count]; i++)
        {
            ECEParticle* particle;
            
            // Getting particle
            particle = particles[i];
            
            if (particle.particleID == PARTICLE_TO_TEST_ID)
            {
                [particle resetSecondaryColor];
            }
            else if (particle.secondaryParticleColor.x < 0)
            {
                particle.secondaryParticleColor = WHITE_COLOR;
            }
        }
                
        for (int j=0; j<[neighbours count]; j++)
        {
            ECEParticle* neigh;
            neigh = neighbours[j];
            
            if (neigh.particleID != PARTICLE_TO_TEST_ID)
                neigh.secondaryParticleColor = YELLOW_COLOR;
        }
    }
    else
    {
        for (int i=0; i<[particles count]; i++)
        {
            ECEParticle* particle;
            
            // Getting particle
            particle = particles[i];
            
            // Reseting secondary color
            [particle resetSecondaryColor];
            
            if (drawDensity)
            {
                double density;
                
                density = [particle density] / 2500;
                
                if (density < 0)
                    particle.secondaryParticleColor = BLACK_COLOR;
                else
                    particle.secondaryParticleColor = GLKVector4Make(density, 0, 1 - density, 1);
            }
        }
    }
}

/**
 * It handles all the debug modes for the input particle.
 *
 * @param particle      Input particle.
 * @param neighbours
 * @return
 */
- (void) handleDebugModesForParticle:(ECEParticle*)particle andNeighbours:(NSMutableArray*) neighbours
{
    // ONLY For Debugging: we paint in black all the particles except the test particle.
    if (PARTICLE_TO_TEST_ID >= 0)
    {
        if (particle.particleID != PARTICLE_TO_TEST_ID &&
            ![NEIGHBOURS_OF_THE_PARTICLE_TO_TEST_ID containsObject:particle])
            particle.secondaryParticleColor = WHITE_COLOR;
        else if (particle.particleID == PARTICLE_TO_TEST_ID)
        {
            [particle resetSecondaryColor];
            NEIGHBOURS_OF_THE_PARTICLE_TO_TEST_ID = [neighbours copy];
        }
        else if ([NEIGHBOURS_OF_THE_PARTICLE_TO_TEST_ID containsObject:particle])
            particle.secondaryParticleColor = YELLOW_COLOR;
    }
    else
    {
        [particle resetSecondaryColor];
        
        if (drawDensity)
        {
            double density;
            
            density = [particle density] / 2500;
            
            if (density < 0)
                particle.secondaryParticleColor = BLACK_COLOR;
            else
                particle.secondaryParticleColor = GLKVector4Make(density, 0, 1 - density, 1);
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

}

- (void) createParticlesInGridInContainerSize:(GLKVector3)boxSize
{

}

#pragma mark - Physics

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

#pragma mark - openGL

- (void) draw
{
    for (int i=0; i<[particles count]; i++)
    {
        [((ECEParticle*)particles[i]) draw];
        
        if (PARTICLE_TO_TEST_ID == [((ECEParticle*)particles[i]) particleID])
            [((ECEParticle*)particles[i]) drawVelocity];
    }
}

@end
