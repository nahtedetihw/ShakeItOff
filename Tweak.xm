#import "Tweak.h"

BOOL enable;
BOOL enableNoiseCancellationBanners;
NSInteger listeningMode;
NSInteger shakeSelection;
HBPreferences *preferences;
static BBServer *bbServer = nil;

static dispatch_queue_t getBBServerQueue() {

    static dispatch_queue_t queue;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
    void* handle = dlopen(NULL, RTLD_GLOBAL);
        if (handle) {
            dispatch_queue_t __weak *pointer = (__weak dispatch_queue_t *) dlsym(handle, "__BBServerQueue");
            if (pointer) queue = *pointer;
            dlclose(handle);
        }
    });

    return queue;

}

static void fakeNotification(NSString *sectionID, NSDate *date, NSString *message, bool banner) {
    
    BBBulletin* bulletin = [[%c(BBBulletin) alloc] init];

    bulletin.title = @"Bluetooth listening mode:";
    bulletin.message = message;
    bulletin.sectionID = sectionID;
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = date;
    bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:sectionID callblock:nil];
    bulletin.clearable = YES;
    bulletin.showsMessagePreview = YES;
    bulletin.publicationDate = date;
    bulletin.lastInterruptDate = date;

    if (banner) {
        if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
            dispatch_sync(getBBServerQueue(), ^{
                [bbServer publishBulletin:bulletin destinations:15];
            });
        }
    }
}

void noiseCancelTestBanner() {
    fakeNotification(@"com.apple.Music", [NSDate date], @"Active Noise Cancellation Mode", true);
}

void transparencyTestBanner() {
    fakeNotification(@"com.apple.Music", [NSDate date], @"Transparency Mode", true);
}

void normalTestBanner() {
    fakeNotification(@"com.apple.Music", [NSDate date], @"Normal Mode", true);
}

void toggleFlashlight() {
    AVCaptureDevice *flashLight = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([flashLight isTorchAvailable] && [flashLight isTorchModeSupported:AVCaptureTorchModeOn]) {
        BOOL success = [flashLight lockForConfiguration:nil];
        if (success) {
            if ([flashLight isTorchActive]) {
                [flashLight setTorchMode:AVCaptureTorchModeOff];
            } else {
                [flashLight setTorchMode:AVCaptureTorchModeOn];
        }
        [flashLight unlockForConfiguration];
        }
    }
    AudioServicesPlaySystemSound(1519);
}

void toggleRespring() {
    pid_t pid;
    const char* args[] = {"killall", "SpringBoard", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
    AudioServicesPlaySystemSound(1519);
}

void toggleSafeMode() {
    pid_t pid;
    const char *args[] = {"killall", "-SEGV", "SpringBoard", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char * const *)args, NULL);
    AudioServicesPlaySystemSound(1519);
}

void toggleDarkMode() {
    BOOL darkEnabled = ([UITraitCollection currentTraitCollection].userInterfaceStyle == UIUserInterfaceStyleDark);
    
    UISUserInterfaceStyleMode *styleMode = [[%c(UISUserInterfaceStyleMode) alloc] init];
    if (darkEnabled) {
        styleMode.modeValue = 1;
    } else if (!darkEnabled)  {
        styleMode.modeValue = 2;
    }
    AudioServicesPlaySystemSound(1519);
}

void toggleLowPowerMode() {
    BOOL success = NO;
    if ([[%c(NSProcessInfo) processInfo] isLowPowerModeEnabled]) {
        [[%c(_CDBatterySaver) batterySaver] setPowerMode:0 error:nil];
        success = YES;
    } else {
        [[%c(_CDBatterySaver) batterySaver] setPowerMode:1 error:nil];
        success = YES;
    }
    AudioServicesPlaySystemSound(1519);
}

void toggleSound() {
    if ([[%c(SBVolumeControl) sharedInstance] _effectiveVolume] == 0) {
        [[%c(SBVolumeControl) sharedInstance] setActiveCategoryVolume:100];
        [[%c(SBVolumeControl) sharedInstance] _updateEffectiveVolume:100];
    } else {
        [[%c(SBVolumeControl) sharedInstance] setActiveCategoryVolume:0];
        [[%c(SBVolumeControl) sharedInstance] _updateEffectiveVolume:0];
    }
    //[[%c(SBVolumeControl) sharedInstance] toggleMute];
    AudioServicesPlaySystemSound(1519);
}

