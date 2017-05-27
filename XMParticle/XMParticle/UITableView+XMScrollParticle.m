//
//  UITableView+XMScrollParticle.m
//  XMParticle
//
//  Created by 忘忧 on 17/5/25.
//  Copyright © 2017年 小明. All rights reserved.
//

#import "UITableView+XMScrollParticle.h"
#import <objc/runtime.h>

@interface XMObject : NSObject

@property (nonatomic, strong) CAEmitterLayer *leftEmitterLayer;
@property (nonatomic, strong) CAEmitterLayer *rightEmitterLayer;
@property (nonatomic, strong) CAEmitterCell *leftEmitterCell;
@property (nonatomic, strong) CAEmitterCell *rightEmitterCell;
@property (nonatomic, assign) CGFloat realoffsetY;
@property (nonatomic, assign) CGFloat oldOffsetY;
@property (nonatomic, assign) NSTimeInterval lastOffsetCapture;
@property (nonatomic, assign) BOOL isScrollingFast;
@property (nonatomic, assign) CGFloat baseBirthRate;
@property (nonatomic, assign) CGFloat baseYAcceleration;
@property (nonatomic) NSTimer *timer;
@property (nonatomic, assign) BOOL hasStop;
@end

static char UIScrollViewDragToDown;



@implementation XMObject

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(check) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:@""];
    }
    return _timer;
}

- (void)check
{
    
    [self.leftEmitterLayer setValue:@(0) forKeyPath:@"emitterCells.left.birthRate"];
    [self.rightEmitterLayer setValue:@(0) forKeyPath:@"emitterCells.right.birthRate"];
    [self.timer invalidate];
    self.timer = nil;
}

- (id)init
{
    if (self = [super init]) {
        self.baseBirthRate = 4;
        self.baseYAcceleration = 10;
    }
    return self;
}

- (void)changeCellWithSpeed:(CGFloat)speed
{
    CGFloat birthRate = fabs(speed * self.baseBirthRate);
    CGFloat yAcceleration = speed * self.baseYAcceleration;
    [self.leftEmitterLayer setValue:@(birthRate) forKeyPath:@"emitterCells.left.birthRate"];
    [self.rightEmitterLayer setValue:@(birthRate) forKeyPath:@"emitterCells.right.birthRate"];
    [self.leftEmitterLayer setValue:@(yAcceleration) forKeyPath:@"emitterCells.left.yAcceleration"];
    [self.rightEmitterLayer setValue:@(yAcceleration) forKeyPath:@"emitterCells.right.yAcceleration"];
}

- (void)changeCellWithFast:(BOOL)fast up:(BOOL)up
{
    CGFloat birthRate = 0;
    CGFloat yAcceleration = 0;
    if (fast) {
        birthRate = 10000;
        yAcceleration = 100000;
    } else {
        birthRate = 10000;
        yAcceleration = 10000;
    }
    
    if (!up) {
        yAcceleration = - yAcceleration;
    }

    [self.leftEmitterLayer setValue:@(birthRate) forKeyPath:@"emitterCells.left.birthRate"];
    [self.rightEmitterLayer setValue:@(birthRate) forKeyPath:@"emitterCells.right.birthRate"];
    [self.leftEmitterLayer setValue:@(yAcceleration) forKeyPath:@"emitterCells.left.yAcceleration"];
    [self.rightEmitterLayer setValue:@(yAcceleration) forKeyPath:@"emitterCells.right.yAcceleration"];
}

- (void)stop
{
    [self.leftEmitterLayer setValue:@(0) forKeyPath:@"emitterCells.left.birthRate"];
    [self.rightEmitterLayer setValue:@(0) forKeyPath:@"emitterCells.right.birthRate"];
    self.hasStop = YES;
//    [self.timer fire];
}

@end


@interface UIScrollView ()
@property (nonatomic, strong, readonly) XMObject *xmObject;
@end

@implementation UITableView (XMScrollParticle)

