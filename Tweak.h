// Original tweak ShakeLight by KritantaDev
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
#import <dlfcn.h>
//#import <BulletinBoard/BBDataProvider.h>
//#import <BulletinBoard/BBBulletin.h>
//#import <BulletinBoard/BBAction.h>

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

@interface SBHomeHardwareButton : NSObject
-(void)doublePressDown:(id)arg1 ;
-(void)longPress:(id)arg1 ;
@end

@interface SpringBoard : NSObject
@property (nonatomic,readonly) SBHomeHardwareButton * homeHardwareButton;
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

@interface CSCoverSheetViewController : UIViewController
-(BOOL)_isShowingChargingModal;
-(void)_transitionChargingViewToVisible:(BOOL)arg1 showBattery:(BOOL)arg2 animated:(BOOL)arg3;
@end

@interface SBLockScreenManager : NSObject
@property (nonatomic,readonly) CSCoverSheetViewController * coverSheetViewController;
+(id)sharedInstance;
-(BOOL)isScreenOn;
@end

@interface AVOutputDevice : NSObject
-(BOOL)isLogicalDeviceLeader;
-(id)currentBluetoothListeningMode;
- (void)setCurrentBluetoothListeningMode:(NSString *)arg1;
@end

@interface MPAVRoute : NSObject
- (id)logicalLeaderOutputDevice;
@end

@interface MPAVRoutingController : NSObject
@property(readonly, nonatomic)MPAVRoute* pickedRoute;
@end

@interface BBAction : NSObject
+ (id)actionWithLaunchBundleID:(id)arg1 callblock:(id)arg2;
@end

@interface BBBulletin : NSObject
@property(nonatomic, copy)NSString* sectionID;
@property(nonatomic, copy)NSString* recordID;
@property(nonatomic, copy)NSString* publisherBulletinID;
@property(nonatomic, copy)NSString* title;
@property(nonatomic, copy)NSString* message;
@property(nonatomic, retain)NSDate* date;
@property(assign, nonatomic)BOOL clearable;
@property(nonatomic)BOOL showsMessagePreview;
@property(nonatomic, copy)BBAction* defaultAction;
@property(nonatomic, copy)NSString* bulletinID;
@property(nonatomic, retain)NSDate* lastInterruptDate;
@property(nonatomic, retain)NSDate* publicationDate;
@end

@interface BBServer : NSObject
- (void)publishBulletin:(BBBulletin *)arg1 destinations:(NSUInteger)arg2 alwaysToLockScreen:(BOOL)arg3;
- (void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2;
-(void)_removeBulletins:(id)arg1 forSectionID:(id)arg2 shouldSync:(BOOL)arg3 ;
-(id)_bulletinsForIDs:(id)arg1 ;
-(id)allBulletinIDsForSectionID:(id)arg1 ;
-(void)_removeActiveSectionID:(id)arg1 ;
@end

@interface SBAssistantController
+ (id)sharedInstance;
-(void)siriPresentation:(id)arg1 requestsPunchout:(id)arg2 withHandler:(/*^block*/id)arg3;
-(void)dismissAssistantViewIfNecessaryWithAnimation:(long long)arg1 factory:(id)arg2 dismissalOptions:(id)arg3 completion:(/*^block*/id)arg4 ;
-(BOOL)isVisible;
@end

@interface SBOrientationLockManager : NSObject
+(id)sharedInstance;
-(BOOL)isUserLocked;
-(void)unlock;
-(void)lock;
@end

@interface BluetoothManager
+ (id)sharedInstance;
- (BOOL)powered;
- (BOOL)enabled;
- (BOOL)setPowered:(BOOL)powered;
- (void)setEnabled:(BOOL)enabled;
@end

@interface RPScreenRecorder
@property (assign,getter=isRecording,nonatomic) BOOL recording;
+ (id)sharedRecorder;
-(void)startRecordingWithHandler:(/*^block*/id)arg1 ;
-(void)stopRecordingWithHandler:(/*^block*/id)arg1 ;
@end

@interface SBRingerControl
- (BOOL)isRingerMuted;
- (void)setRingerMuted:(BOOL)muted;
-(void)activateRingerHUDFromMuteSwitch:(int)arg1;
@end

@interface SBMainWorkspace
@property (nonatomic,readonly) SBRingerControl * ringerControl;
- (id)sharedInstance;
@end
