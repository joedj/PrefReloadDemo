#import <Preferences/Preferences.h>

static BOOL state = NO;

@interface PrefsReloadDemoSettingsController: PSListController
@end

@implementation PrefsReloadDemoSettingsController {
    BOOL _listening;
}

static void toggle(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    PrefsReloadDemoSettingsController *controller = (__bridge PrefsReloadDemoSettingsController *)observer;
    dispatch_async(dispatch_get_main_queue(), ^{
        state = !state;
        [controller reloadSpecifiers];
    });
}

- (void)dealloc {
    if (_listening) {
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge void *)self, CFSTR("net.joedj.prefsreloaddemo/toggle"), NULL);
    }
}

- (NSArray *)specifiers {
    if (!_specifiers) {

        if (!_listening) {
            _listening = YES;
            CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge void *)self, toggle, CFSTR("net.joedj.prefsreloaddemo/toggle"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        }

        _specifiers = [[NSMutableArray alloc] init];

        PSSpecifier *demoSwitchSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Demo Switch" target:self set:@selector(setDemoSwitchEnabled:) get:@selector(isDemoSwitchEnabled) detail:nil cell:PSSwitchCell edit:nil];
        [(NSMutableArray *)_specifiers addObject:demoSwitchSpecifier];

        PSSpecifier *activatorSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Activator" target:self set:nil get:nil detail:nil cell:PSLinkCell edit:nil];
        [activatorSpecifier setProperty:@"switch-flip.net.joedj.prefsreloaddemo.switch" forKey:@"activatorListener"];
        [activatorSpecifier setProperty:@"Toggle PrefsReloadDemo" forKey:@"activatorTitle"];
        [activatorSpecifier setProperty:[NSBundle bundleWithIdentifier:@"com.libactivator.preferencebundle"].bundlePath forKey:@"lazy-bundle"];
        activatorSpecifier->action = @selector(lazyLoadBundle:);
        [(NSMutableArray *)_specifiers addObject:activatorSpecifier];

        if (state) {
            PSSpecifier *applistSpecifier = [PSSpecifier preferenceSpecifierNamed:@"AppList" target:self set:nil get:nil detail:nil cell:PSLinkCell edit:nil];
            [applistSpecifier setProperty:@"/tmp/prefsreloaddemo.applist.plist" forKey:@"ALSettingsPath"];
            [applistSpecifier setProperty:@YES forKey:@"ALSettingsDefaultValue"];
            [applistSpecifier setProperty:@"/System/Library/PreferenceBundles/AppList.bundle" forKey:@"lazy-bundle"];
            applistSpecifier->action = @selector(lazyLoadBundle:);
            [(NSMutableArray *)_specifiers addObject:applistSpecifier];
        }

    }
    return _specifiers;
}

- (NSNumber *)isDemoSwitchEnabled {
    return @(state);
}

- (void)setDemoSwitchEnabled:(NSNumber *)newState {
    state = newState.boolValue;
    [self reloadSpecifiers];
}

@end
