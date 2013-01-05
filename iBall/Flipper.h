//
//  Flipper.h
//  iBall
//
//  Created by iNghia on 12/31/12.
//  Copyright (c) 2012 iNghia. All rights reserved.
//

#import "Cube.h"

@interface Flipper : Cube
{
    float angleVelocity;
    bool flipping;
    bool invert;
    GLKMatrix4 modelMatrix;
    float minAngle;
    float maxAngle;
}

@property(nonatomic, assign) float angleVelocity;
@property(nonatomic, assign) bool flipping;
@property(nonatomic, assign) bool invert;
@property(nonatomic, assign) GLKMatrix4 modelMatrix;
@property(nonatomic, assign) float minAngle;
@property(nonatomic, assign) float maxAngle;

- (id)initWithAll:(GLKVector3)originPos andDirection:(GLKVector3)direction andOriginDirection:(int)originDirection;
- (void) flip;
- (GLKVector3) getEndPointOfFlipper;
- (GLKVector3) getStartPointOfFlipper;
- (GLKVector3) getCenterPointOfFlipper;

- (void) changeAngleVelocityDirection;
- (GLKVector3) getNormalVector;
- (float) getSpeed;
@end
