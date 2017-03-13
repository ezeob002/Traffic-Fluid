//
//  ECEParticlesGrid.h
//  ECE595
//


#import <Foundation/Foundation.h>
#import "ECEParticle.h"

@interface ECEParticlesGrid : NSObject

@property NSInteger numberOfParticles;

- (void) resetInfo;

- (void) draw;

- (void) resetWithParticles:(NSMutableArray*)particles;

- (NSMutableArray*) findNearestNeighborsToPosition:(ECEParticle*)particle withRadius:(double)radius
;

- (void) removeParticle:(ECEParticle*)particle;

@end
