//
//  DayNightSwitch.m
//  DayNightSwitch
//
//  Created by Finn Gaida on 03.09.16.
//  Copyright © 2016 Finn Gaida. All rights reserved.
//

#import "DayNightSwitch.h"

#import <roothide.h>

/// some color constants
#define onKnobColor [UIColor colorWithRed:0.882 green:0.765 blue:0.325 alpha:1];
#define onSubviewColor [UIColor colorWithRed:0.992 green:0.875 blue:0.459 alpha:1];
#define offKnobColor [UIColor colorWithRed:0.894 green:0.902 blue:0.788 alpha:1];
#define offSubviewColor [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
#define offColor [UIColor colorWithRed:0.235 green:0.255 blue:0.271 alpha:1];
#define offBorderColor [UIColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1];
#define onColor [UIColor colorWithRed:0.627 green:0.894 blue:0.98 alpha:1];
#define onBorderColor [UIColor colorWithRed:0.533 green:0.769 blue:0.843 alpha:1];

@interface Knob : UIView

/// Visual state of the knob, animates changes
@property(nonatomic, assign) BOOL on;

/// Horizontally expanded state of the knob, animates changes
@property(nonatomic, assign) BOOL expanded;

/// Round subview of the knob
@property(nonatomic, strong) UIView *subview;

/// Circular subviews on the off state `subview`
@property(nonatomic, strong) NSArray<UIView *> *craters;

- (void)setAnimated:(BOOL)animated;

@end

@implementation Knob {
    BOOL _shouldAnimate;
}

/// Distance from knob to subview circle
- (CGFloat)subviewMargin {
    return self.frame.size.height / 12;
}

/**
 Sets up the `subview` with the craters as well

 - returns: the view
 */
- (UIView *)setupSubview {

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake([self subviewMargin], [self subviewMargin],
                                                         self.frame.size.width - [self subviewMargin] * 2,
                                                         self.frame.size.height - [self subviewMargin] * 2)];
    v.layer.masksToBounds = true;
    v.layer.cornerRadius = v.frame.size.height / 2;
    v.backgroundColor = offSubviewColor;

    for (UIView *c in [self setupCraters]) {
        [v addSubview:c];
    }

    self.subview = v;
    return v;
}

/**
 Sets up three craters

 - returns: array of set up views
 */
- (NSArray *)setupCraters {

    // shortcuts
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;

    UIView *topLeft = [[UIView alloc] initWithFrame:CGRectMake(0, h * 0.1, w * 0.2, w * 0.2)];
    UIView *topRight = [[UIView alloc] initWithFrame:CGRectMake(w * 0.5, 0, w * 0.3, w * 0.3)];
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(w * 0.4, h * 0.5, w * 0.25, w * 0.25)];

    NSArray<UIView *> *all = @[ topLeft, topRight, bottom ];

    for (UIView *v in all) {
        v.backgroundColor = offSubviewColor;
        v.layer.masksToBounds = YES;
        v.layer.cornerRadius = v.frame.size.height / 2;

        UIColor *offC = offKnobColor;
        v.layer.borderColor = offC.CGColor;
        v.layer.borderWidth = [self subviewMargin];
    }

    self.craters = all;
    return all;
}

- (instancetype)initWithFrame:(CGRect)frame {
    _on = NO;
    _expanded = NO;

    self = [super initWithFrame:frame];

    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.height / 2;
    self.backgroundColor = offKnobColor;

    [self addSubview:[self setupSubview]];

    [self _setOn:NO];
    [self _setExpanded:NO];

    return self;
}

- (void)setOn:(BOOL)on {
    if (_on == on) {
        return;
    }

    _on = on;

    [self _setOn:on];
}

- (void)_setOn:(BOOL)on {
    [UIView animateWithDuration:(_shouldAnimate ? 0.8 : 0)
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         if (on) {
                             self.backgroundColor = onKnobColor;
                             self.subview.backgroundColor = onSubviewColor;
                         } else {
                             self.backgroundColor = offKnobColor;
                             self.subview.backgroundColor = offSubviewColor;
                         }

                         BOOL cache = self.expanded;
                         [self _setExpanded:cache];
                     }
                     completion:nil];

    [UIView animateWithDuration:(_shouldAnimate ? 0.4 : 0)
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.subview.transform = CGAffineTransformMakeRotation(M_PI * ((self.on) ? 0.2 : -0.2));
                     }
                     completion:nil];
}

- (void)setExpanded:(BOOL)expanded {
    if (_expanded == expanded) {
        return;
    }

    _expanded = expanded;

    [self _setExpanded:expanded];
}

