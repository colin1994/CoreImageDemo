//
//  MetalKernelFilter.m
//  CoreImageDemo
//
//  Created by Colin on 2018/7/3.
//  Copyright © 2018年 Colin. All rights reserved.
//

#import "MetalKernelFilter.h"

@interface MetalKernelFilter () {
    CIImage  *inputImage;
    NSNumber *inputAlpha;
}

@end

@implementation MetalKernelFilter

static CIColorKernel *customKernel = nil;

- (instancetype)init {
    self = [super init];
    if (self) {
        if (customKernel == nil) {
NSURL *kernelURL = [[NSBundle mainBundle] URLForResource:@"default" withExtension:@"metallib"];
NSError *error;
NSData *data = [NSData dataWithContentsOfURL:kernelURL];
customKernel = [CIColorKernel kernelWithFunctionName:@"vignetteMetal"
                                fromMetalLibraryData:data
                                               error:&error];

            if (@available(iOS 11.0, *)) {
            }
        }
    }
    
    return self;
}

- (CIImage *)outputImage {
    CGRect dod = inputImage.extent;
    CGFloat radius = 0.5 * MAX(dod.size.width, dod.size.height);
    CIVector *center = [CIVector vectorWithX:dod.size.width / 2.0
                                           Y:dod.size.height / 2.0];
    
    return [customKernel applyWithExtent:dod roiCallback:^CGRect(int index, CGRect destRect) {
        return destRect;
    } arguments:@[inputImage, center, @(radius), inputAlpha ?: @(0.0)]];
}

@end
