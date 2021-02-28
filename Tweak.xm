// Originl tweak ShakeLight by KritantaDev
// https://github.com/KritantaDev/ShakeLight

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AudioToolbox/AudioServices.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>
#import <spawn.h>
#import "MediaRemote.h"

BOOL enable;
NSInteger shakeSelection;
HBPreferences *preferences;

@interface UISUserInterfaceStyleMode : NSObject
@property (nonatomic, assign) long long modeValue;
@end

@interface _CDBatterySaver
-(id)batterySaver;
-(BOOL)setPowerMode:(long long)arg1 error:(id *)arg2;
@end

@interface SBVolumeControl
+(id)sharedInstance;
-(void)setActiveCategoryVolume:(float)arg1 ;
-(float)_effectiveVolume;
-(void)toggleMute;
-(void)_updateEffectiveVolume:(float)arg1;
@end

@interface SpringBoard : NSObject
-(void)_runBottomEdgeSwipeTestFromHomeScreen:(BOOL)arg1;
-(void)_simulateLockButtonPress;
-(void)takeScreenshot;
@end

@interface SBReachabilityManager : NSObject
+(id)sharedInstance;
-(void)toggleReachability;
-(BOOL)reachabilityModeActive;
@end

@interface SBApplication : NSObject
@property (nonatomic, readonly) NSString *bundleIdentifier;
@end

@interface LSApplicationWorkspace : NSObject
+(id)defaultWorkspace;
-(void)openApplicationWithBundleIdentifier:(id)arg1 configuration:(id)arg2 completionHandler:(/*^block*/id)arg3 ;
@end

@interface SBMediaController : NSObject
+(id)sharedInstance;
@property (nonatomic) SBApplication *nowPlayingApplication;
@property (nonatomic,readonly) NSString * displayName;
@end

@interface SBWiFiManager : NSObject
+(id)sharedInstance;
-(void)setWiFiEnabled:(BOOL)arg1 ;
-(BOOL)wiFiEnabled;
@end

@interface RadiosPreferences : NSObject
- (BOOL)airplaneMode;
- (void)setAirplaneMode:(BOOL)arg1;
- (void)synchronize;
@end

@interface SBControlCenterController : UIViewController
+(id)sharedInstance;
-(BOOL)isVisible;
-(void)presentAnimated:(BOOL)arg1 completion:(/*^block*/id)arg2;
-(void)dismissAnimated:(BOOL)arg1 completion:(/*^block*/id)arg2;
@end

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

%group ShakeItOff
%hook UIResponder
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    %orig;
    if(event.type == UIEventSubtypeMotionShake && self == [[UIApplication sharedApplication] keyWindow]) {
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
        }
    }
}

%end
%end

%ctor {
    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.nahtedetihw.shakeitoffprefs"];
    [preferences registerBool:&enable default:NO forKey:@"enable"];
    [preferences registerInteger:&shakeSelection default:0 forKey:@"shakeSelection"];

    if (enable) {
        %init(ShakeItOff);
        return;
    }
    return;
}
