//
//  TFCamera.m
//  Traffluid
//

#import "TFCamera.h"

@interface TFCamera ()
{}

- (GLKVector3) getUpVector;

- (GLKVector3) getUnitViewVector;

- (GLKVector3) getUnitHorizontalVector;

@end

@implementation TFCamera

@synthesize position, lookAt, up, theta, phi, distanceToLookAtPoint;

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
    distanceToLookAtPoint = 5;
    position = GLKVector3Make(0, 0, distanceToLookAtPoint);
    lookAt   = GLKVector3Make(0, 0, 0);
    up       = GLKVector3Make(0, 1, 0);
    theta    = M_PI * 0.25;
    phi      = M_PI * 0.5;
}

- (void) setInitialPosition:(GLKVector3)pos
              initialLookAt:(GLKVector3)look
              initialUp:(GLKVector3)n
{
    position = pos;
    lookAt = look;
    up     = n;
    
    phi   = distanceToLookAtPoint != 0 ? acos((pos.v[1] - lookAt.v[1]) / distanceToLookAtPoint) : 0;
    theta = sinf(phi) != 0 && distanceToLookAtPoint != 0 ? acos((pos.v[0] - lookAt.v[0]) / (distanceToLookAtPoint * sinf(phi))) : 0;
}

#pragma mark - Utils

- (void) updatePositionAndNormal
{
    position.v[0] = lookAt.v[0] + distanceToLookAtPoint * sinf(phi) * cosf(theta);
    position.v[1] = lookAt.v[1] + distanceToLookAtPoint * cosf(phi);
    position.v[2] = lookAt.v[2] + distanceToLookAtPoint * sinf(phi) * sinf(theta);
    
    up = GLKVector3CrossProduct([self getUnitHorizontalVector], [self getUnitViewVector]);
}

- (GLKVector3) getUpVector
{
    return GLKVector3CrossProduct([self getUnitHorizontalVector], [self getUnitViewVector]);
}

- (GLKVector3) getUnitViewVector
{
    GLKVector3 viewDirection;
    
    // Getting unit view vector
    viewDirection = GLKVector3Subtract(lookAt, position);
    viewDirection = GLKVector3Normalize(viewDirection);
    
    return viewDirection;
}

- (GLKVector3) getUnitHorizontalVector
{
    GLKVector3 horizontalVector;
    
    // Getting unit view vector
    horizontalVector = GLKVector3CrossProduct([self getUnitViewVector], GLKVector3Make(0, 1, 0));
    horizontalVector = GLKVector3Normalize(horizontalVector);
    
    return horizontalVector;
}

- (void) addToTheta:(CGFloat)value
{
    theta += value;
    
    // Clamping angle
    /*if (fabs(theta) > M_PI * 2)
        theta = theta > 0 ? theta - M_PI - 0.0001 : theta + M_PI + 0.0001;*/
}

- (void) addToPhi:(CGFloat)value
{
    phi += value;
    
    // Clamping angle
    if (phi < 0)
        phi = 0 + 0.0001;
    if (phi > M_PI)
        phi = M_PI - 0.0001;
}

- (void) zoomCameraByScalar:(CGFloat)scalar
{
    distanceToLookAtPoint += scalar;
    
    if (distanceToLookAtPoint < 0.01)
        distanceToLookAtPoint = 0.01;
}

- (void) moveCameraHorizontallyByScalar:(CGFloat)scalar
{
    GLKVector3 horizontalVector;
    
    // Getting horizontal vector
    horizontalVector = [self getUnitHorizontalVector];
    
    // Modifying lookAt vector
    lookAt = GLKVector3Add(lookAt, GLKVector3MultiplyScalar(horizontalVector, scalar));
}

- (void) moveCameraVerticallyByScalar:(CGFloat)scalar
{
    // Modifying lookAt vecyor
    lookAt = GLKVector3Add(lookAt, GLKVector3MultiplyScalar(up, scalar));
}

@end
