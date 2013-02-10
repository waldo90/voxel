//
//  VXVBO.h
//  voxel
//
//  Created by Pat Smith on 06/02/2013.
//  Copyright (c) 2013 Pat Smith. All rights reserved.
//

#import <Foundation/Foundation.h>


/*

AAAABBBCCC
*/
@interface VXVBO : NSObject
@property (strong, readonly) NSMutableData* buffer;

-(id)initWithVertexSize:(NSUInteger)vertex_size;

- (void)pushVertex:(const void*)vertex;

-(long)vertexDataSize;
- (const void *)vertexData;



@end