- (void)_setExpanded:(BOOL)expanded {
    CGFloat newWidth = self.frame.size.height * (expanded ? 1.25 : 1);
    CGFloat x = (self.on) ? self.superview.frame.size.width - newWidth - [(DayNightSwitch *)self.superview knobMargin]
                          : self.frame.origin.x;

    [UIView animateWithDuration:(_shouldAnimate ? 0.8 : 0)
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.frame = CGRectMake(x, self.frame.origin.y, newWidth, self.frame.size.height);
                         self.subview.center =
                             CGPointMake((self.on) ? self.frame.size.width - self.frame.size.height / 2
                                                   : self.frame.size.height / 2,
                                         self.subview.center.y);

                         for (UIView *v in self.craters) {
                             v.alpha = (self.on) ? 0 : 1;
                         }
                     }
                     completion:nil];
}

- (void)setAnimated:(BOOL)animated {
    _shouldAnimate = animated;
}

@end

@interface DayNightLayerDelegate : NSObject <CALayerDelegate>
@property(nonatomic, assign) BOOL animated;
@end

@implementation DayNightLayerDelegate

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)key {
    return _animated ? nil : [NSNull null];
}

@end

@interface DayNightSwitch ()

/// Round white knob
@property(nonatomic, strong) Knob *knob;

@property(nonatomic, assign) BOOL moved;

/// This prevents the tap gesture recognizer from interfering the drag movement
@property(nonatomic, assign) BOOL dragging;

@property(nonatomic, assign) BOOL isOnBeforeDrag;

@property(nonatomic, strong) DayNightLayerDelegate *layerDelegate;

@end

/// A switch inspired by [Dribbble](https://dribbble.com/shots/1909289-Day-Night-Toggle-Button-GIF)
@implementation DayNightSwitch {
    BOOL _shouldSkipChangeAction;
    BOOL _shouldAnimate;
}

/// Width of the darker border of the background
- (CGFloat)borderWidth {
    return self.frame.size.height / 7;
}

/// Distance between border and knob
- (CGFloat)knobMargin {
    return self.frame.size.height / 10;
}

/**
 Sets up the `knob`

 - returns: the knob view
 */
- (Knob *)setupKnob {

    CGFloat w = self.frame.size.height - [self knobMargin] * 2;
    Knob *v = [[Knob alloc] initWithFrame:CGRectMake([self knobMargin], [self knobMargin], w, w)];

    self.knob = v;
    return v;
}

/**
 Sets up the border layers

 - returns: array containing both layers
 */
- (NSArray *)setupBorders {

    CAShapeLayer *b1 = [CAShapeLayer layer];
    CAShapeLayer *b2 = [CAShapeLayer layer];
    UIBezierPath *path =
        [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
                                   cornerRadius:self.frame.size.height / 2];

    b1.path = path.CGPath;
    b1.fillColor = [UIColor clearColor].CGColor;

    UIColor *onC = onBorderColor;
    b1.strokeColor = onC.CGColor;
    b1.lineWidth = [self borderWidth];
    b1.delegate = self.layerDelegate;
    self.onBorder = b1;

    b2.path = path.CGPath;
    b2.fillColor = [UIColor clearColor].CGColor;

    UIColor *offC = offBorderColor;
    b2.strokeColor = offC.CGColor;
    b2.lineWidth = [self borderWidth];
    b2.delegate = self.layerDelegate;
    self.offBorder = b2;

    return @[ b1, b2 ];
}

/**
 Creates 7 stars with different location and size

 - returns: an array of set up views
 */
- (NSArray *)setupStars {

    // shortcuts
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;

    CGFloat x = h * 0.05;
    UIView *s1 = [[UIView alloc] initWithFrame:CGRectMake(w * 0.5, h * 0.16, x, x)];
    UIView *s2 = [[UIView alloc] initWithFrame:CGRectMake(w * 0.62, h * 0.33, x * 0.6, x * 0.6)];
    UIView *s3 = [[UIView alloc] initWithFrame:CGRectMake(w * 0.7, h * 0.15, x, x)];
    UIView *s4 = [[UIView alloc] initWithFrame:CGRectMake(w * 0.83, h * 0.39, x * 1.4, x * 1.4)];
    UIView *s5 = [[UIView alloc] initWithFrame:CGRectMake(w * 0.7, h * 0.54, x * 0.8, x * 0.8)];
    UIView *s6 = [[UIView alloc] initWithFrame:CGRectMake(w * 0.52, h * 0.73, x * 1.3, x * 1.3)];
    UIView *s7 = [[UIView alloc] initWithFrame:CGRectMake(w * 0.82, h * 0.66, x * 1.1, x * 1.1)];

    NSArray *all = @[ s1, s2, s3, s4, s5, s6, s7 ];

    for (UIView *s in all) {
        s.layer.masksToBounds = YES;
        s.layer.cornerRadius = s.frame.size.height / 2;
        s.backgroundColor = [UIColor whiteColor];
    }

    self.stars = all;
    return all;
}

/**
 Sets up the `cloud`

 - returns: the image view
 */