- (void)show
{
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"panGestureRecognizer.state" options:NSKeyValueObservingOptionNew context:nil];
    
    XMObject *object = [[XMObject alloc] init];
    self.xmObject = object;
    object.realoffsetY = 0;
    object.oldOffsetY = 0;
    NSLog(@"%@",self.xmObject);
    
    self.xmObject.leftEmitterLayer = [CAEmitterLayer new];
    self.xmObject.leftEmitterLayer.emitterPosition = CGPointMake(CGRectGetMinX(self.frame), self.bounds.size.height / 2);
    self.xmObject.leftEmitterLayer.emitterShape = kCAEmitterLayerRectangle;
    self.xmObject.leftEmitterLayer.renderMode = kCAEmitterLayerAdditive;
//    self.xmObject.leftEmitterLayer.emitterMode = kCAEmitterLayerOutline;
    self.xmObject.leftEmitterLayer.emitterSize = CGSizeMake(0, 50);
    self.xmObject.leftEmitterCell = [CAEmitterCell new];
    self.xmObject.leftEmitterCell.name = @"left";
    self.xmObject.leftEmitterCell.birthRate = 1000;
    self.xmObject.leftEmitterCell.lifetime =  1;
    self.xmObject.leftEmitterCell.contents = (__bridge id _Nullable)([UIImage imageNamed:@"spark"].CGImage);
    self.xmObject.leftEmitterCell.velocity = -200;
    self.xmObject.leftEmitterCell.velocityRange = -100;
    self.xmObject.leftEmitterCell.yAcceleration = 10000;
    self.xmObject.leftEmitterCell.scale = 0.2;
    self.xmObject.leftEmitterCell.scaleSpeed = -0.4;
    //    self.xmObject.rightEmitterCell.emissionRange = M_PI * 0.5;
    self.xmObject.leftEmitterCell.color = [[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1] CGColor];
    self.xmObject.leftEmitterCell.redRange = 0.2;
    self.xmObject.leftEmitterCell.redSpeed = -0.2;
    self.xmObject.leftEmitterCell.greenRange = 0.1;
    self.xmObject.leftEmitterCell.greenSpeed = 0.1;
    self.xmObject.leftEmitterCell.blueRange = 0.05;
    self.xmObject.leftEmitterCell.blueSpeed = -0.05;
    self.xmObject.leftEmitterCell.alphaRange = 0.1;
    self.xmObject.leftEmitterCell.alphaSpeed = - 0.15;
    self.xmObject.leftEmitterLayer.emitterCells = @[self.xmObject.leftEmitterCell];
    [self.superview.layer addSublayer:self.xmObject.leftEmitterLayer];
    
    self.xmObject.rightEmitterLayer = [CAEmitterLayer new];
    self.xmObject.rightEmitterLayer.emitterPosition = CGPointMake(CGRectGetMaxX(self.frame), self.bounds.size.height / 2);
    self.xmObject.rightEmitterLayer.emitterShape = kCAEmitterLayerRectangle;
    self.xmObject.rightEmitterLayer.renderMode = kCAEmitterLayerAdditive;
    self.xmObject.rightEmitterLayer.emitterSize = CGSizeMake(0, 50);
    self.xmObject.rightEmitterCell = [CAEmitterCell new];
    self.xmObject.rightEmitterCell.name = @"right";
    self.xmObject.rightEmitterCell.birthRate = 1000;
    self.xmObject.rightEmitterCell.lifetime =  1;
    self.xmObject.rightEmitterCell.contents = (__bridge id _Nullable)([UIImage imageNamed:@"spark"].CGImage);
    self.xmObject.rightEmitterCell.velocity = 200;
    self.xmObject.rightEmitterCell.velocityRange = 100;
    self.xmObject.rightEmitterCell.yAcceleration = 10000;
    self.xmObject.rightEmitterCell.scale = 0.2;
    self.xmObject.rightEmitterCell.scaleSpeed = -0.4;
