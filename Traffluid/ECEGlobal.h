//
//  ECEGlobal.h
//  ECE 595
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#define RED_COLOR       GLKVector4Make(1, 0, 0, 1)
#define GREEN_COLOR     GLKVector4Make(0, 1, 0, 1)
#define BLUE_COLOR      GLKVector4Make(0, 0, 1, 1)
#define WHITE_COLOR     GLKVector4Make(1, 1, 1, 1)
#define BLACK_COLOR     GLKVector4Make(0, 0, 0, 1)
#define YELLOW_COLOR    GLKVector4Make(1, 1, 0, 1)
#define ORANGE_COLOR    GLKVector4Make(1, 0.26, 0, 1)

static const NSInteger X_COMPONENT_NODE = 0;
static const NSInteger Y_COMPONENT_NODE = 1;
static const NSInteger Z_COMPONENT_NODE = 2;

extern NSInteger PARTICLE_TO_TEST_ID;
extern NSArray*  NEIGHBOURS_OF_THE_PARTICLE_TO_TEST_ID;

/// Vertex object with position and color.
typedef struct
{
    float Position[3];
    float Color[4];
    
} Vertex;

@interface ECEGlobal : NSObject

+ (GLenum) getRenderType;

+ (void) setRenderType:(GLenum)newRenderType;

+ (void) setDefaultRenderType;

+ (int) getRandomNumberBetween:(int)from to:(int)to;

@end
