//
//  ECEOpendGlassBox.m
//  ECE595
//
//  
#import "ECEOpendGlassBox.h"

// Particle's Lighting Materials
GLfloat mat_ambient_OpendGlassBox[]    = {0, 0, 0, 1.0f};
GLfloat mat_diffuse_OpendGlassBox[]    = {0, 0, 0, 1.0f};

@interface ECEOpendGlassBox ()
{
    GLKVector3 position;
    
    GLKVector3 dimensions;
}

@end

@implementation ECEOpendGlassBox

@synthesize min, max, color, vertexBuffer, indexBuffer;

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
 * It initializes the cube with input values.
 *
 * @param _min  MIN value of the cube.
 * @param _max  MAX value of the cube.
 * @return
 */
- (id) initWithMin:(GLKVector3)_min andMax:(GLKVector3)_max
{
    id selfCube;
    
    selfCube = [self init];
    
    // Update values
    [selfCube updateWithMin:_min andMax:_max];
    
    // Calculating the dimension and position of the box
    dimensions = GLKVector3Subtract(_max, _min);
    position   = GLKVector3Add(_min, GLKVector3MultiplyScalar(dimensions, 0.5));
    
    return selfCube;
}

/**
 * It gives the default value to all the members in this class.
 *
 * @param
 * @return
 */
- (void) resetInfo
{
    [super resetInfo];
    
    // Init
    min          = GLKVector3Make(-1, 0, -1);
    max          = GLKVector3Make(1, 1, 1);
    color        = WHITE_COLOR;
    color.w      = 0.25;
    
    // Associating grid's vertex and index buffers
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // Updating cube with the default min and max.
    [self updateWithMin:min andMax:max];
}

/**
 * It updates the cube with input values.
 *
 * @param _min    MIN value of the cube.
 * @param _max    MAX value of the cube.
 * @return
 */
- (void) updateWithMin:(GLKVector3)_min andMax:(GLKVector3)_max
{
    // Setting min and max values
    min   = _min;
    max   = _max;
    
    // Calculating the dimension and position of the box
    dimensions = GLKVector3Subtract(_max, _min);
    position   = GLKVector3Add(_min, GLKVector3MultiplyScalar(dimensions, 0.5));
    
    // Creating vertex buffer from min and max values.
    //
    // (1) Creating Vertices
    Vertex v1 = {{max.x, min.y, max.z},  {color.x, color.y, color.z, color.w}};
    Vertex v2 = {{max.x, max.y, max.z},  {color.x, color.y, color.z, color.w}};
    Vertex v3 = {{max.x, max.y, min.z},  {color.x, color.y, color.z, color.w}};
    Vertex v4 = {{max.x, min.y, min.z},  {color.x, color.y, color.z, color.w}};
    Vertex v5 = {{min.x, min.y, min.z},  {color.x, color.y, color.z, color.w}};
    Vertex v6 = {{min.x, max.y, min.z},  {color.x, color.y, color.z, color.w}};
    Vertex v7 = {{min.x, max.y, max.z},  {color.x, color.y, color.z, color.w}};
    Vertex v8 = {{min.x, min.y, max.z},  {color.x, color.y, color.z, color.w}};
    
    //
    // (2) Creating vertex buffer
    vertices[0] = v1;
    vertices[1] = v2;
    vertices[2] = v3;
    vertices[3] = v4;
    vertices[4] = v5;
    vertices[5] = v6;
    vertices[6] = v7;
    vertices[7] = v8;
    
    //
    // (3) Creating indices buffer
    //
    //    (a) 1st Face
    indices[0]  = 0;
    indices[1]  = 1;
    indices[2]  = 2;
    indices[3]  = 2;
    indices[4]  = 3;
    indices[5]  = 0;
    //    (b) 2nd Face
    indices[6]  = 2;
    indices[7]  = 3;
    indices[8]  = 4;
    indices[9]  = 4;
    indices[10] = 5;
    indices[11] = 2;
    //    (c) 3rd Face
    indices[12] = 4;
    indices[13] = 5;
    indices[14] = 6;
    indices[15] = 6;
    indices[16] = 7;
    indices[17] = 4;
    //    (d) 4th Face
    indices[18] = 0;
    indices[19] = 1;
    indices[20] = 6;
    indices[21] = 6;
    indices[22] = 7;
    indices[23] = 0;
    //    (e) 5th Face
    indices[24] = 0;
    indices[25] = 3;
    indices[26] = 4;
    indices[27] = 4;
    indices[28] = 7;
    indices[29] = 0;
    
    // Associating grid's vertex and index buffers
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), vertices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, sizeof(indices), indices);
}

- (void) draw
{
    glPushMatrix();
    glColor4f(0, 0, 0, 0.3);
    
    // Setting Lighting materials
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, mat_ambient_OpendGlassBox);
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, mat_diffuse_OpendGlassBox);
    
    glTranslatef(position.x, position.y, position.z);
    glScalef(dimensions.x, dimensions.y, dimensions.z);
    glLineWidth(1.0);
    glutWireCube(1);
    glPopMatrix();
}

- (void) multiplyByMatrix:(GLKMatrix4)matrix
{
    int size;
    GLKVector4 v;
    GLKMatrix4 myMatrix;
    
    // init vertex
    v = GLKVector4Make(0, 0, 0, 0);
    
    // Getting number of vertices
    size = sizeof(vertices)/sizeof(vertices[0]);
    
    // Getting my own matrix
    myMatrix = matrix;
    
    // Going through all the vertices and multiplying each by the input matrix.
    for (int i=0; i<size; i++)
    {
        // From Vertex to GLKVector3
        v.x = vertices[i].Position[0];
        v.y = vertices[i].Position[1];
        v.z = vertices[i].Position[2];
        v.w = 1;
        
        // Multiplying
        v = GLKMatrix4MultiplyVector4(myMatrix, v);
        
        // From GLKVector3 to Vertex
        Vertex vertex  = {{v.x,  v.y,  v.z},  {color.x,  color.y,  color.z, color.w}};
        vertices[i] = vertex;
    }
    
    // Associating grid's vertex and index buffers
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), vertices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, sizeof(indices), indices);
}

@end
