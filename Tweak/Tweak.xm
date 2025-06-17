#import "DayNightSwitch.h"

#import <roothide.h>

@interface PSSwitchTableCell : UITableViewCell
- (SEL)cellAction;
@end

@interface PSSpecifier : NSObject
@end

// MARK: Settings
static BOOL enabled = NO;
static BOOL global = NO;

static void loadPrefs(void) {

    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithUTF8String:jbroot("/var/mobile/Library/Preferences/de.finngaida.daynightswitch.plist")]];

    enabled = [settings objectForKey:@"enabled"] ? [[settings objectForKey:@"enabled"] boolValue] : YES;
    global = [settings objectForKey:@"global"] ? [[settings objectForKey:@"global"] boolValue] : NO;
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("de.finngaida.daynightswitch/settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPrefs();
}

@interface UISwitch (DayNightSwitch)
@property (nonatomic, strong) DayNightSwitch *dns_dayNightSwitch;
@property (nonatomic, strong) NSNumber *dns_bypass;
- (UIImpactFeedbackGenerator *)_impactFeedbackGenerator;
- (void)dns_setup;
- (void)dns_addSwitch;
@end

%hook UISwitch

%property (nonatomic, strong) DayNightSwitch *dns_dayNightSwitch;
%property (nonatomic, strong) NSNumber *dns_bypass;

- (instancetype)initWithFrame:(CGRect)arg1 {
    id object = %orig;
    [self dns_setup];
    return object;
}

- (instancetype)initWithCoder:(id)arg1 {
    id object = %orig;
    [self dns_setup];
    return object;
}

%new
- (void)dns_setup {
    if (enabled && !self.dns_dayNightSwitch) {
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        if (global) {
            [self dns_addSwitch];
        } else if ([bundleId isEqual: @"com.apple.Preferences"]) {
            PSSwitchTableCell *cell = (PSSwitchTableCell *)self.superview;
            if ([cell respondsToSelector:@selector(specifier)] && [cell respondsToSelector:@selector(control)]) {
                id spec = [cell performSelector:@selector(specifier)];
                if ([spec respondsToSelector:@selector(identifier)]) {
                    NSString *identifier = [spec performSelector:@selector(identifier)];
                    if ([identifier isEqual:@"DND_TOP_LEVEL"] && [cell performSelector:@selector(control)] == self) {
                        [self dns_addSwitch];
                    }
                }
            }
        }
    }
}

%new
- (void)dns_addSwitch {
    DayNightSwitch *sub = [[DayNightSwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];

    self.dns_bypass = @YES;
    sub.on = self.on;
    self.dns_bypass = nil;

    __weak __typeof(self) weakSelf = self;
    sub.changeAction = ^(BOOL on, BOOL shouldNotifyChanged) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        self.dns_bypass = @YES;
        BOOL isOn = strongSelf.on;
        strongSelf.on = on;
        self.dns_bypass = nil;

        if (isOn != on) {
            [[strongSelf _impactFeedbackGenerator] impactOccurred];
        }

        if (shouldNotifyChanged) {
            [strongSelf sendActionsForControlEvents:UIControlEventValueChanged];
        }
    };

    self.dns_dayNightSwitch = sub;

    [self addSubview:sub];
}

- (void)setOn:(BOOL)arg1 animated:(BOOL)arg2 notifyingVisualElement:(BOOL)arg3 {
    %orig;
    if ([self.dns_bypass boolValue]) {
        return;
    }

    [self.dns_dayNightSwitch blockChangeActionAnimated:arg2];
    [self.dns_dayNightSwitch setOn:arg1];
    [self.dns_dayNightSwitch unblockChangeAction];
}

%end