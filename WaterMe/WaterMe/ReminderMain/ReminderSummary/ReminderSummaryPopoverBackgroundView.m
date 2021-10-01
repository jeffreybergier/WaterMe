//
//  ReminderSummaryPopoverBackgroundView.m
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/6/18.
//  Copyright © 2018 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

#import "ReminderSummaryPopoverBackgroundView.h"
#import "WaterMe-Swift.h"

@interface ReminderSummaryPopoverBackgroundView ()
{
    CGFloat _arrowOffset;
    UIPopoverArrowDirection _arrowDirection;
}

// MARK: Safety Net for Shadow Opacity
@property (nonatomic) BOOL shadowOpacityWasCalled;

// MARK: Required to Implement for UIKit
@property (nonatomic) CGFloat arrowOffset;
@property (nonatomic) UIPopoverArrowDirection arrowDirection;
@property (class, nonatomic, readonly) UIEdgeInsets contentViewInsets;
@property (class, nonatomic, readonly) CGFloat arrowHeight;
@property (class, nonatomic, readonly) CGFloat arrowBase;

@property (nonatomic, weak, nullable) UIView* myArrowView;
@property (nonatomic, weak, nullable) CALayer* myArrowViewMaskLayer;
@property (nonatomic, weak, nullable) NSLayoutConstraint* horizontalArrowConstraint;
@property (nonatomic, weak, nullable) NSLayoutConstraint* verticalArrowConstraint;
@property (nonatomic, strong, nonnull) NSArray<NSLayoutConstraint*>* upConstraints;
@property (nonatomic, strong, nonnull) NSArray<NSLayoutConstraint*>* downConstraints;
@property (nonatomic, strong, nonnull) NSArray<NSLayoutConstraint*>* leadingConstraints;
@property (nonatomic, strong, nonnull) NSArray<NSLayoutConstraint*>* trailingConstraints;

@end

@implementation ReminderSummaryPopoverBackgroundView

@dynamic arrowOffset, arrowDirection, contentViewInsets, arrowHeight, arrowBase;

- (void)didMoveToWindow;
{
    [super didMoveToWindow];
    [self setShadowOpacityWasCalled:NO];
    if (![self myArrowView]) {
        [self configureArrowViewConstraints];
        [self configureArrowMaskLayer];
        [self updateArrowConstraintsForOffset];
        [self enableDisableConstraintsForArrowDirection];
    }
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    if (![self shadowOpacityWasCalled]) {
        [self setAlpha:0.1];
    } else {
        [self setAlpha:1.0];
    }
}

- (void)configureArrowViewConstraints;
{
    // Create and Add the View
    UIView* view = [UIVisualEffectView style_systemMaterial];
    [self setMyArrowView:view];
    [self addSubview:view];

    // Configure height and width constraints
    // And add them. These never change
    CGFloat height = [ReminderSummaryPopoverBackgroundView arrowHeight];
    CGFloat width = [ReminderSummaryPopoverBackgroundView arrowBase];
    NSLayoutConstraint* arrowWidthConstraint = [[view widthAnchor] constraintEqualToConstant:width];
    NSLayoutConstraint* arrowHeightConstraint = [[view heightAnchor] constraintEqualToConstant:height];
    [self addConstraints:@[arrowWidthConstraint, arrowHeightConstraint]];

    // Configure left/right/top/bottom attachments
    // But don't add them, these change
    NSLayoutConstraint* upDownSlide = [[view centerXAnchor] constraintEqualToAnchor:[self centerXAnchor] constant:0];
    NSLayoutConstraint* leftRightSlide = [[view centerYAnchor] constraintEqualToAnchor:[self centerYAnchor] constant:0];
    NSLayoutConstraint* upAttach = [[view topAnchor] constraintEqualToAnchor:[self topAnchor] constant:0];
    NSLayoutConstraint* downAttach = [[view bottomAnchor] constraintEqualToAnchor:[self bottomAnchor] constant:0];
    NSLayoutConstraint* leadAttach = [[view leftAnchor] constraintEqualToAnchor:[self leftAnchor] constant:0];
    NSLayoutConstraint* trailAttach = [[view rightAnchor] constraintEqualToAnchor:[self rightAnchor] constant:0];

    // Store them in the appropriate properties
    // These need to change dynamically
    [self setUpConstraints:@[upDownSlide, upAttach]];
    [self setDownConstraints:@[upDownSlide, downAttach]];
    [self setLeadingConstraints:@[leadAttach, leftRightSlide]];
    [self setTrailingConstraints:@[trailAttach, leftRightSlide]];
    [self setHorizontalArrowConstraint:leftRightSlide];
    [self setVerticalArrowConstraint:upDownSlide];
}

