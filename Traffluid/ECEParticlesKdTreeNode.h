//
//  ECEParticlesGridCell.h
//  ECE 595
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ECEParticlesKdTreeNode : NSObject

/// Position of the current node.
@property GLKVector3 position;

/// Type of the node. Possible values are: X_COMPONENT_NODE, Y_COMPONENT_NODE and Z_COMPONENT_NODE.
@property NSInteger typeOfNode;

/// Parent node of this node.
@property ECEParticlesKdTreeNode* parentNode;

/// Root node of the left subtree.
@property ECEParticlesKdTreeNode* leftSubtreeRootNode;

/// Root node of the right subtree.
@property ECEParticlesKdTreeNode* rightSubtreeRootNode;

- (id) initWithPosition:(GLKVector3)_position type:(NSInteger)type andParent:(ECEParticlesKdTreeNode*)_parent;

- (void) resetInfo;

- (void) draw;

- (void) addPosition:(GLKVector3)_position;

- (void) generatePlane;

@end
