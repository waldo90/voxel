//
//  VXBox.h
//  voxel
//
//  Created by Pat Smith on 05/02/2013.
//  Copyright (c) 2013 Pat Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "VXVBO.h"

struct _InterleavingVertexData
{
    GLKVector3 vertices;    //vertices
//    GLKVector3 normal;      //normals
    GLKVector4 color;       //color
    //    GLKVector2 texture;     //texture coordinates
};

typedef struct _InterleavingVertexData InterleavingVertexData;

@interface VXBox : NSObject
@property (strong, readonly) VXVBO* vbo;
- (const void *)vertexData;


@end
