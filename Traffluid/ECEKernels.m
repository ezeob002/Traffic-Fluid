//
//  ECEKernel.m
//  ECE 595
//
#import "ECEKernels.h"

/// The support radius.
static double h;

/// The constant used in the Poly kernel.
static double polyKernelConstant;

/// The constant used in the Spiky kernel.
static double spikyKernelConstant;

/// The constant used in the Viscosity kernel.
static double viscosityKernelConstant;

@implementation ECEKernels

/**
 * It gets an instance of the object found in an static variable. This way this variable is initialize just once.
 *
 * @param
 * @return
 */
+ (ECEKernels *) initializeWithSupportRadius:(double)_h
{
    static ECEKernels *inst = nil;
    @synchronized(self)
    {
        if (!inst)
        {
            inst = [[self alloc] init];
            
            // init support
            h = _h;
            
            // Init kernel's constants
            polyKernelConstant          =   315.0 / (64.0 * M_PI * pow(h, 9));
            spikyKernelConstant         =  - 45.0 / (M_PI * pow(h, 6));
            viscosityKernelConstant     =    45.0 / (M_PI * pow(h, 6));
        }
    }
    
    return inst;
}

/**
 * It inits the constants related to the support h.
 *
 * @param
 * @return
 */
+ (void) setSupport:(double)_h
{
    h = _h;
    
    // Improving constants
    polyKernelConstant          =   315.0 / (64.0 * M_PI * pow(h, 9));
    spikyKernelConstant         =  - 45.0 / (M_PI * pow(h, 6));
    viscosityKernelConstant     =    45.0 / (M_PI * pow(h, 6));
}

#pragma mark - Poly Kernel

+ (double) usePolyKernel:(GLKVector3)r
{
    double result, lengthSquared, length;
    
    // init
    result = 0;
    
    // Getting vecotr length
    lengthSquared = GLKVector3DotProduct(r, r);
    
    // Calculating length of vector r
    length = sqrt(lengthSquared);
    
    if (0 <= length && length <= h)
    {
        double aux;
        
        // Using auxiliar variable to reduce computations.
        aux = (h * h - lengthSquared);
        
        // Calculation
        result = polyKernelConstant * (aux * aux * aux);
    }
    
    return result;
}

+ (GLKVector3) useGradiantOfPolyKernel:(GLKVector3)r
{
    GLKVector3 result;
    double length;
    
    // init
    length = GLKVector3Length(r);
    result = r;
    
    if (0 <= length && length <= h)
    {
        double aux;
        
        // Using auxiliar variable to reduce computations.
        aux = (h * h - length * length);
        
        // Calculation
        result = GLKVector3MultiplyScalar(r, (-1) * polyKernelConstant * 6 * (aux * aux));
    }
    
    return result;
}

+ (double) useLaplacianOfPolyKernel:(GLKVector3)r
{
    double result;
    double length;
    
    // init
    length = GLKVector3Length(r);
    result = 0;
    
    if (0 <= length && length <= h)
    {
        double aux;
        
        // Using auxiliar variable to reduce computations.
        aux = (h * h - length * length);
        
        // Calculation
        result = (-1) * polyKernelConstant * 6 * aux * (3 * h * h - 7 * length * length);
    }
    
    return result;
}

#pragma mark - Spiky Kernel

+ (GLKVector3) useGradiantOfSpikyKernel:(GLKVector3)r
{
    GLKVector3 result;
    double lengthSquared, length;
    
    // init
    lengthSquared = GLKVector3DotProduct(r, r);
    result = GLKVector3Make(0, 0, 0);
    
    // Calculating length of vector r
    length = sqrt(lengthSquared);
    
    if (0 <= length && length <= h)
    {
        double aux;
        
        // Using auxiliar variable to reduce computations.
        aux = (h - length);
        
        // Calculation
        result = GLKVector3MultiplyScalar(r, spikyKernelConstant * (aux * aux) / length);
    }
    
    return result;
}

#pragma mark - Viscosity Kernel

+ (double) useLaplacianOfViscosityKernel:(GLKVector3)r
{
    double result;
    double lengthSquared, length;
    
    // init
    lengthSquared = GLKVector3DotProduct(r, r);
    length = sqrt(lengthSquared);
    result = 0;
    
    if (0 <= length && length <= h)
    {
        // Calculation
        result = viscosityKernelConstant * (h - length);
    }
    
    return result;
}

@end
