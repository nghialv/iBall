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
}

@property(nonatomic, assign) float angleVelocity;
@property(nonatomic, assign) bool flipping;
@property(nonatomic, assign) bool invert;
@property(nonatomic, assign) GLKMatrix4 modelMatrix;

- (id)initWithAll:(GLKVector3)originPos andDirection:(GLKVector3)direction;
- (void) flip;
- (GLKVector3) getEndPointOfFlipper;
- (GLKVector3) getStartPointOfFlipper;
- (void) changeAngleVelocityDirection;
- (GLKVector3) getNormalVector;
- (float) getSpeed;
@end
