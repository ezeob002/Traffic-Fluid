//
//  ECEParticlesGrid.h
//  ECE 595
//


#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ECEGlobal.h"
#import "ECEParticlesGrid.h"

@interface ECEParticlesKdTree : ECEParticlesGrid

- (void) resetInfo;

- (void) draw;

- (void) resetWithParticles:(NSMutableArray*)particles;

- (NSMutableArray*) findNearestNeighborsToPosition:(ECEParticle*)particle withRadius:(double)radius
;
@end
