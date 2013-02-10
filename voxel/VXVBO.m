//
//  VXVBO.m
//  voxel
//
//  Created by Pat Smith on 06/02/2013.
//  Copyright (c) 2013 Pat Smith. All rights reserved.
//

#import "VXVBO.h"

#pragma mark -
#pragma mark InterleavingVertexData

/*
//vertex buffer object struct
struct InterleavingVertexData
{
    GLKVector3 vertices;    //vertices
    GLKVector3 normal;      //normals
    GLKVector4 color;       //color
    GLKVector2 texture;     //texture coordinates
};
typedef struct InterleavingVertexData InterleavingVertexData;
*/
/*
#pragma mark -
#pragma mark VertexIndices

//vertex indices struct
struct VertexIndices
{
    GLuint a;               //vertex indices
    GLuint b;
    GLuint c;
};
typedef struct VertexIndices VertexIndices;


//create and return a vertex index with specified indices
static inline VertexIndices VertexIndicesMake(GLuint a, GLuint b, GLuint c)
{
    //declare vertex indices
    VertexIndices vertexIndices;
    
    //set indices
    vertexIndices.a = a;
    vertexIndices.b = b;
    vertexIndices.c = c;
    
    //return vertex indices
    return vertexIndices;
}
*/
#pragma mark -
#pragma mark VertexBuffer -> VXVBO


@interface VXVBO ()
{
 //   NSMutableData* _data;
    NSUInteger     _vertex_size;
}
@end

@implementation VXVBO

-(id)initWithVertexSize:(NSUInteger)vertex_size
{
    self = [super init];
    if (self) {
        _vertex_size  = vertex_size;
        _buffer = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)pushVertex:(const void *)vertex
{
    [_buffer appendBytes:vertex length:_vertex_size];
}

-(long)vertexDataSize
{
    return [_buffer length];
}
- (const void *)vertexData
{
    return [_buffer bytes];
}


@end