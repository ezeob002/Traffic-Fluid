//
//  ECESphere.m
//  ECE595
//

#import "ECESphere.h"
#import "ECEShape.h"

@implementation ECESphere

@synthesize center, radius, color, vertexBuffer, indexBuffer, normalsBuffer;

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

- (id) initWithCenter:(GLKVector3)_center andRadius:(double)_radius
{
    id selfSphere;
    
    selfSphere = [self init];
    
    // Update values
    [selfSphere updateWithCenter:_center andRadius:_radius];
    
    return selfSphere;
}

- (void) resetInfo
{
    [super resetInfo];
    
    // Init
    center          = GLKVector3Make(0, 0, 0);
    radius          = 1;
    color           = RED_COLOR;
    
    // Associating grid's vertex and index buffers
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // Updating cube with the default min and max.
    [self updateWithCenter:center andRadius:radius];
}

- (void) updateWithCenter:(GLKVector3)_center andRadius:(double)_radius
{
    int numSlices, numParallels, numVertices, numIndices;
    float angleStep;
    
    // init
    radius = _radius;
    numSlices = 8;
    numParallels = numSlices / 2;
    numVertices = ( numParallels + 1 ) * ( numSlices + 1 );
    numIndices = numParallels * numSlices * 6;
    angleStep = (2.0f * M_PI) / ((float) numSlices);
    
    for (int i = 0; i < numParallels + 1; i++)
    {
        for (int j = 0; j < numSlices + 1; j++)
        {
            float x, y, z;
            int vertex;
            
            // init
            vertex = ( i * (numSlices + 1) + j );

            // Vertex
            x = radius * sinf( angleStep * (float)i ) * sinf( angleStep * (float)j );
            y = radius * cosf( angleStep * (float)i );
            z = radius * sinf( angleStep * (float)i ) * cosf( angleStep * (float)j );
            Vertex v = {{x + _center.x, y + _center.y, z + _center.z},  {color.x, color.y, color.z, color.w}};
            
            // Setting new created vertex
            vertices[vertex] = v;
            
            // Normal
            x = x / radius;
            y = y / radius;
            z = z / radius;
            Vertex n = {{x, y, z},  {color.x, color.y, color.z, color.w}};
            
            // Setting new created normal
            normals[vertex] = n;
            
            // Texture coordinates
            x = (float) j / (float) numSlices;
            y = ( 1.0f - (float) i ) / (float) (numParallels - 1 );
            Vertex t = {{x, y}};
            
            // Setting new created texture coordinates
            texCoords[vertex] = t;
        }
    }
    
    // Generate the indices
    int index = 0;
    for (int i = 0; i < numParallels ; i++ )
    {
        for (int j = 0; j < numSlices; j++ )
        {
            indices[index]     = i * ( numSlices + 1 ) + j;
            indices[index + 1] = ( i + 1 ) * ( numSlices + 1 ) + j;
            indices[index + 2] = ( i + 1 ) * ( numSlices + 1 ) + ( j + 1 );
            indices[index + 3] = i * ( numSlices + 1 ) + j;
            indices[index + 4] = ( i + 1 ) * ( numSlices + 1 ) + ( j + 1 );
            indices[index + 5] = i * ( numSlices + 1 ) + ( j + 1 );
            index += 6;
        }
    }
    
    // Associating grid's vertex and index buffers
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), vertices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, sizeof(indices), indices);
    
     //glBindBuffer(GL_ARRAY_BUFFER, normalsBuffer);
     //glBufferSubData(GL_ARRAY_BUFFER_BINDING, 0, sizeof(normals), normals);
    
}

- (void) draw
{
    glutSolidSphere(0.05, 10, 10);
}

- (void) multiplyByMatrix:(GLKMatrix4)matrix
{
    
}

@end
