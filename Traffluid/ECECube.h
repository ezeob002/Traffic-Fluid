//
//  ECECube.h
//  ECE 595
//

#import <Foundation/Foundation.h>
#import "ECEShape.h"

@interface ECECube : ECEShape
{
    /// Vertices of the cube
    Vertex vertices[8];
    
    /// Normals of the vertices of the cube
    Vertex normals[8];
    
    /// Indices for every of the faces of the cube.
    GLubyte indices[36];
}

/// Min vertex of the cube.
@property GLKVector3 min;

/// Max vertex of the cube.
@property GLKVector3 max;

- (id) initWithMin:(GLKVector3)_min andMax:(GLKVector3)_max;

- (void) updateWithMin:(GLKVector3)_min andMax:(GLKVector3)_max;

- (void) resetInfo;

- (void) draw;

- (void) multiplyByMatrix:(GLKMatrix4)matrix;

@end
