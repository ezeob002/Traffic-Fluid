//
//  ECEGlobal.m
//  ECE 595
//

#import "ECEGlobal.h"
#import <GLKit/GLKit.h>

static GLenum renderType = GL_TRIANGLES;

NSInteger PARTICLE_TO_TEST_ID = -1;
NSArray*  NEIGHBOURS_OF_THE_PARTICLE_TO_TEST_ID = nil;

@implementation ECEGlobal

+ (GLenum) getRenderType
{
    return renderType;
}

+ (void) setRenderType:(GLenum)newRenderType
{
    renderType = newRenderType;
}

+ (void) setDefaultRenderType
{
    renderType = GL_TRIANGLES;
}

+ (int) getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

@end
