//
//  ECELeapFrogIntegrator.m
//  ECE595
//

#import "ECELeapFrogIntegrator.h"

@interface ECELeapFrogIntegrator ()
{

}

@end

@implementation ECELeapFrogIntegrator

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
 * It gets an instance of the object found in an static variable. This way this variable is initialize just once.
 *
 * @param
 * @return
 */
+ (ECELeapFrogIntegrator *) sharedInstance
{
    static ECELeapFrogIntegrator *inst = nil;
    @synchronized(self)
    {
        if (!inst)
        {
            inst = [[self alloc] init];
        }
    }
    
    return inst;
}

/**
 * It gives the default value to all the members in this class.
 *
 * @param
 * @return
 */
- (void) resetInfo
{
    
}

+ (GLKVector3) integrateVector:(GLKVector3)vector
                 withDeltaTime:(double)deltaTime
           previousVectorValue:(GLKVector3)previousVector
{
    GLKVector3 r;
    
    r = GLKVector3Add(previousVector, GLKVector3MultiplyScalar(vector, deltaTime));
    
    return r;
}

@end
