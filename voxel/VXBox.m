//
//  VXBox.m
//  voxel
//
//  Created by Pat Smith on 05/02/2013.
//  Copyright (c) 2013 Pat Smith. All rights reserved.
//

#import "VXBox.h"


@interface VXBox ()
{
}
@end

@implementation VXBox

- (id)init
{
    self = [super init];
    if (self) {
        _vbo = [[VXVBO alloc] initWithVertexSize:sizeof(InterleavingVertexData)];
        InterleavingVertexData vertex;
        /*
        {{ 1,-1, 1}, {1,0,0,1}},
        {{ 1, 1, 1}, {1,0,0,1}},
        {{-1, 1, 1}, {0.5,0,0.5,1}},
        {{-1,-1, 1}, {0.5,0,0.5,1}},
        {{ 1,-1,-1}, {1,0,0,1}},
        {{ 1, 1,-1}, {1,0,0,1}},
        {{-1, 1,-1}, {1,0,0,1}},
        {{-1,-1,-1}, {1,0,1,1}}
        */
        vertex.vertices = GLKVector3Make(1, -1, 1);
        vertex.color = GLKVector4Make(1, 0, 0, 1);
        [_vbo pushVertex:&vertex];
        vertex.vertices = GLKVector3Make(1, 1, 1);
        vertex.color = GLKVector4Make(0, 1, 0, 1);
        [_vbo pushVertex:&vertex];
        vertex.vertices = GLKVector3Make(-1, 1, 1);
        vertex.color = GLKVector4Make(0.5, 0, 0.5, 1);
        [_vbo pushVertex:&vertex];
        vertex.vertices = GLKVector3Make(-1, -1, 1);
        vertex.color = GLKVector4Make(0.5, 0, 0.5, 1);
        [_vbo pushVertex:&vertex];
        vertex.vertices = GLKVector3Make(1, -1, -1);
        vertex.color = GLKVector4Make(1, 0, 0, 1);
        [_vbo pushVertex:&vertex];
        vertex.vertices = GLKVector3Make(1, 1, -1);
        vertex.color = GLKVector4Make(1, 0, 0, 1);
        [_vbo pushVertex:&vertex];
        vertex.vertices = GLKVector3Make(-1, 1, -1);
        vertex.color = GLKVector4Make(1, 0, 0, 1);
        [_vbo pushVertex:&vertex];
        vertex.vertices = GLKVector3Make(-1, -1, -1);
        vertex.color = GLKVector4Make(1, 0, 1, 1);
        [_vbo pushVertex:&vertex];
    }
    return self;
}

- (const void *)vertexData
{
    NSLog(@"Size of GLKVector3: %ld", sizeof(GLKVector3));
    NSLog(@"Size of GLKVector4: %ld", sizeof(GLKVector4));
    NSLog(@"Size of InterleavingVertexData: %ld", sizeof(InterleavingVertexData));
    NSLog(@"Size of buffer: %ld", (unsigned long)_vbo.buffer.length);
    NSLog(@"Expected buffer size: %ld", (sizeof(GLKVector3)+sizeof(GLKVector4))*8);
    NSLog(@"%@", _vbo.buffer);
    return [_vbo.buffer bytes];
}

@end
