//
//  ECETrafficParticle.m
//  ECE595
//

#import "ECETrafficParticle.h"

@implementation ECETrafficParticle

@synthesize internalForceAlongN, internalForceAlongT, enabled;

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
    self.particleID      = 0;
    self.position        = GLKVector3Make(0.0, 0.0, 0.0);
    self.velocity        = GLKVector3Make(0.0, 0.0, 0.0);
    self.acceleration    = GLKVector3Make(0.0, 0.0, 0.0);
    self.density         = 0.1;
    self.pressure        = 0;
    self.sphereRadius    = 0.05;
    self.cube            = [[ECESphere alloc] initWithCenter:GLKVector3Make(0, 0, 0) andRadius:self.sphereRadius];
    self.particleColor   = GREEN_COLOR;
    self.supportRadius   = 0.0;
    self.secondaryParticleColor = GLKVector4Make(- 1.0, -1.0, -1.0, -1.0);
    self.numOfNeighbours = 0;
    
    internalForceAlongN        = GLKVector3Make(0.0, 0.0, 0.0);
    internalForceAlongT        = GLKVector3Make(0.0, 0.0, 0.0);
    enabled                    = YES;
}

#pragma mark - Utils

/**
 * It sets the position of the particle with the input "position". It also modifies the shape of the 3D element of the particle based on that position.
 *
 * @param
 * @return
 */
- (void) setParticlePosition:(GLKVector3)_position
{
    [super setParticlePosition:_position];
}

/**
 * It sets the position of the particle with the input "position". It also modifies the shape of the 3D element of the particle based on that position.
 *
 * @param
 * @return
 */
- (void) setParticlePosition:(GLKVector3)_position andRadius:(float)radius
{
    [super setParticlePosition:_position andRadius:radius];
}

/**
 * It sets the color of the particle with the input "color".
 *
 * @param
 * @return
 */
- (void) setTheParticleColor:(GLKVector4)_color
{
    [super setParticleColor:_color];
}

- (void) update:(double)deltaTime
{
    [super update:deltaTime];
}

#pragma mark - openGL

- (void) drawVelocity
{
    GLKVector3 tempVelocity;
    
    // init
    tempVelocity = GLKVector3MultiplyScalar(self.velocity, 0.03);
    
    // Drawing line
    if (GLKVector3Length(tempVelocity) > 0.01)
        [super drawArrowFrom:self.position to:GLKVector3Add(self.position, tempVelocity)];
}

- (void) drawInternalForceAlongN
{
    GLKVector3 tempForce;
    
    // init
    tempForce = GLKVector3MultiplyScalar(self.internalForceAlongN, 0.001);
    
    // Drawing line
    if (GLKVector3Length(tempForce) > 0.01)
        [self drawArrowFrom:self.position to:GLKVector3Add(self.position, tempForce)];
}

- (void) drawInternalForceAlongT
{
    GLKVector3 tempForce;
    
    // init
    tempForce = GLKVector3MultiplyScalar(self.internalForceAlongT, 0.001);
    
    // Drawing line
    if (GLKVector3Length(tempForce) > 0.01)
        [self drawArrowFrom:self.position to:GLKVector3Add(self.position, tempForce)];
}

- (void) draw
{
    [super draw];
}

@end
