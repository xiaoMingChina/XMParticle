//
//  XMScrollParticle.m
//  XMParticle
//
//  Created by 忘忧 on 17/6/1.
//  Copyright © 2017年 小明. All rights reserved.
//

#import "XMScrollParticle.h"
#import "XMParticleConst.h"
#import <objc/runtime.h>

@interface XMScrollParticle()

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic) CAEmitterLayer *leftEmitterLayer;
@property (nonatomic) CAEmitterLayer *rightEmitterLayer;
@property (nonatomic) CAEmitterCell *leftEmitterCell;
@property (nonatomic) CAEmitterCell *rightEmitterCell;


@property (nonatomic, assign) CGFloat realoffsetY;
@property (nonatomic, assign) CGFloat oldOffsetY;
@property (nonatomic, assign) NSTimeInterval lastOffsetCapture;
@property (nonatomic, assign) BOOL isScrollingFast;
@property (nonatomic, assign) CGFloat baseBirthRate;
@property (nonatomic, assign) CGFloat baseYAcceleration;
@property (nonatomic, assign) BOOL hasStop;



@end

@implementation XMScrollParticle

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (![newSuperview isKindOfClass:[UIScrollView class]]) return;
    [self removeObserves];
    if (newSuperview) {
        _scrollView = (UIScrollView *)newSuperview;
        [self addObservers];
        [self updateEmitterPoint];
    }
}

#pragma mark Private Methods

- (void)updateEmitterPoint
{
    self.leftEmitterLayer.emitterPosition = CGPointMake(CGRectGetMinX(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame) / 2);
    self.rightEmitterLayer.emitterPosition = CGPointMake(CGRectGetMaxX(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame) / 2);
    self.leftEmitterLayer.emitterSize = CGSizeMake(0, 50);
    self.rightEmitterLayer.emitterSize = CGSizeMake(0, 50);
    [self.scrollView.superview.layer addSublayer:self.leftEmitterLayer];
    [self.scrollView.superview.layer addSublayer:self.rightEmitterLayer];
    
}

- (void)addObservers
{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.scrollView addObserver:self forKeyPath:XMParticleKeyPathContentOffset options:options context:nil];
    
}

- (void)removeObserves
{
    [self.superview removeObserver:self forKeyPath:XMParticleKeyPathContentOffset];
}

#pragma mark  Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint oldPoint = [[change objectForKey:@"old"] CGPointValue];
        CGPoint newPoint = [[change objectForKey:@"new"] CGPointValue];
        if (oldPoint.y == newPoint.y) {
            return;
        }
        NSLog(@"isChanging");
    }
}

#pragma mark Getter/Setter

- (CAEmitterLayer *)leftEmitterLayer
{
    if (!_leftEmitterLayer) {
        _leftEmitterLayer = [CAEmitterLayer new];
        _leftEmitterLayer.emitterShape = kCAEmitterLayerRectangle;
        _leftEmitterLayer.renderMode = kCAEmitterLayerAdditive;
        _leftEmitterLayer.emitterCells = @[self.leftEmitterCell];
    }
    return _leftEmitterLayer;
}

- (CAEmitterLayer *)rightEmitterLayer
{
    if (!_rightEmitterLayer) {
        _rightEmitterLayer = [CAEmitterLayer new];
        _rightEmitterLayer.emitterShape = kCAEmitterLayerRectangle;
        _rightEmitterLayer.renderMode = kCAEmitterLayerAdditive;
        _rightEmitterLayer.emitterCells = @[self.rightEmitterCell];
    }
    return _rightEmitterLayer;
}

- (CAEmitterCell *)leftEmitterCell
{
    if (!_leftEmitterCell) {
        _leftEmitterCell = [CAEmitterCell new];
        _leftEmitterCell.name = @"left";
        _leftEmitterCell.contents = (__bridge id _Nullable)([UIImage imageNamed:@"spark"].CGImage);
        _leftEmitterCell.birthRate = 1000;
        _leftEmitterCell.lifetime =  1;
        _leftEmitterCell.velocity = -200;
        _leftEmitterCell.velocityRange = -100;
        _leftEmitterCell.yAcceleration = 10000;
        _leftEmitterCell.scale = 0.2;
        _leftEmitterCell.scaleSpeed = -0.4;
        _leftEmitterCell.color = [[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1] CGColor];
        _leftEmitterCell.redRange = 0.2;
        _leftEmitterCell.redSpeed = -0.2;
        _leftEmitterCell.greenRange = 0.1;
        _leftEmitterCell.greenSpeed = 0.1;
        _leftEmitterCell.blueRange = 0.05;
        _leftEmitterCell.blueSpeed = -0.05;
        _leftEmitterCell.alphaRange = 0.1;
        _leftEmitterCell.alphaSpeed = - 0.15;

    }
    return _leftEmitterCell;
}

- (CAEmitterCell *)rightEmitterCell
{
    if (!_rightEmitterCell) {
        _rightEmitterCell = [CAEmitterCell new];
        _rightEmitterCell.name = @"right";
        _rightEmitterCell.birthRate = 1000;
        _rightEmitterCell.lifetime =  1;
        _rightEmitterCell.contents = (__bridge id _Nullable)([UIImage imageNamed:@"spark"].CGImage);
        _rightEmitterCell.velocity = 200;
        _rightEmitterCell.velocityRange = 100;
        _rightEmitterCell.yAcceleration = 10000;
        _rightEmitterCell.scale = 0.2;
        _rightEmitterCell.scaleSpeed = -0.4;
        //    _rightEmitterCell.emissionRange = M_PI * 0.5;
        _rightEmitterCell.color = [[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1] CGColor];
        _rightEmitterCell.redRange = 0.2;
        _rightEmitterCell.redSpeed = -0.2;
        _rightEmitterCell.greenRange = 0.1;
        _rightEmitterCell.greenSpeed = 0.1;
        _rightEmitterCell.blueRange = 0.05;
        _rightEmitterCell.blueSpeed = -0.05;
        _rightEmitterCell.alphaRange = 0.1;
        _rightEmitterCell.alphaSpeed = - 0.15;

    }
    return _rightEmitterCell;
}


@end
