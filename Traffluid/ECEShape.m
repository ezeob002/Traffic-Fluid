//
//  ECEShape.m
//  ECE 595
//

#import "ECEShape.h"

@implementation ECEShape

@synthesize vertexBuffer, indexBuffer, color, renderType, normalsBuffer;

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
    vertexBuffer  = 0;
    indexBuffer   = 0;
    normalsBuffer = 0;
    color         = GLKVector4Make(0, 0, 0, 1);
    renderType    = GL_TRIANGLES;
}

/**
 * It multiplies all the vertices in this shape by the input matrix "matrix".
 *
 * @param
 * @return
 */
- (void) multiplyByMatrix:(GLKMatrix4)matrix
{

}

@end
