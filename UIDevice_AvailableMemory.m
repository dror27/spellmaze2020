//
//  UIDevice_AvailableMemory.m
//  Board3
//
//  Created by Dror Kessler on 8/7/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "UIDevice_AvailableMemory.h"

// Put this in UIDeviceAdditions.m
#include <sys/sysctl.h>  
#include <mach/mach.h>

@implementation UIDevice (AvailableMemory)

- (double)availableMemory {
	vm_statistics_data_t vmStats;
	mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
	kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	
	if(kernReturn != KERN_SUCCESS) {
		return NSNotFound;
	}
	
	return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}

@end
