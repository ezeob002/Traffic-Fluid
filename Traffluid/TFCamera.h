//
//  TFCamera.h
//  Traffluid


#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface TFCamera : NSObject

@property GLKVector3 position;

@property GLKVector3 lookAt;

@property GLKVector3 up;

@property CGFloat theta;

@property CGFloat phi;

@property CGFloat distanceToLookAtPoint;

- (void) resetInfo;

- (void) setInitialPosition:(GLKVector3)pos
              initialLookAt:(GLKVector3)look
                  initialUp:(GLKVector3)n;

- (void) updatePositionAndNormal;

- (void) addToTheta:(CGFloat)value;

- (void) addToPhi:(CGFloat)value;

- (void) zoomCameraByScalar:(CGFloat)scalar;

- (void) moveCameraHorizontallyByScalar:(CGFloat)scalar;

- (void) moveCameraVerticallyByScalar:(CGFloat)scalar;

@end