void toggleLockScreen() {
    [(SpringBoard *)[UIApplication sharedApplication] _simulateLockButtonPress];
    AudioServicesPlaySystemSound(1519);
}

void togglePreviousTrack() {
    MRMediaRemoteSendCommand(kMRPreviousTrack, nil);
    AudioServicesPlaySystemSound(1519);
}

void togglePlayPause() {
    MRMediaRemoteSendCommand(kMRTogglePlayPause, nil);
    AudioServicesPlaySystemSound(1519);
}

void toggleNextTrack() {
    MRMediaRemoteSendCommand(kMRNextTrack, nil);
    AudioServicesPlaySystemSound(1519);
}

void toggleReachability() {
    [[%c(SBReachabilityManager) sharedInstance] toggleReachability];
    AudioServicesPlaySystemSound(1519);
}

void toggleNowPlayingApp() {
    SBApplication *app = [[%c(SBMediaController) sharedInstance] nowPlayingApplication];
    [[%c(LSApplicationWorkspace) defaultWorkspace] openApplicationWithBundleIdentifier:app.bundleIdentifier configuration:nil completionHandler:nil];
    AudioServicesPlaySystemSound(1519);
}

void toggleScreenshot() {
    [(SpringBoard *)[UIApplication sharedApplication] takeScreenshot];
    AudioServicesPlaySystemSound(1519);
}

void toggleAirplaneMode() {
    RadiosPreferences *prefs = [[%c(RadiosPreferences) alloc] init];
    if (prefs.airplaneMode == NO) {
        [prefs setAirplaneMode:YES];
    } else {
        [prefs setAirplaneMode:NO];
    }
    AudioServicesPlaySystemSound(1519);
}

void toggleControlCenter() {
    if ([[%c(SBControlCenterController) sharedInstance] isVisible] == NO) {
    [[%c(SBControlCenterController) sharedInstance] presentAnimated:YES completion:nil];
    } else {
    [[%c(SBControlCenterController) sharedInstance] dismissAnimated:YES completion:nil];
    }
    AudioServicesPlaySystemSound(1519);
}

void toggleWiFi() {
    if ([[%c(SBWiFiManager) sharedInstance] wiFiEnabled] == NO) {
        [[%c(SBWiFiManager) sharedInstance] setWiFiEnabled:YES];
    } else {
        [[%c(SBWiFiManager) sharedInstance] setWiFiEnabled:NO];
    }
    AudioServicesPlaySystemSound(1519);
}

void toggleBattery() {
    if ([((SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance]).coverSheetViewController _isShowingChargingModal] == NO) {
        [((SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance]).coverSheetViewController _transitionChargingViewToVisible:YES showBattery:YES animated:YES];
    } else {
        [((SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance]).coverSheetViewController dismissViewControllerAnimated:YES completion:nil];
    }
    AudioServicesPlaySystemSound(1519);
}

void toggleNoiseCancellation() {
    if (listeningMode == 0) {
        [[[[[[%c(SBMediaController) sharedInstance] valueForKey:@"_routingController"] pickedRoute] logicalLeaderOutputDevice] valueForKey:@"_avOutputDevice"] setCurrentBluetoothListeningMode:@"AVOutputDeviceBluetoothListeningModeAudioTransparency"];
        listeningMode = 1;
        if (enableNoiseCancellationBanners) transparencyTestBanner();
    } else if (listeningMode == 1) {
    [[[[[[%c(SBMediaController) sharedInstance] valueForKey:@"_routingController"] pickedRoute] logicalLeaderOutputDevice] valueForKey:@"_avOutputDevice"] setCurrentBluetoothListeningMode:@"AVOutputDeviceBluetoothListeningModeActiveNoiseCancellation"];
        listeningMode = 2;
        if (enableNoiseCancellationBanners) noiseCancelTestBanner();
    } else if (listeningMode == 2) {
    [[[[[[%c(SBMediaController) sharedInstance] valueForKey:@"_routingController"] pickedRoute] logicalLeaderOutputDevice] valueForKey:@"_avOutputDevice"] setCurrentBluetoothListeningMode:@"AVOutputDeviceBluetoothListeningModeNormal"];
        listeningMode = 0;
        if (enableNoiseCancellationBanners) normalTestBanner();
        }
    AudioServicesPlaySystemSound(1519);
}

