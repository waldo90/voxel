//
//  VXVoxelBox.m
//  voxel
//
//  Created by Pat Smith on 10/02/2013.
//  Copyright (c) 2013 Pat Smith. All rights reserved.
//

#import "VXVoxelBox.h"
#import <GLKit/GLKit.h>

GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    1.0f, -1.0f, -1.0f,        1.0f, 0.0f, 0.0f,
    1.0f, 1.0f, -1.0f,         1.0f, 0.0f, 0.0f,
    1.0f, -1.0f, 1.0f,         1.0f, 0.0f, 0.0f,
    1.0f, -1.0f, 1.0f,         1.0f, 0.0f, 0.0f,
    1.0f, 1.0f, -1.0f,         1.0f, 0.0f, 0.0f,
    1.0f, 1.0f, 1.0f,          1.0f, 0.0f, 0.0f,
    
    1.0f, 1.0f, -1.0f,         0.0f, 1.0f, 0.0f,
    -1.0f, 1.0f, -1.0f,        0.0f, 1.0f, 0.0f,
    1.0f, 1.0f, 1.0f,          0.0f, 1.0f, 0.0f,
    1.0f, 1.0f, 1.0f,          0.0f, 1.0f, 0.0f,
    -1.0f, 1.0f, -1.0f,        0.0f, 1.0f, 0.0f,
    -1.0f, 1.0f, 1.0f,         0.0f, 1.0f, 0.0f,
    
    -1.0f, 1.0f, -1.0f,        -1.0f, 0.0f, 0.0f,
    -1.0f, -1.0f, -1.0f,       -1.0f, 0.0f, 0.0f,
    -1.0f, 1.0f, 1.0f,         -1.0f, 0.0f, 0.0f,
    -1.0f, 1.0f, 1.0f,         -1.0f, 0.0f, 0.0f,
    -1.0f, -1.0f, -1.0f,       -1.0f, 0.0f, 0.0f,
    -1.0f, -1.0f, 1.0f,        -1.0f, 0.0f, 0.0f,
    
    -1.0f, -1.0f, -1.0f,       0.0f, -1.0f, 0.0f,
    1.0f, -1.0f, -1.0f,        0.0f, -1.0f, 0.0f,
    -1.0f, -1.0f, 1.0f,        0.0f, -1.0f, 0.0f,
    -1.0f, -1.0f, 1.0f,        0.0f, -1.0f, 0.0f,
    1.0f, -1.0f, -1.0f,        0.0f, -1.0f, 0.0f,
    1.0f, -1.0f, 1.0f,         0.0f, -1.0f, 0.0f,
    
    1.0f, 1.0f, 1.0f,          0.0f, 0.0f, 1.0f,
    -1.0f, 1.0f, 1.0f,         0.0f, 0.0f, 1.0f,
    1.0f, -1.0f, 1.0f,         0.0f, 0.0f, 1.0f,
    1.0f, -1.0f, 1.0f,         0.0f, 0.0f, 1.0f,
    -1.0f, 1.0f, 1.0f,         0.0f, 0.0f, 1.0f,
    -1.0f, -1.0f, 1.0f,        0.0f, 0.0f, 1.0f,
    
    1.0f, -1.0f, -1.0f,        0.0f, 0.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,       0.0f, 0.0f, -1.0f,
    1.0f, 1.0f, -1.0f,         0.0f, 0.0f, -1.0f,
    1.0f, 1.0f, -1.0f,         0.0f, 0.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,       0.0f, 0.0f, -1.0f,
    -1.0f, 1.0f, -1.0f,        0.0f, 0.0f, -1.0f
};

@implementation VXVoxelBox

- (id)init
{
    self = [super initWithVertexSize:sizeof(GLKVector3)];
    if (self) {
    }
    return self;
}

-(long)vertexDataSize
{
    return sizeof(gCubeVertexData);
}
/* HACK - maybe one day we'll read data in and put it in the buffer but for now - shortcut to stack data */
- (const void *)vertexData
{
    return gCubeVertexData;
}




@end
