//
//  ECECollisionOOBox.m
//  ECE595
//
//  
#import "ECECollisionOOBox.h"


@interface ECECollisionOOBox ()
{
    /// It's a vector which values are the half distances of the box.
    GLKVector3 exts;
    
    /// It's the transformation matrix to transform a vector from World Coordinate System to the Box Coordinate System.
    GLKMatrix3 transform;
}

- (void) createTransformationMatrix;

- (float) collisionFunction:(GLKVector3)position;

- (GLKVector3) getContactPoint:(GLKVector3)position;

- (GLKVector3) transformToLocal:(GLKVector3)position;

- (GLKVector3) getContactPoint:(GLKVector3)position;

- (GLKVector3) getLocalNormalAtLocalContactPoint:(GLKVector3)cpLocal andLocalPosition:(GLKVector3)posLocal;

- (GLKVector3) reflectVector:(GLKVector3)vector inNormal:(GLKVector3)normal;

@end

@implementation ECECollisionOOBox

@synthesize center, u, v, w, halfU, halfV, halfW;

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
 * It initializes with default values all the members of this class.
 *
 * @param
 * @return
 */
-(id) initWithCenter:(GLKVector3)_center
               axisU:(GLKVector3)_u
               axisV:(GLKVector3)_v
               axisW:(GLKVector3)_w
               halfU:(double)_halfU
               halfV:(double)_halfV
               halfW:(double)_halfW
{
    self = [super init];
    if (self)
    {
        center = _center;
        u      = _u;
        v      = _v;
        w      = _w;
        halfU  = _halfU;
        halfV  = _halfV;
        halfW  = _halfW;
        exts   = GLKVector3Make(_halfU, _halfV, _halfW);
        [self createTransformationMatrix];
    }
    return self;
}

