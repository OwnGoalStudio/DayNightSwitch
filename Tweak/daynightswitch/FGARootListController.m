#import "FGARootListController.h"

#import <Preferences/PSSpecifier.h>

#import <roothide.h>
#import <spawn.h>

@implementation FGARootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }

    return _specifiers;
}

- (void)respring {
    pid_t pid;
    const char *args[] = {"killall", "-9", "SpringBoard", "backboardd", NULL};
    posix_spawn(&pid, jbroot("/usr/bin/killall"), NULL, NULL, (char *const *)args, NULL);
}

- (void)twitter {
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:[NSURL URLWithString:@"twitter://fga"]]) {
        [app openURL:[NSURL URLWithString:@"twitter://user?screen_name=fga"] options:@{} completionHandler:nil];
    } else if ([app canOpenURL:[NSURL URLWithString:@"tweetbot://fga/user_profile/fga"]]) {
        [app openURL:[NSURL URLWithString:@"tweetbot://fga/user_profile/fga"] options:@{} completionHandler:nil];
    } else if ([app canOpenURL:[NSURL URLWithString:@"https://twitter.com/fga"]]) {
        [app openURL:[NSURL URLWithString:@"https://twitter.com/fga"] options:@{} completionHandler:nil];
    }
}

- (void)github {
    [self openURL:[NSURL URLWithString:@"https://github.com/finngaida"]];
}

- (void)mail {
    [self openURL:[NSURL URLWithString:@"mailto:f@fga.pw?subject=DayNightSwitch%20Feature%20Request"]];
}

- (void)paypal {
    [self openURL:[NSURL URLWithString:@"https://paypal.me/fga"]];
}

- (void)support {
    [self openURL:[NSURL URLWithString:@"https://havoc.app/search/82Flex"]];
}

- (void)openURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
        NSString *key = [specifier propertyForKey:@"cell"];
        if ([key isEqualToString:@"PSButtonCell"]) {
            UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
            NSNumber *isDestructiveValue = [specifier propertyForKey:@"isDestructive"];
            BOOL isDestructive = [isDestructiveValue boolValue];
            cell.textLabel.textColor = isDestructive ? [UIColor systemRedColor] : [UIColor systemBlueColor];
            cell.textLabel.highlightedTextColor = isDestructive ? [UIColor systemRedColor] : [UIColor systemBlueColor];
            return cell;
        }
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

@end
