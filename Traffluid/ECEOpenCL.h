//
//  ECEOpenCL.h
//  Traffluid
//

#import <Foundation/Foundation.h>
#import <OpenCL/OpenCL.h>

@interface ECEOpenCL : NSObject

+ (ECEOpenCL *) sharedInstance;

- (void) resetInfo;

- (int) initOpenCL;

- (void) displayPlatformsInfo;

@end
