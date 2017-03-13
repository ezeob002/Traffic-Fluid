//
//  ECEGrid.m
//  Traffluid
//


#import "ECEGrid.h"
#import <OpenGL/OpenGL.h>
#import <GLUT/GLUT.h>

static const int W      = 10;
static const int N      = 8;

Vertex GridVertices[4 * N];

GLubyte GridIndices[4 * (N + 1)];

@implementation ECEGrid

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
    [super resetInfo];

    [self createGridVerticesAndIndices];
}

#pragma mark - Utils

- (void) createGridVerticesAndIndices
{
    CGFloat delta, wDiv2;
    int lastIndex, lastIndex2;
    
    // init
    delta = ((CGFloat)W) / ((CGFloat)N);
    wDiv2 = ((CGFloat)W) / 2.0;
    lastIndex = 0;
    lastIndex2 = 0;
    
    // Creating lines along the x axis
    for (int i=0; i<2 * (N + 1); i += 2)
    {
        Vertex v1 = {{ wDiv2, 0, wDiv2 - (i / 2) * delta},  {0, 0, 0, 1}};
        Vertex v2 = {{-wDiv2, 0, wDiv2 - (i / 2) * delta},  {0, 0, 0, 1}};
        
        GridVertices[i]     = v1;
        GridVertices[i + 1] = v2;
        
        GridIndices[i]     = i;
        GridIndices[i + 1] = i + 1;
        
        lastIndex =  i + 1;
    }
    
    // Creating lines along the z axis
    for (int i=(lastIndex + 1); i< 4 * N; i += 2)
    {
        NSInteger ii;
        
        ii = i - lastIndex + 1;
        
        Vertex v1 = {{wDiv2 - (ii / 2) * delta, 0,   wDiv2},  {0, 0, 0, 1}};
        Vertex v2 = {{wDiv2 - (ii / 2) * delta, 0, - wDiv2},  {0, 0, 0, 1}};
        
        GridVertices[i]     = v1;
        GridVertices[i + 1] = v2;
        
        GridIndices[i]     = i;
        GridIndices[i + 1] = i + 1;
        
        lastIndex2 =  i + 1;
    }
    
    // Creating the last indices
    GridIndices[lastIndex2 + 1]  = 0;
    GridIndices[lastIndex2 + 2]  = 2 * (N);
    GridIndices[lastIndex2 + 3]  = 1;
    GridIndices[lastIndex2 + 4]  = 2 * (N) + 1;
    
    // Creating grid's vertex and index buffers
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GridVertices), GridVertices, GL_STATIC_DRAW);
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GridIndices), GridIndices, GL_STATIC_DRAW);
}

- (void) draw
{
    glBindBuffer(GL_ARRAY_BUFFER,         vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Position));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *) offsetof(Vertex, Color));
    
    glDrawElements(GL_LINE_STRIP, sizeof(GridIndices)/sizeof(GridIndices[0]), GL_UNSIGNED_BYTE, 0);
}

@end
