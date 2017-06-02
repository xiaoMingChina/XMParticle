//
//  UIScrollView+XMScrollParticle.m
//  XMParticle
//
//  Created by 忘忧 on 17/6/1.
//  Copyright © 2017年 小明. All rights reserved.
//

#import "UIScrollView+XMScrollParticle.h"
#import "XMScrollParticle.h"

@interface UIScrollView ()
@property (nonatomic, strong, readonly) XMScrollParticle *xmScrollParticle;
@end

static const char XMParticleScoll;

@implementation UIScrollView (XMScrollParticle)

- (void)xm_showScrollParticle
{
    if (self.xmScrollParticle) {
        //已经存在
        [self.xmScrollParticle removeFromSuperview];
        self.xmScrollParticle = nil;
    }
    
    XMScrollParticle *object = [[XMScrollParticle alloc] init];
    self.xmScrollParticle = object;
    [self insertSubview:object atIndex:0];
}

#pragma mark Getter/Setter

- (XMScrollParticle *)xmScrollParticle
{
    return objc_getAssociatedObject(self, &XMParticleScoll);
}

- (void)setXmScrollParticle:(XMScrollParticle *)xmScrollParticle
{
    [self willChangeValueForKey:@"XMParticleScoll"];
    objc_setAssociatedObject(self, &XMParticleScoll,
                             xmScrollParticle,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"XMParticleScoll"];
}

@end