- (void)enableDisableConstraintsForArrowDirection;
{
    // if the arrow view has not been configured yet, bail
    if (![self myArrowView]) { return; }

    [self removeConstraints:[self upConstraints]];
    [self removeConstraints:[self downConstraints]];
    [self removeConstraints:[self leadingConstraints]];
    [self removeConstraints:[self trailingConstraints]];
    switch ([self arrowDirection]) {
        case UIPopoverArrowDirectionAny:
        case UIPopoverArrowDirectionUnknown:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Unexpected Arrow Direction"
                                         userInfo:nil];
        case UIPopoverArrowDirectionUp:
            [[self myArrowView] setTransform:CGAffineTransformIdentity];
            [self addConstraints:[self upConstraints]];
            break;
        case UIPopoverArrowDirectionDown:
            [[self myArrowView] setTransform:CGAffineTransformMakeRotation((180.0 * M_PI) / 180.0)];
            [self addConstraints:[self downConstraints]];
            break;
        case UIPopoverArrowDirectionLeft:
        {
            CGFloat height = [ReminderSummaryPopoverBackgroundView arrowHeight];
            CGFloat width = [ReminderSummaryPopoverBackgroundView arrowBase];
            CGAffineTransform rotation = CGAffineTransformMakeRotation((-90*M_PI)/180.0);
            CGAffineTransform rotationAndTranslation = CGAffineTransformTranslate(rotation, 0, (height-width)/2);
            [[self myArrowView] setTransform:rotationAndTranslation];
            [self addConstraints:[self leadingConstraints]];
            break;
        }
        case UIPopoverArrowDirectionRight:
        {
            CGFloat height = [ReminderSummaryPopoverBackgroundView arrowHeight];
            CGFloat width = [ReminderSummaryPopoverBackgroundView arrowBase];
            CGAffineTransform rotation = CGAffineTransformMakeRotation((90*M_PI)/180.0);
            CGAffineTransform rotationAndTranslation = CGAffineTransformTranslate(rotation, 0, (height-width)/2);
            [[self myArrowView] setTransform:rotationAndTranslation];
            [self addConstraints:[self trailingConstraints]];
            break;
        }
    }
}

- (void)updateArrowConstraintsForOffset;
{
    [[self horizontalArrowConstraint] setConstant:[self arrowOffset]];
    [[self verticalArrowConstraint] setConstant:[self arrowOffset]];
}

- (void)configureArrowMaskLayer;
{
    [[self myArrowViewMaskLayer] removeFromSuperlayer];
    [self setMyArrowViewMaskLayer:nil];
    CGFloat strokeWidth = 12;
    CGFloat gap = 4 + (strokeWidth / 2);
    CGFloat height = [ReminderSummaryPopoverBackgroundView arrowHeight];
    CGFloat width = [ReminderSummaryPopoverBackgroundView arrowBase];
    UIBezierPath* path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(gap, height - gap)];
    [path addLineToPoint:CGPointMake(width / 2, gap)];
    [path addLineToPoint:CGPointMake(width - gap, height - gap)];
    [path closePath];
    CAShapeLayer* mask = [[CAShapeLayer alloc] init];
    [mask setPath:[path CGPath]];
    [mask setLineJoin:kCALineJoinRound];
    [mask setLineWidth:strokeWidth];
    [mask setStrokeColor:[[UIColor blackColor] CGColor]];
    [[[self myArrowView] layer] setMask:mask];
    [mask setPosition:[[[self myArrowView] layer] position]];
    [self setMyArrowViewMaskLayer:mask];
}

// MARK: Required of Implementers

+ (UIEdgeInsets)contentViewInsets;
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
+ (CGFloat)arrowHeight;
{
    return 50;
}
+ (CGFloat)arrowBase;
{
    return 80;
}
- (CGFloat)arrowOffset;
{
    return _arrowOffset;
}
- (UIPopoverArrowDirection)arrowDirection;
{
    return _arrowDirection;
}
- (void)setArrowOffset:(CGFloat)arrowOffset;
{
    _arrowOffset = arrowOffset;
    [self updateArrowConstraintsForOffset];
}
- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection;
{
    _arrowDirection = arrowDirection;
    [self enableDisableConstraintsForArrowDirection];
}

// MARK: Sneakiness to get desired look

- (CGFloat)_shadowOpacity;
{
    [self setShadowOpacityWasCalled:YES];
    if ([[self traitCollection] userInterfaceStyleIsNormal]) {
        return 0.15;
    } else {
        return 0.6;
    }
}

@end
