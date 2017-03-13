//
//  ECEKernel.h
//  ECE 595
//


#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ECEKernels : NSObject

+ (ECEKernels *) initializeWithSupportRadius:(double)_h;

+ (void) setSupport:(double)_h;

// Poly Kernel

+ (double) usePolyKernel:(GLKVector3)r;

+ (GLKVector3) useGradiantOfPolyKernel:(GLKVector3)r;

+ (double) useLaplacianOfPolyKernel:(GLKVector3)r;

// Spiky Kernel

+ (GLKVector3) useGradiantOfSpikyKernel:(GLKVector3)r;

// Viscosity Kernel

+ (double) useLaplacianOfViscosityKernel:(GLKVector3)r;

@end
