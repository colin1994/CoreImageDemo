//
//  MetalKernelViewController.m
//  CoreImageDemo
//
//  Created by Colin on 2018/7/3.
//  Copyright © 2018年 Colin. All rights reserved.
//

#import "MetalKernelViewController.h"
#import "MetalKernelFilter.h"

@interface MetalKernelViewController ()

@property (strong, nonatomic) MetalKernelFilter *vignetteFilter;
@property (strong, nonatomic) CIImage *inputImage;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation MetalKernelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 初始化 Filter
    self.vignetteFilter = [[MetalKernelFilter alloc] init];
    NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"vignetteImage" withExtension:@"jpg"];
    self.inputImage = [CIImage imageWithContentsOfURL:imageURL];
    [self.vignetteFilter setValue:_inputImage forKey:@"inputImage"];
    
    self.imageView.image = [UIImage imageWithCIImage:self.inputImage];
    
}

#pragma mark - Action
- (IBAction)alphaChanged:(UISlider *)sender {
    [self.vignetteFilter setValue:@(sender.value) forKey:@"inputAlpha"];
    CIImage *result = _vignetteFilter.outputImage;
    self.imageView.image = [UIImage imageWithCIImage:result];
}

@end
