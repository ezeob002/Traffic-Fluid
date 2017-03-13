//
//  ECEPlane.m
//  ECE 595
//
//  
#import "ECEAxisAlignedPlane.h"
@class ECEParticlesKdTreeNode;

#define PLANE_SIZE 2.0

@implementation ECEAxisAlignedPlane

@synthesize position, color, vertexBuffer, indexBuffer;

- (id) initWithPosition:(GLKVector3)_position
{
    id selfPlane;
    
    selfPlane = [self init];
    
    // Update values
    [selfPlane updateWithPosition:_position andTypeOfComponent:X_COMPONENT_NODE];
    
    return selfPlane;
}

- (void) resetInfo
{
    [super resetInfo];
    
    // Init
    color           = RED_COLOR;
    self.renderType = GL_LINE_STRIP;
    
    // Associating grid's vertex and index buffers
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    // Updating cube with the default min and max.
    [self updateWithPosition:position andTypeOfComponent:X_COMPONENT_NODE];
}

- (void) updateWithPosition:(GLKVector3)_position andTypeOfComponent:(NSInteger)component
{
    // Setting min and max values
    position = _position;
    
    // Creating vertex buffer from position value.
    if (component == X_COMPONENT_NODE)
    {
        //
        // (1) Creating Vertices
        //
        Vertex v1 = {{position.x, position.y - PLANE_SIZE, position.z + PLANE_SIZE},
            {color.x, color.y, color.z, color.w}};
        Vertex v2 = {{position.x, position.y + PLANE_SIZE, position.z + PLANE_SIZE},
            {color.x, color.y, color.z, color.w}};
        Vertex v3 = {{position.x, position.y - PLANE_SIZE, position.z - PLANE_SIZE},
            {color.x, color.y, color.z, color.w}};
        Vertex v4 = {{position.x, position.y + PLANE_SIZE, position.z - PLANE_SIZE},
            {color.x, color.y, color.z, color.w}};
        
        //
        // (2) Creating vertex buffer
        //
        vertices[0] = v1;
        vertices[1] = v2;
        vertices[2] = v4;
        vertices[3] = v3;
        
        //
        // (3) Creating indices buffer
        //
        indices[0]  = 0;
        indices[1]  = 1;
        indices[2]  = 2;
        indices[3]  = 3;
        indices[4]  = 0;
    }
    else if (component == Y_COMPONENT_NODE)
    {
        //
        // (1) Creating Vertices
        //
        Vertex v1 = {{position.x - PLANE_SIZE, position.y, position.z + PLANE_SIZE},
            {color.x, color.y, color.z, color.w}};
        Vertex v2 = {{position.x + PLANE_SIZE, position.y, position.z + PLANE_SIZE},
            {color.x, color.y, color.z, color.w}};
        Vertex v3 = {{position.x - PLANE_SIZE, position.y, position.z - PLANE_SIZE},
            {color.x, color.y, color.z, color.w}};
        Vertex v4 = {{position.x + PLANE_SIZE, position.y, position.z - PLANE_SIZE},
            {color.x, color.y, color.z, color.w}};
        
        //
        // (2) Creating vertex buffer
        //
        vertices[0] = v1;
        vertices[1] = v2;
        vertices[2] = v4;
        vertices[3] = v3;
        
        //
        // (3) Creating indices buffer
        //
        indices[0]  = 0;
        indices[1]  = 1;
        indices[2]  = 2;
        indices[3]  = 3;
        indices[4]  = 0;
    }
    else if (component == Z_COMPONENT_NODE)
    {
        //
        // (1) Creating Vertices
        //
        Vertex v1 = {{position.x - PLANE_SIZE, position.y + PLANE_SIZE, position.z},
            {color.x, color.y, color.z, color.w}};
        Vertex v2 = {{position.x + PLANE_SIZE, position.y + PLANE_SIZE, position.z},
            {color.x, color.y, color.z, color.w}};
        Vertex v3 = {{position.x - PLANE_SIZE, position.y - PLANE_SIZE, position.z},
            {color.x, color.y, color.z, color.w}};
        Vertex v4 = {{position.x + PLANE_SIZE, position.y - PLANE_SIZE, position.z},
            {color.x, color.y, color.z, color.w}};
        
        //
        // (2) Creating vertex buffer
        //
        vertices[0] = v1;
        vertices[1] = v2;
        vertices[2] = v4;
        vertices[3] = v3;
        
        //
        // (3) Creating indices buffer
        //
        indices[0]  = 0;
        indices[1]  = 1;
        indices[2]  = 2;
        indices[3]  = 3;
        indices[4]  = 0;
    }
    
    // Associating grid's vertex and index buffers
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), vertices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, sizeof(indices), indices);
}

#pragma mark - openGL

- (void) draw
{
    // Associating buffers
    glBindBuffer(GL_ARRAY_BUFFER,         vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    
    // Poiting to the data
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
    
    // Drawing
    glDrawElements(self.renderType, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_BYTE, 0);
}

@end
