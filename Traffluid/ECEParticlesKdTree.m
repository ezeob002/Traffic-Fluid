//
//  ECEParticlesGrid.m
//  ECE 595
//

#import "ECEParticlesKdTree.h"
#import "ECEParticlesKdTreeNode.h"
#import "ECEParticle.h"

@interface ECEParticlesKdTree ()
{
    /// Rootn node of the tree.
    ECEParticlesKdTreeNode* rootNode;
}

- (void) addPosition:(GLKVector3)_position;

@end

@implementation ECEParticlesKdTree

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
    rootNode = nil;
}

#pragma mark - Utils

/**
 * It resets the kd-tree with the positions of each particle in the input "particle".
 *
 * @param particles     Array with the particles which positions will be inserted into the kd-tree.
 * @return
 */
- (void) resetWithParticles:(NSMutableArray*)particles
{
    // Erasing kd-tree
    rootNode = nil;
    
    // Creating a new kd-tree with the new particles in the input array.
    for (int i=0; i<[particles count]; i++)
        [self addPosition:[((ECEParticle*)particles[i]) position]];
}

/**
 * It adds the input "position" position to the kd-tree.
 *
 * @param position     Position to be added to the kd-tree.
 * @return
 */
- (void) addPosition:(GLKVector3)_position
{
    if (rootNode)
        // Adding position to the root node
        [rootNode addPosition:_position];
    else
        // Creating root node.
        rootNode = [[ECEParticlesKdTreeNode alloc] initWithPosition:_position type:X_COMPONENT_NODE andParent:nil];
}

/**
 * It returns an array with the nearest neighbours of input particle "particle" within the range defined by input "radius".
 *
 * @param particle     The particle which position the nearest neighbouts will be looked for.
 * @param radius       The range within the nearest neighbours will be looked for.
 * @return an array with the nearest neighbours of input particle "particle" within the range defined by input "radius".
 */
- (NSMutableArray*) findNearestNeighborsToPosition:(ECEParticle*)particle withRadius:(double)radius
{
    NSMutableArray *r;
    
    // init array
    r = [[NSMutableArray alloc] init];
    
    return r;
}

#pragma mark - openGL

- (void) draw
{
    if (rootNode)
        [rootNode draw];
}

@end
