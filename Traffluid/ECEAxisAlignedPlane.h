//
//  ECEPlane.h
//  ECE 595
//
//  
#import <Foundation/Foundation.h>
#import "ECEShape.h"

@interface ECEAxisAlignedPlane : ECEShape
{
    /// Vertices of the cube
    Vertex vertices[4];
    
    /// Indices for every of the faces of the cube.
    GLubyte indices[5];
}

/// Position of the plane.
@property GLKVector3 position;

- (id) initWithPosition:(GLKVector3)_position;

- (void) updateWithPosition:(GLKVector3)_position andTypeOfComponent:(NSInteger)component;

- (void) resetInfo;

- (void) draw;

@end