- (UIImageView *)setupCloud {

    UIImageView *v =
        [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width / 3, self.frame.size.height * 0.4,
                                                      self.frame.size.width / 3, self.frame.size.width * 0.23)];
    v.image = [UIImage
        imageWithContentsOfFile:
            [NSString
                stringWithUTF8String:jbroot("/var/mobile/Library/Application Support/DayNightSwitch/cloud@2x.png")]];
    v.transform = CGAffineTransformMakeScale(0, 0);

    // this should be done with UIBezierPaths...

    self.cloud = v;
    return v;
}

// MARK: Initializers
- (instancetype)initWithCenter:(CGPoint)center {
    CGFloat height = 30;
    CGFloat width = height * 1.75;

    self = [super initWithFrame:CGRectMake(center.x - width / 2, center.y - height / 2, width, height)];
    [self commonInit];

    return self;
}

/**
 Init method called by all initializers. The switch is initialized off by default
 */
- (void)commonInit {
    self.moved = NO;
    self.dragging = NO;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.height / 2;
    self.backgroundColor = [UIColor colorWithRed:0.235 green:0.255 blue:0.271 alpha:1];
    self.layerDelegate = [[DayNightLayerDelegate alloc] init];

    NSArray *borders = [self setupBorders];
    [self.layer addSublayer:borders[0]];
    [self.layer addSublayer:borders[1]];

    for (UIView *v in [self setupStars]) {
        [self addSubview:v];
    }

    [self addSubview:[self setupKnob]];
    [self addSubview:[self setupCloud]];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapGestureOccurred:)];
    [self addGestureRecognizer:tapGesture];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(panGestureOccurred:)];
    [self addGestureRecognizer:panGesture];
}

- (void)panGestureOccurred:(UIPanGestureRecognizer *)sender {
    CGPoint touchLocation = [sender locationInView:self];

    if (sender.state == UIGestureRecognizerStateBegan) {
        self.isOnBeforeDrag = self.on;
        self.dragging = YES;
        self.knob.expanded = YES;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        self.moved = YES;

        if (touchLocation.x > self.frame.size.width / 2 && !self.on) {
            self.on = YES;
        } else if (touchLocation.x < self.frame.size.width / 2 && self.on) {
            self.on = NO;
        }
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled ||
               sender.state == UIGestureRecognizerStateFailed) {

        self.knob.expanded = NO;
        self.dragging = NO;
        self.moved = NO;

        if (self.on != self.isOnBeforeDrag && self.changeAction) {
            self.changeAction(self.on, YES);
        }
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self commonInit];
    return self;
}

- (void)tapGestureOccurred:(UITapGestureRecognizer *)sender {
    if (self.dragging) {
        return;
    }

    self.on = !self.on;
}

- (void)setOn:(BOOL)on {
    if (_on == on) {
        return;
    }

    _on = on;

    [self _setOn:on];
}

- (void)_setOn:(BOOL)on {
    // call the action closure
    if (self.changeAction && !_shouldSkipChangeAction) {
        self.changeAction(on, !self.moved);
    }

    BOOL shouldAnimate = _shouldAnimate || self.dragging;

    [self.layerDelegate setAnimated:shouldAnimate];
    [self.knob setAnimated:shouldAnimate];

    self.knob.on = on;

    [UIView animateWithDuration:(shouldAnimate ? 0.4 : 0)
        delay:0
        usingSpringWithDamping:1
        initialSpringVelocity:0
        options:UIViewAnimationOptionAllowUserInteraction
        animations:^{
            CGFloat knobRadius = self.knob.frame.size.width / 2;

            if (on) {
                self.knob.center =
                    CGPointMake(self.frame.size.width - knobRadius - [self knobMargin], self.knob.center.y);

                self.backgroundColor = onColor;
                self.offBorder.strokeStart = 1.0;
                self.cloud.transform = CGAffineTransformIdentity;
            } else {
                self.knob.center = CGPointMake(knobRadius + [self knobMargin], self.knob.center.y);

                self.backgroundColor = offColor;
                self.offBorder.strokeEnd = 1.0;
                self.cloud.transform = CGAffineTransformMakeScale(0, 0);
            }

            for (int i = 0; i < self.stars.count; i++) {
                UIView *star = self.stars[i];
                star.alpha = (on) ? 0 : 1;

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * i * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    star.transform = CGAffineTransformMakeScale(1.5, 1.5);

                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        star.transform = CGAffineTransformIdentity;
                    });
                });
            }
        }
        completion:^(BOOL finished) {
            // reset the values
            if (on) {
                self.offBorder.strokeStart = 0.0;
                self.offBorder.strokeEnd = 0.0;
            } else {
                self.offBorder.strokeStart = 0.0;
                self.offBorder.strokeEnd = 1.0;
            }
        }];
}

- (void)blockChangeActionAnimated:(BOOL)animated {
    _shouldSkipChangeAction = YES;
    _shouldAnimate = animated;
    [self.knob setAnimated:animated];
}

- (void)unblockChangeAction {
    _shouldSkipChangeAction = NO;
}

@end
