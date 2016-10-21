//
//  VignetteFilter.m
//  CoreImageDemo
//
//  Created by Colin on 16/10/11.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "VignetteFilter.h"

@interface VignetteFilter () {
    CIImage  *inputImage;
    NSNumber *inputAlpha;
}

@end

@implementation VignetteFilter

static CIColorKernel *customKernel = nil;

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        if (customKernel == nil)
        {
            NSBundle *bundle = [NSBundle bundleForClass: [self class]];
            NSURL *kernelURL = [bundle URLForResource:@"Vignette" withExtension:@"cikernel"];
            
            NSError *error;
            NSString *kernelCode = [NSString stringWithContentsOfURL:kernelURL
                                                            encoding:NSUTF8StringEncoding error:&error];
            if (kernelCode == nil) {
                NSLog(@"Error loading kernel code string in %@\n%@",
                      NSStringFromSelector(_cmd),
                      [error localizedDescription]);
                abort();
            }
            
            NSArray *kernels = [CIColorKernel kernelsWithString:kernelCode];
            customKernel = [kernels objectAtIndex:0];
        }
    }
    
    return self;
}

- (CIImage *)outputImage
{
    CGRect dod = inputImage.extent;
    CGFloat radius = 0.5 * MAX(dod.size.width, dod.size.height);
    CIVector *center = [CIVector vectorWithX:dod.size.width / 2.0
                                           Y:dod.size.height / 2.0];
    
    return [customKernel applyWithExtent:dod roiCallback:^CGRect(int index, CGRect destRect) {
        return destRect;
    } arguments:@[inputImage, center, @(radius), inputAlpha ?: @(0.0)]];
}

@end
