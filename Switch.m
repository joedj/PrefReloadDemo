#import <flipswitch/Flipswitch.h>
#import <notify.h>

@interface PrefsReloadDemoSwitch: NSObject <FSSwitchDataSource>
@end

@implementation PrefsReloadDemoSwitch {
    FSSwitchState _state;
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
    return _state;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
    notify_post("net.joedj.prefsreloaddemo/toggle");
}

@end
