//
//  MosaicFilter.m
//  CoreImageDemo
//
//  Created by Colin on 16/10/12.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "MosaicFilter.h"

@interface MosaicFilter () {
    CIImage  *inputImage;
    CIImage  *inputMaskImage;
    NSNumber *inputRadius;
    CIVector *inputPoint;
}

@end

@implementation MosaicFilter

static CIKernel *customKernel = nil;

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        if (customKernel == nil)
        {
            NSBundle *bundle = [NSBundle bundleForClass: [self class]];
            NSURL *kernelURL = [bundle URLForResource:@"Mosaic" withExtension:@"cikernel"];
            
            NSError *error;
            NSString *kernelCode = [NSString stringWithContentsOfURL:kernelURL
                                                            encoding:NSUTF8StringEncoding error:&error];
            if (kernelCode == nil) {
                NSLog(@"Error loading kernel code string in %@\n%@",
                      NSStringFromSelector(_cmd),
                      [error localizedDescription]);
                abort();
            }
            
            NSArray *kernels = [CIKernel kernelsWithString:kernelCode];
            customKernel = [kernels objectAtIndex:0];
        }
    }
    
    return self;
}

- (CIImage *)outputImage
{
    CGRect dod = inputImage.extent;
    
    if (!inputPoint) {
        return inputImage;
    }
    return [customKernel applyWithExtent:dod roiCallback:^CGRect(int index, CGRect destRect) {
        if (index == 0) {
            return inputImage.extent;
        }
        else
        {
            return inputMaskImage.extent;
        }
    } arguments:@[inputImage, inputMaskImage, inputRadius, inputPoint, @(inputMaskImage.extent.size.width), @(inputMaskImage.extent.size.height)]];
}

@end
