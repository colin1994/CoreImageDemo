//
//  VignetteViewController.m
//  CoreImageDemo
//
//  Created by Colin on 16/10/11.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "VignetteViewController.h"
#import <GLKit/GLKit.h>
#import "VignetteFilter.h"

@interface VignetteViewController ()

@property (weak, nonatomic) IBOutlet GLKView *glkView;
@property (strong, nonatomic) CIContext *context;
@property (strong, nonatomic) VignetteFilter *vignetteFilter;
@property (assign, nonatomic) CGRect targetBounds;
@property (strong, nonatomic) CIImage *inputImage;


@end

@implementation VignetteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置 OpenGLES 渲染环境
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.glkView.context = eaglContext;
    self.context = [CIContext contextWithEAGLContext:eaglContext];
    
    // 初始化 Filter
    self.vignetteFilter = [[VignetteFilter alloc] init];
    NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"vignetteImage" withExtension:@"jpg"];
    self.inputImage = [CIImage imageWithContentsOfURL:imageURL];
    [self.vignetteFilter setValue:_inputImage forKey:@"inputImage"];
    
    [self.glkView layoutIfNeeded];
}

#pragma mark - Layout
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // 获取绘制区域
    self.targetBounds = [self aspectFit:_inputImage.extent
                                 toRect:CGRectMake(0.0, 0.0, _glkView.drawableWidth, _glkView.drawableHeight)];
    [self.context drawImage:_inputImage inRect:_targetBounds fromRect:_inputImage.extent];
    [self.glkView display];
}

#pragma mark - Action
- (IBAction)alphaChanged:(UISlider *)sender {
    [self.vignetteFilter setValue:@(sender.value) forKey:@"inputAlpha"];
    
    [self.context drawImage:_vignetteFilter.outputImage inRect:_targetBounds fromRect:_inputImage.extent];
    [self.glkView.context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - Private
/**
 获取实际显示区域

 @param fromRect 图片实际大小
 @param toRect   GLKView 显示区域

 @return Fit 后的实际显示区域
 */
- (CGRect)aspectFit:(CGRect)fromRect toRect:(CGRect)toRect {
    CGFloat fromAspectRatio = fromRect.size.width / fromRect.size.height;
    CGFloat toAspectRatio = toRect.size.width / toRect.size.height;
    
    CGRect fitRect = toRect;
    
    if (fromAspectRatio > toAspectRatio) {
        fitRect.size.height = toRect.size.width / fromAspectRatio;
        fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5;
    } else {
        fitRect.size.width = toRect.size.height  * fromAspectRatio;
        fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5;
    }
    
    return CGRectIntegral(fitRect);
}


@end
