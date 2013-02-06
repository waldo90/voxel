//
//  VXBox.m
//  voxel
//
//  Created by Pat Smith on 05/02/2013.
//  Copyright (c) 2013 Pat Smith. All rights reserved.
//

#import "VXBox.h"
#import "VXVBO.h"

typedef struct {
    float pos[3];
    float col[4];
} Vurt;

@interface VXBox ()
{
    NSMutableData* _data;
}
@end

@implementation VXBox

- (id)init
{
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] initWithCapacity:sizeof(Vurt)*8];
    }
    return self;
}

@end
