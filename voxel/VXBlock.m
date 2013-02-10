//
//  VXBlock.m
//  voxel
//
//  Created by Pat Smith on 10/02/2013.
//  Copyright (c) 2013 Pat Smith. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "VXBlock.h"

@implementation VXBlock
- (id)init
{
    self = [super init];
    if (self) {
        self.active = TRUE;
        self.type = BlockType_Default;
    }
    return self;
}

@end
