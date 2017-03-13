//
//  ECEParticlesGridCell.m
//  ECE 595
//

#import "ECEParticlesKdTreeNode.h"
#import "ECEAxisAlignedPlane.h"

@interface ECEParticlesKdTreeNode ()
{
    /// Plane to be drawn into the scene that represents the current node.
    ECEAxisAlignedPlane *plane;
}

@end

@implementation ECEParticlesKdTreeNode

@synthesize position, parentNode, leftSubtreeRootNode, rightSubtreeRootNode, typeOfNode;

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
 * It initializes with the input values all the members of this class.
 *
 * @param _position     Position to be set to the instance of this class to be returned.
 * @param type          Type to be set to the instance of this class to be returned. Possible values are: FIRST_COMPONENT_NODE, SECOND_COMPONENT_NODE and THIRD_COMPONENT_NODE.
 * @return
 */
- (id) initWithPosition:(GLKVector3)_position type:(NSInteger)type andParent:(ECEParticlesKdTreeNode*)_parent
{
    ECEParticlesKdTreeNode *me;
    
    // init
    me = [self init];
    
    // Setting input values
    me.position   = _position;
    me.typeOfNode = type;
    me.parentNode = _parent;
    [me generatePlane];
    
    return me;
}

/**
 * It gives the default value to all the members in this class.
 *
 * @param
 * @return
 */
- (void) resetInfo
{
    position             = GLKVector3Make(0.0, 0.0, 0.0);
    parentNode           = nil;
    leftSubtreeRootNode  = nil;
    rightSubtreeRootNode = nil;
    typeOfNode           = X_COMPONENT_NODE;
    plane                = [[ECEAxisAlignedPlane alloc] init];
}

#pragma mark - Utils

/**
 * It adds the input "position" position to the kd-tree.
 *
 * @param position     Position to be added to the kd-tree.
 * @return
 */
- (void) addPosition:(GLKVector3)_position
{
    if (typeOfNode == X_COMPONENT_NODE)
    {
        if (position.x < _position.x)
        {
            if (leftSubtreeRootNode)
                // Adding position to the left subtree
                [leftSubtreeRootNode addPosition:_position];
            else
                // Creating left subtree with the given position.
                leftSubtreeRootNode = [[ECEParticlesKdTreeNode alloc] initWithPosition:_position type:Y_COMPONENT_NODE andParent:self];
        }
        else
        {
            if (rightSubtreeRootNode)
                // Adding position to the right subtree
                [rightSubtreeRootNode addPosition:_position];
            else
                // Creating right subtree with the given position.
                rightSubtreeRootNode = [[ECEParticlesKdTreeNode alloc] initWithPosition:_position type:Y_COMPONENT_NODE andParent:self];
        }
    }
    else if (typeOfNode == Y_COMPONENT_NODE)
    {
        if (position.y < _position.y)
        {
            if (leftSubtreeRootNode)
                // Adding position to the left subtree
                [leftSubtreeRootNode addPosition:_position];
            else
                // Creating left subtree with the given position.
                leftSubtreeRootNode = [[ECEParticlesKdTreeNode alloc] initWithPosition:_position type:Z_COMPONENT_NODE andParent:self];
        }
        else
        {
            if (rightSubtreeRootNode)
                // Adding position to the right subtree
                [rightSubtreeRootNode addPosition:_position];
            else
                // Creating right subtree with the given position.
                rightSubtreeRootNode = [[ECEParticlesKdTreeNode alloc] initWithPosition:_position type:Z_COMPONENT_NODE andParent:self];
        }
    }
    else if (typeOfNode == Z_COMPONENT_NODE)
    {
        if (position.z < _position.z)
        {
            if (leftSubtreeRootNode)
                // Adding position to the left subtree
                [leftSubtreeRootNode addPosition:_position];
            else
                // Creating left subtree with the given position.
                leftSubtreeRootNode = [[ECEParticlesKdTreeNode alloc] initWithPosition:_position type:X_COMPONENT_NODE andParent:self];
        }
        else
        {
            if (rightSubtreeRootNode)
                // Adding position to the right subtree
                [rightSubtreeRootNode addPosition:_position];
            else
                // Creating right subtree with the given position.
                rightSubtreeRootNode = [[ECEParticlesKdTreeNode alloc] initWithPosition:_position type:X_COMPONENT_NODE andParent:self];
        }
    }
}

/**
 * It creates the plane to be drawn into the scene (to represent this node) based on this node's position.
 *
 * @param
 * @return
 */
- (void) generatePlane
{
    if (typeOfNode == X_COMPONENT_NODE)
        plane.color = RED_COLOR;
    else if (typeOfNode == Y_COMPONENT_NODE)
        plane.color = GREEN_COLOR;
    else if (typeOfNode == Z_COMPONENT_NODE)
        plane.color = BLUE_COLOR;
    
    [plane updateWithPosition:position andTypeOfComponent:typeOfNode];
}

#pragma mark - openGL

- (void) draw
{
    if (plane)
        [plane draw];
    
    // Drawing children
    if (leftSubtreeRootNode)
        [leftSubtreeRootNode draw];
    if (rightSubtreeRootNode)
        [rightSubtreeRootNode draw];
}

@end