-(id) initFromCube:(ECECube*)cube
{
    self = [super init];
    if (self)
    {
        
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
    center = GLKVector3Make(0, 0, 0);
    u      = GLKVector3Make(1, 0, 0);
    v      = GLKVector3Make(0, 1, 0);
    w      = GLKVector3Make(0, 0, 1);
    halfU  = 1;
    halfV  = 1;
    halfW  = 1;
    exts   = GLKVector3Make(halfU, halfV, halfW);
    [self createTransformationMatrix];
}

#pragma mark - Utils

/**
 * It creates the transformation matrix that would transform a vector from World Coordinate System to the Box Coordinate System.
 *
 * @param
 * @return
 */
- (void) createTransformationMatrix
{
    transform = GLKMatrix3MakeWithColumns(u, v, w);
}

/**
 * It transform the input vector from World Coordinate System to the Box Coordinate System.
 *
 * @param
 * @return
 */
- (GLKVector3) transformToLocal:(GLKVector3)position
{
    position = GLKVector3Subtract(position, center);
    position = GLKMatrix3MultiplyVector3(transform, position);
    
    return position;
}

/**
 * It transform the input vector to World Coordinate System from the Box Coordinate System.
 *
 * @param
 * @return
 */
- (GLKVector3) transformToWorld:(GLKVector3)position
{
    BOOL invertible;
    
    position = GLKMatrix3MultiplyVector3(GLKMatrix3Invert(transform, &invertible), position);
    position = GLKVector3Add(position, center);
    
    return position;
}

/**
 * It handles the collision of the input particle with the collision shape.
 *
 * @param
 * @return
 */
- (void) handleCollisionFor:(ECEParticle*)particle
{
    if (particle)
    {
        double result;
        GLKVector3 localPos;
        
        // Transforming particle position to the local coordinate system.
        localPos = [self transformToLocal:[particle position]];

        // Transforming the position into local coordinate position.
        result = [self collisionFunction:localPos];

        if (result > 0)
        {
            GLKVector3 cpLocal, worldNormal, newVelocity;
            
            // Getting local contact point
            cpLocal = [self getContactPoint:localPos];
            
            // Getting normal at local contact point
            worldNormal = [self transformToWorld:[self getLocalNormalAtLocalContactPoint:cpLocal andLocalPosition:localPos]];
            worldNormal = GLKVector3Normalize(worldNormal);
            
           /* if (worldNormal.y > worldNormal.z || worldNormal.y > worldNormal.x)
            {*/
                // Getting new particle's velocity
                newVelocity = [self reflectVector:[particle velocity] inNormal:worldNormal];
                
                // Setting new velocity
                particle.velocity = newVelocity;
                
                // Setting position of the particle as the contact point in the box.
                [particle setParticlePosition:[self transformToWorld:cpLocal]];
            //}
        }
    }
}

- (void) handleCollisionWithNOBounginFor:(ECEParticle*)particle
{
    if (particle)
    {
        double result;
        GLKVector3 localPos;
        
        // Transforming particle position to the local coordinate system.
        localPos = [self transformToLocal:[particle position]];
        
        // Transforming the position into local coordinate position.
        result = [self collisionFunction:localPos];
        
        if (result > 0)
        {
            GLKVector3 cpLocal, worldNormal;
            
            // Getting local contact point
            cpLocal = [self getContactPoint:localPos];
            
            // Getting normal at local contact point
            worldNormal = [self transformToWorld:[self getLocalNormalAtLocalContactPoint:cpLocal andLocalPosition:localPos]];
            worldNormal = GLKVector3Normalize(worldNormal);
            
            // Setting position of the particle as the contact point in the box.
            [particle setParticlePosition:[self transformToWorld:cpLocal]];
            //}
        }
    }
}

- (void) handleOutsideCollisionFor:(ECEParticle*)particle
{
    if (particle)
    {
        double result;
        GLKVector3 localPos;
        
        // Transforming particle position to the local coordinate system.
        localPos = [self transformToLocal:[particle position]];
        
        // Transforming the position into local coordinate position.
        result = [self collisionFunction:localPos];
        
        if (result < 0)
        {
            GLKVector3 cpLocal, worldNormal, newVelocity;
            
            // Getting local contact point
            cpLocal = [self getContactPoint:localPos];
            
            // Getting normal at local contact point
            GLKVector3 normal = [self getLocalNormalAtLocalContactPoint:cpLocal andLocalPosition:localPos];
            worldNormal = [self transformToWorld:normal];
            
            if (GLKVector3Length(worldNormal) > 0)
            {
                worldNormal = GLKVector3Normalize(worldNormal);
            
                /* if (worldNormal.y > worldNormal.z || worldNormal.y > worldNormal.x)
                 {*/
                // Getting new particle's velocity
                newVelocity = [self reflectVector:[particle velocity] inNormal:worldNormal];
                
                // Setting new velocity
                particle.velocity = newVelocity;
                
                // Setting position of the particle as the contact point in the box.
                [particle setParticlePosition:[self transformToWorld:cpLocal]];
            }
            //}
        }
    }
}

/**
 * It returns a float that describes the collision of the input position. (1) If the float is zero, it means the position is in the surface of the box. (2) If the float is greater than zero, it means the position is outside the box (3) If the float is less than zero, it means the position is inside the box.
 *
 * @param
 * @return
 */
- (float) collisionFunction:(GLKVector3)position
{
    float r;
    GLKVector3 substraction;
    
    // init
    r = 0;
    
    // Valor absolute all the componentes in the position
    position.x = fabs(position.x);
    position.y = fabs(position.y);
    position.z = fabs(position.z);
    
    // Substracting position with the exts vector.
    substraction = GLKVector3Subtract(position, exts);
    
    // Extracting the maximun component of the substraction vector.
    r = substraction.x;
    if (r < substraction.y)
        r = substraction.y;
    if (r < substraction.z)
        r = substraction.z;
    
    return r;
}

/**
 * It returns the contact point in the surface of the box of the local input position.
 *
 * @param position      Local position from where the contact point will be calculated.
 * @return the contact point in the surface of the box of the local input position.
 */
- (GLKVector3) getContactPoint:(GLKVector3)position
{
    GLKVector3 max;
    
    max = GLKVector3Maximum(GLKVector3MultiplyScalar(exts, -1), position);
    
    return GLKVector3Minimum(exts, max);
}

/**
 * It returns the normal of the wall of the box where the input local point "cpLocal" resides, based on the local position input "posLocal" where the point really is.
 *
 * @param cpLocal      Local position from where the normal will be calculated.
 * @param posLocal     Local position of the point.
 * @return the normal of the wall of the box where the input local point "cpLocal" resides, based on the local position input "posLocal" where the point really is.
 */
- (GLKVector3) getLocalNormalAtLocalContactPoint:(GLKVector3)cpLocal andLocalPosition:(GLKVector3)posLocal
{
    GLKVector3 localNormal;
    
    localNormal = GLKVector3Subtract(cpLocal, posLocal);
    
    // Applying sign function to x
    if (localNormal.x > 0)
        localNormal.x = 1;
    else if (localNormal.x < 0)
        localNormal.x = - 1;
    
    // Applying sign function to y
    if (localNormal.y > 0)
        localNormal.y = 1;
    else if (localNormal.y < 0)
        localNormal.y = - 1;
    
    // Applying sign function to z
    if (localNormal.z > 0)
        localNormal.z = 1;
    else if (localNormal.z < 0)
        localNormal.z = - 1;
    
    return localNormal;
}

/**
 * It reflects the input vector "vector" in the input normal "normal".
 *
 * @param position      Position that will be reflected.
 * @param normal        Normal from where the position will be reflected.
 * @return the reflected vector.
 */
- (GLKVector3) reflectVector:(GLKVector3)vector inNormal:(GLKVector3)normal
{
    GLKVector3 transformedVector;
    double CR = 0.8;
    
    transformedVector = GLKVector3MultiplyScalar(normal, GLKVector3DotProduct(vector, normal));
    transformedVector = GLKVector3MultiplyScalar(transformedVector, (1 + CR));
    transformedVector = GLKVector3Subtract(vector, transformedVector);
    
    return transformedVector;
}

@end
