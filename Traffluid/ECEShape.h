//
//  ECEShape.h
//  ECE 595
//


#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ECEGlobal.h"
#import <OpenGL/OpenGL.h>
#import <GLUT/GLUT.h>

@interface ECEShape : NSObject

/// Vertex buffer of the cube
@property GLuint vertexBuffer;

/// Index buffer of the cube.
@property GLuint indexBuffer;

/// Normals buffer of the cube
@property GLuint normalsBuffer;

/// Color of the cube.
@property GLKVector4 color;

/// Render type for the shapes to be rendered. Possible values are: GL_POINTS, GL_LINES, GL_TRIANGLES, etc.
@property GLenum renderType;

- (void) resetInfo;

- (void) multiplyByMatrix:(GLKMatrix4)matrix;

@end
