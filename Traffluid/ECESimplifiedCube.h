//
//  ECESimplifiedCube.h
//  ECE595
//

#import <Foundation/Foundation.h>
#import "ECEShape.h"

@interface ECESimplifiedCube : ECEShape
{
    /// Vertices of the cube
    Vertex vertices[8];
    
    /// Indices for every of the faces of the cube.
    GLubyte indices[17];
}

/// Min vertex of the cube.
@property GLKVector3 min;

/// Max vertex of the cube.
@property GLKVector3 max;

/// Position of the cube.
@property GLKVector3 position;

- (id) initWithMin:(GLKVector3)_min andMax:(GLKVector3)_max;

- (void) updateWithMin:(GLKVector3)_min andMax:(GLKVector3)_max;

- (void) resetInfo;

- (void) draw;

- (void) multiplyByMatrix:(GLKMatrix4)matrix;

@end
