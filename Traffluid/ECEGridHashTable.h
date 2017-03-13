//
//  ECEHashTable.h
//  ECE595
//


#import <Foundation/Foundation.h>
#import "ECEParticlesGrid.h"
#import "ECEFluidMaterial.h"

extern NSMutableArray* lastNeighbours;

@interface ECEGridHashTable : ECEParticlesGrid

@property NSMutableArray* arrayfHashes;

- (id) initWithNumberOfParticles:(NSInteger)_numOfParticles
                andFluidMaterial:(ECEFluidMaterial*)fluidMaterial;

- (void) resetInfo;

- (void) draw;

- (void) resetWithParticles:(NSMutableArray*)particles;

- (void) findNearestNeighborsToPosition:(ECEParticle*)particle withRadius:(double)radius;

- (void) removeParticle:(ECEParticle*)particle;

@end