//    self.xmObject.rightEmitterCell.emissionRange = M_PI * 0.5;
    self.xmObject.rightEmitterCell.color = [[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1] CGColor];
    self.xmObject.rightEmitterCell.redRange = 0.2;
    self.xmObject.rightEmitterCell.redSpeed = -0.2;
    self.xmObject.rightEmitterCell.greenRange = 0.1;
    self.xmObject.rightEmitterCell.greenSpeed = 0.1;
    self.xmObject.rightEmitterCell.blueRange = 0.05;
    self.xmObject.rightEmitterCell.blueSpeed = -0.05;
    self.xmObject.rightEmitterCell.alphaRange = 0.1;
    self.xmObject.rightEmitterCell.alphaSpeed = - 0.15;
    self.xmObject.rightEmitterLayer.emitterCells = @[self.xmObject.rightEmitterCell];
    [self.superview.layer addSublayer:self.xmObject.rightEmitterLayer];

}

#pragma mark - Observing -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([self isTracking]) {
        self.xmObject.hasStop = NO;
    }
    if([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint oldPoint = [[change objectForKey:@"old"] CGPointValue];
        CGPoint newPoint = [[change objectForKey:@"new"] CGPointValue];
        if (oldPoint.y == newPoint.y) {
            [self scrollViewDidScrollFinish];
            return;
        }

//        if ([self isDecelerating] && self.xmObject.hasStop) {
//            return;
//        }
        [self scrollViewDidScrollWithKVO:newPoint];
    }
}

- (void)scrollViewDidScrollFinish
{
    //停止
    [self.xmObject stop];
}


- (void)scrollViewDidScrollWithKVO:(CGPoint)contentOffset
{
    CGFloat currentOffsetY = contentOffset.y;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval timeDiff = currentTime - self.xmObject.lastOffsetCapture;
    
//    NSLog(@"timeDiff : %f",timeDiff);
    

        //时间间隔
        //移动距离
        CGFloat distance = currentOffsetY - self.xmObject.oldOffsetY;
        CGFloat scrollSpeed = distance / timeDiff;
        NSLog(@"scroll speed : %f",scrollSpeed);
        [self.xmObject changeCellWithSpeed:scrollSpeed];

    
    BOOL isFast;
    
    if(timeDiff > 0.1) {
        CGFloat distance = currentOffsetY - self.xmObject.oldOffsetY;
        //The multiply by 10, / 1000 isn't really necessary.......
        CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
        
        CGFloat scrollSpeed = fabs(scrollSpeedNotAbs);
        if (scrollSpeed > 0.5) {
            self.xmObject.isScrollingFast = YES;
//            NSLog(@"Fast");
            isFast = YES;
        } else {
            self.xmObject.isScrollingFast = NO;
//            NSLog(@"Slow");
            isFast = NO;
        }
//            NSLog(@"scroll speed : %f",scrollSpeed);
        
        
        
        
        self.xmObject.oldOffsetY = currentOffsetY;
        self.xmObject.lastOffsetCapture = currentTime;
    }
    BOOL isUping;
    if (currentOffsetY > self.xmObject.oldOffsetY) {
//         NSLog(@"----upDrag----");
        isUping = NO;
    } else {
//         NSLog(@"====downDrag====");
        isUping = YES;
    }
    
    self.xmObject.oldOffsetY = currentOffsetY;
    
//    [self.xmObject changeCellWithFast:isFast up:isUping];

    if ( ![self isDecelerating] && ![self isDragging]) {
         [self.xmObject stop];
    }
//    CGPoint scrollVelocity = [[self panGestureRecognizer] velocityInView:self];
//    NSLog(@"scroll velocity : %f",scrollVelocity.y);
    
//    NSLog(@"scroll velocity : %f",contentOffset.y);

}

- (XMObject *)xmObject
{
    return objc_getAssociatedObject(self, &UIScrollViewDragToDown);
}

- (void)setXmObject:(XMObject *)xmObject
{
    [self willChangeValueForKey:@"XMUIScrollViewDragToDown"];
    objc_setAssociatedObject(self, &UIScrollViewDragToDown,
                             xmObject,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"XMUIScrollViewDragToDown"];
}

@end
