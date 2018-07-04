//
//  MosaicViewController.m
//  CoreImageDemo
//
//  Created by Colin on 16/10/12.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "MosaicViewController.h"
#import <GLKit/GLKit.h>
#import "MosaicFilter.h"

@interface MosaicViewController ()

@property (weak, nonatomic) IBOutlet GLKView *glkView;
@property (strong, nonatomic) CIContext *context;
@property (strong, nonatomic) MosaicFilter *mosaicFilter;
@property (assign, nonatomic) CGRect targetBounds;
@property (strong, nonatomic) CIImage *inputImage;

@end

@implementation MosaicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置 OpenGLES 渲染环境
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.glkView.context = eaglContext;
    self.context = [CIContext contextWithEAGLContext:eaglContext];
    
    // 初始化 Filter
    self.mosaicFilter = [[MosaicFilter alloc] init];
    NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"mosaicImage" withExtension:@"jpg"];
    self.inputImage = [CIImage imageWithContentsOfURL:imageURL];
    CIImage *maskImage = [[CIImage alloc] initWithImage:[UIImage imageNamed:@"mosaic_asset_2"]];
    
    [self.mosaicFilter setValue:_inputImage forKey:@"inputImage"];
    [self.mosaicFilter setValue:maskImage forKey:@"inputMaskImage"];
    [self.mosaicFilter setValue:@(35.f) forKey:@"inputRadius"];
    
    [self.glkView layoutIfNeeded];
    [self viewDidLayoutSubviews];
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
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:_glkView];
    point.y = _glkView.frame.size.height - point.y;
    point = [self converPointToImagePoint:point];
    CIVector *pVector = [CIVector vectorWithCGPoint:point];

    CGImageRef cgImage = [self.context createCGImage:self.mosaicFilter.outputImage fromRect:[self.mosaicFilter.outputImage extent]];
    self.inputImage = [CIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);

    [self.mosaicFilter setValue:_inputImage forKey:@"inputImage"];
    [self.mosaicFilter setValue:pVector forKey:@"inputPoint"];
    [self.context drawImage:_mosaicFilter.outputImage inRect:_targetBounds fromRect:_inputImage.extent];
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

- (CGPoint)converPointToImagePoint:(CGPoint)imageViewPoint {
    CGPoint imagePoint = CGPointZero;
    CGFloat scale = self.inputImage.extent.size.width / self.targetBounds.size.width;
    
    imagePoint.x = (imageViewPoint.x *  [UIScreen mainScreen].scale - self.targetBounds.origin.x) * scale;
    imagePoint.y = (imageViewPoint.y *  [UIScreen mainScreen].scale - self.targetBounds.origin.y) * scale;
    
    return imagePoint;
}



@end
