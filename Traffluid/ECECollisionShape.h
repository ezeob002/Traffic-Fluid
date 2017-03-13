//
//  ECECollision.h
//  ECE595
//
//  
#import <Foundation/Foundation.h>
#import "ECEParticle.h"


@interface ECECollisionShape : NSObject

- (void) resetInfo;

- (void) handleCollisionFor:(ECEParticle*)particle;

- (void) handleCollisionWithNOBounginFor:(ECEParticle*)particle;

- (void) handleOutsideCollisionFor:(ECEParticle*)particle;

@end
