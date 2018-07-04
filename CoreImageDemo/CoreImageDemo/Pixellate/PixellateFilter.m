//
//  PixellateFilter.m
//  CoreImageDemo
//
//  Created by Colin on 16/10/11.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "PixellateFilter.h"

@interface PixellateFilter () {
    CIImage  *inputImage;
    NSNumber *inputRadius;
}

@end

@implementation PixellateFilter

static CIWarpKernel *customKernel = nil;

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        if (customKernel == nil)
        {
            NSBundle *bundle = [NSBundle bundleForClass: [self class]];
            NSURL *kernelURL = [bundle URLForResource:@"Pixellate" withExtension:@"cikernel"];
            
            NSError *error;
            NSString *kernelCode = [NSString stringWithContentsOfURL:kernelURL
                                                            encoding:NSUTF8StringEncoding error:&error];
            if (kernelCode == nil) {
                NSLog(@"Error loading kernel code string in %@\n%@",
                      NSStringFromSelector(_cmd),
                      [error localizedDescription]);
                abort();
            }
            
            NSArray *kernels = [CIWarpKernel kernelsWithString:kernelCode];
            customKernel = [kernels objectAtIndex:0];
        }
    }
    
    return self;
}

- (CIImage *)outputImage
{
    CGRect dod = inputImage.extent;
    return [customKernel applyWithExtent:dod roiCallback:^CGRect(int index, CGRect destRect) {
        return destRect;
    } inputImage:inputImage arguments:@[inputRadius]];
}

@end
