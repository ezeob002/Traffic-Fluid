//
//  ECECollisionOOBox.h
//  ECE595
//
// 
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ECECollisionShape.h"
#import "ECECube.h"

@interface ECECollisionOOBox : ECECollisionShape

/// The center of the Oriented Bounding Box (OOB).
@property GLKVector3 center;

/// The u axis of the OOB coordinate system.
@property GLKVector3 u;

/// The v axis of the OOB coordinate system.
@property GLKVector3 v;

/// The w axis of the OOB coordinate system.
@property GLKVector3 w;

/// Half the length of the box in the u axis.
@property double halfU;

/// Half the length of the box in the v axis.
@property double halfV;

/// Half the length of the box in the w axis.
@property double halfW;

-(id) initWithCenter:(GLKVector3)_center
               axisU:(GLKVector3)_u
               axisV:(GLKVector3)_v
               axisW:(GLKVector3)_w
               halfU:(double)_halfU
               halfV:(double)_halfV
               halfW:(double)_halfW;

-(id) initFromCube:(ECECube*)cube;

@end
