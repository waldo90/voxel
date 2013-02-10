//
//  VXBlock.h
//  voxel
//
//  Created by Pat Smith on 10/02/2013.
//  Copyright (c) 2013 Pat Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VXVBO.h"

enum BlockType
{
	BlockType_Default = 0,
    
	BlockType_Grass,
	BlockType_Dirt,
	BlockType_Water,
	BlockType_Stone,
    BlockType_Wood,
    BlockType_Sand,
    
    BlockType_NumTypes,
};

@interface VXBlock : NSObject

@property(nonatomic)BOOL active;
@property(nonatomic)enum BlockType type;

@end