void toggleOrientationLock() {
    if ([[%c(SBOrientationLockManager) sharedInstance] isUserLocked] == YES) {
        [[%c(SBOrientationLockManager) sharedInstance] unlock];
    } else {
        [[%c(SBOrientationLockManager) sharedInstance] lock];
    }
    AudioServicesPlaySystemSound(1519);
}

void toggleBluetooth() {
    if ([[%c(BluetoothManager) sharedInstance] enabled] == NO) {
        [[%c(BluetoothManager) sharedInstance] setEnabled:YES];
    } else {
        [[%c(BluetoothManager) sharedInstance] setEnabled:NO];
    }
    AudioServicesPlaySystemSound(1519);
}

void toggleRinger() {
    if ([((SBMainWorkspace *)[%c(SBMainWorkspace) sharedInstance]).ringerControl isRingerMuted] == NO) {
        [((SBMainWorkspace *)[%c(SBMainWorkspace) sharedInstance]).ringerControl setRingerMuted:YES];
        [((SBMainWorkspace *)[%c(SBMainWorkspace) sharedInstance]).ringerControl activateRingerHUDFromMuteSwitch:0];
    } else {
        [((SBMainWorkspace *)[%c(SBMainWorkspace) sharedInstance]).ringerControl setRingerMuted:NO];
        [((SBMainWorkspace *)[%c(SBMainWorkspace) sharedInstance]).ringerControl activateRingerHUDFromMuteSwitch:1];
    }
    AudioServicesPlaySystemSound(1519);
}

%group ShakeItOff

%hook UIWindow
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    %orig;
    BOOL isScreenOn = MSHookIvar<BOOL>([%c(SBLockScreenManager) sharedInstance], "_isScreenOn");
    if (event.type == UIEventSubtypeMotionShake && self == [[UIApplication sharedApplication] keyWindow] && isScreenOn == YES) {
        switch (shakeSelection) {
            case 0:
                toggleFlashlight();
            break;
            
            case 1:
                toggleRespring();
            break;
                
            case 2:
                toggleSafeMode();
            break;
                
            case 3:
                toggleDarkMode();
            break;
                
            case 4:
                toggleLowPowerMode();
            break;
                
            case 5:
                toggleSound();
            break;
                
            case 6:
                toggleLockScreen();
            break;
                
            case 7:
                togglePreviousTrack();
            break;
                
            case 8:
                togglePlayPause();
            break;
                
            case 9:
                toggleNextTrack();
            break;
                
            case 10:
                toggleReachability();
            break;
                
            case 11:
                toggleNowPlayingApp();
            break;
                
            case 12:
                toggleScreenshot();
            break;
                
            case 13:
                toggleAirplaneMode();
            break;
                
            case 14:
                toggleControlCenter();
            break;
                
            case 15:
                toggleWiFi();
            break;
                
            case 16:
                toggleBattery();
            break;
                
            case 17:
                toggleNoiseCancellation();
            break;
                
            case 18:
                toggleOrientationLock();
            break;
                
            case 19:
                toggleBluetooth();
            break;
                
            case 20:
                toggleRinger();
            break;
        }
    }
}

%end

%hook BBServer

- (id)initWithQueue:(id)arg1 {

    bbServer = %orig;
    
    return bbServer;

}

- (id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
    
    bbServer = %orig;

    return bbServer;

}

- (void)dealloc {

    if (bbServer == self) bbServer = nil;

    %orig;

}

%end

%end

%ctor {
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.nahtedetihw.shakeitoffprefs"];
    [preferences registerBool:&enable default:NO forKey:@"enable"];
    [preferences registerBool:&enableNoiseCancellationBanners default:NO forKey:@"enableNoiseCancellationBanners"];
    [preferences registerInteger:&shakeSelection default:0 forKey:@"shakeSelection"];

    if (enable) {
        %init(ShakeItOff);
        return;
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)noiseCancelTestBanner, (CFStringRef)@"com.nahtedetihw.shakeitoff/NoiseCancel", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)transparencyTestBanner, (CFStringRef)@"com.nahtedetihw.shakeitoff/Transparency", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)normalTestBanner, (CFStringRef)@"com.nahtedetihw.shakeitoff/Normal", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
    }
    return;
}
