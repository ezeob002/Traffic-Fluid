//
//  ECELeapFrogIntegrator.h
//  ECE595
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ECELeapFrogIntegrator : NSObject

+ (ECELeapFrogIntegrator *) sharedInstance;

- (void) resetInfo;

+ (GLKVector3) integrateVector:(GLKVector3)vector
                 withDeltaTime:(double)deltaTime
           previousVectorValue:(GLKVector3)previousVector;

@end
