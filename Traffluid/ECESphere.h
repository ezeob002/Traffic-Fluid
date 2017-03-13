//
//  ECESphere.h
//  ECE595
//

#import <Foundation/Foundation.h>
#import "ECEShape.h"

@interface ECESphere : ECEShape
{
    /// Vertices of the sphere
    Vertex vertices[45];
    
    /// Normals of the sphere
    Vertex normals[45];
    
    /// Texture coordinates of the sphere
    Vertex texCoords[45];
    
    /// Indices for every of the faces of the sphere.
    GLubyte indices[192];
}

/// Min vertex of the cube.
@property GLKVector3 center;

/// Max vertex of the cube.
@property double radius;

- (id) initWithCenter:(GLKVector3)_center andRadius:(double)_radius;

- (void) updateWithCenter:(GLKVector3)_center andRadius:(double)_radius;

- (void) resetInfo;

- (void) draw;

- (void) multiplyByMatrix:(GLKMatrix4)matrix;

@end
