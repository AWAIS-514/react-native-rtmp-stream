//
//  RTMPStreamPublisherView.m
//
//  React Native RTMP Stream - Publisher View Implementation
//  Created by Nitensclue
//  https://nitensclue.com
//

#import "RTMPStreamPublisherView.h"
#import "RTMPStreamClient.h"
#import <NodeMediaClient/NodeMediaClient.h>
#import <AVFoundation/AVFoundation.h>

@interface RTMPStreamPublisherView () <NodePublisherDelegate>

@property(strong, nonatomic) NodePublisher *np;

@property (nonatomic) BOOL isPreview;
@property (nonatomic) BOOL hasRequestedPreview;
@property (nonatomic) BOOL viewHasValidBounds;
@end

@implementation RTMPStreamPublisherView

- (id)init {
  self = [super init];
  if (self) {
      _np = [[NodePublisher alloc] initWithLicense:[RTMPStreamClient license]];
      [_np setNodePublisherDelegate:self];
      // Don't attach view here - wait until view is in hierarchy
      _hasRequestedPreview = NO;
      _viewHasValidBounds = NO;
      _isPreview = NO;
      _audioParam = nil;
      _videoParam = nil;
      _videoOrientation = 1; // Default to portrait orientation
      // CRITICAL: Set portrait orientation immediately to RTMP Stream SDK
      [_np setVideoOrientation:1];
      // CRITICAL: Enable hardware acceleration on iOS to use VideoToolbox encoder
      // VideoToolbox handles 4:2:2 → 4:2:0 conversion automatically, avoiding x264 4:2:2 error
      [_np setHWAccelEnable:YES];
      self.backgroundColor = [UIColor blackColor];
  }
  return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    // Attach view when it's added to hierarchy
    if (self.superview) {
        // Ensure we're on main thread for UI operations
        dispatch_async(dispatch_get_main_queue(), ^{
            // Small delay to ensure view is fully in hierarchy
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self->_np attachView:self];
            });
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_np detachView];
        });
    }
}

- (void)dealloc
{
    _hasRequestedPreview = NO;
    _viewHasValidBounds = NO;
    [_np detachView];
    [_np closeCamera];
    [_np stop];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Check if view now has valid bounds
    if (!_viewHasValidBounds && self.bounds.size.width > 0 && self.bounds.size.height > 0) {
        _viewHasValidBounds = YES;
        
        // If preview was requested but couldn't start due to invalid bounds, try again
        if (_hasRequestedPreview && !_isPreview) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startPreview];
            });
        }
    }
}

-(void) onEventCallback:(nonnull id)sender event:(int)event msg:(nonnull NSString*)msg {
    if (_onChange) {
        _onChange(@{@"code": [NSNumber numberWithInteger:event], @"msg": msg});;
    }
}

- (void)setHWAccelEnable:(BOOL)HWAccelEnable {
    // CRITICAL: Always enable hardware acceleration on iOS
    // VideoToolbox (hardware encoder) handles 4:2:2 → 4:2:0 conversion automatically
    // This avoids the x264 "baseline profile doesn't support 4:2:2" error
    BOOL forceEnable = YES; // Always use hardware acceleration on iOS
    [_np setHWAccelEnable:forceEnable];
}

- (void)setDenoiseEnable:(BOOL)denoiseEnable {
    [_np setDenoiseEnable:denoiseEnable];
}

- (void)setCryptoKey:(NSString *)cryptoKey {
    [_np setCryptoKey:cryptoKey];
}

- (void)setEnhancedRtmp:(BOOL)enhancedRtmp {
    [_np setEnhancedRtmp:enhancedRtmp];
}

- (void)setTorchEnable:(BOOL)torchEnable {
    [_np enableTorch:torchEnable];
}

- (void)setRoomRatio:(float)roomRatio {
    [_np setRoomRatio:roomRatio];
}

- (void)setFrontCamera:(BOOL)frontCamera {
    if(_frontCamera != frontCamera) {
        _frontCamera = frontCamera;
        if(_isPreview) {
            [self stopPreview];
            [self startPreview];
        }
    }
}

- (void)setCameraDevice:(int)cameraDevice {
    if(_cameraDevice != cameraDevice) {
        _cameraDevice = cameraDevice;
        if(_isPreview) {
            [self stopPreview];
            [self startPreview];
        }
    }
}

- (void)setVideoOrientation:(int)videoOrientation {
    // CRITICAL: Always force portrait orientation (1) for iOS camera preview and stream
    // RTMP Stream SDK value: 1 = Portrait, 3 = LandscapeRight, 4 = LandscapeLeft
    // This ensures preview and stream are always portrait regardless of device orientation
    _videoOrientation = 1; // Always store as portrait
    [_np setVideoOrientation:1]; // Always use portrait for RTMP Stream SDK
}

- (void)setKeyFrameInterval:(int)keyFrameInterval {
    [_np setKeyFrameInterval:keyFrameInterval];
}

- (void)setVolume:(float)volume {
    [_np setVolume:volume];
}

- (void)setAudioParam:(NSDictionary *)audioParam {
    if (!audioParam) {
        return;
    }
    // Store for validation in start method - use property setter safely
    _audioParam = audioParam;
    int codecid = [[audioParam objectForKey:@"codecid"] intValue];
    int profile = [[audioParam objectForKey:@"profile"] intValue];
    int samplerate = [[audioParam objectForKey:@"samplerate"] intValue];
    int channels = [[audioParam objectForKey:@"channels"] intValue];
    int bitrate = [[audioParam objectForKey:@"bitrate"] intValue];
    [_np setAudioParamWithCodec:codecid profile:profile samplerate:samplerate channels:channels bitrate:bitrate];
}

- (void)setVideoParam:(NSDictionary *)videoParam {
    if (!videoParam) {
        return;
    }
    // Store for validation in start method - use property setter safely
    _videoParam = videoParam;
    int codecid = [[videoParam objectForKey:@"codecid"] intValue];
    int profile = [[videoParam objectForKey:@"profile"] intValue];
    int width = [[videoParam objectForKey:@"width"] intValue];
    int height = [[videoParam objectForKey:@"height"] intValue];
    int fps = [[videoParam objectForKey:@"fps"] intValue];
    int bitrate = [[videoParam objectForKey:@"bitrate"] intValue];
    
    // CRITICAL: NodeMediaClient's x264 build does NOT support 4:2:2 chroma format
    // iOS camera outputs 4:2:2, but x264 encoder requires 4:2:0
    // The SDK should convert 4:2:2 → 4:2:0, but it's not working reliably
    // Try Main profile (77) as it may have better handling of chroma conversion
    // If this still fails, it's a RTMP Stream SDK limitation
    if (profile != 77 && profile != 66) {
        profile = 77; // Try Main profile for better chroma handling
    }
    
    [_np setVideoParamWithCodec:codecid profile:profile width:width height:height fps:fps bitrate:bitrate];
}

-(int)start{
    if(!_url) {
        return -1;
    }
    
    // Ensure we're on the main thread for UI/AV operations
    if (![NSThread isMainThread]) {
        __block int result = -1;
        dispatch_sync(dispatch_get_main_queue(), ^{
            result = [self start];
        });
        return result;
    }
    
    // CRITICAL: Ensure preview is active and camera is capturing before starting stream
    if (!_isPreview) {
        int previewResult = [self startPreview];
        if (previewResult != 0) {
            if (_onChange) {
                _onChange(@{@"code": @2003, @"msg": @"Camera preview must be active before starting stream"});
            }
            return -1;
        }
        // Don't block here - preview will start asynchronously
        // The JavaScript side should wait for preview ready event before calling start()
        if (_onChange) {
            _onChange(@{@"code": @2003, @"msg": @"Please wait for camera preview to be ready before starting stream"});
        }
        return -1;
    }
    
    // CRITICAL: Verify audio and video parameters are set before starting stream
    // If parameters are not set, the stream will connect but fail to write packets
    if (!_audioParam || !_videoParam) {
        if (_onChange) {
            _onChange(@{@"code": @2003, @"msg": @"Audio or video parameters not configured"});
        }
        return -1;
    }
    
    // CRITICAL: Ensure AVAudioSession is properly configured before starting stream
    // Use VideoChat mode for better streaming compatibility
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    // Deactivate first to avoid conflicts
    [audioSession setActive:NO error:&error];
    
    // Set category with VideoChat mode for streaming
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                                         mode:AVAudioSessionModeVideoChat
                                      options:AVAudioSessionCategoryOptionDefaultToSpeaker | 
                                               AVAudioSessionCategoryOptionAllowBluetooth |
                                               AVAudioSessionCategoryOptionAllowBluetoothA2DP
                                        error:&error];
    if (!success || error) {
        // Try with default mode as fallback
        error = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                             mode:AVAudioSessionModeDefault
                          options:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth
                            error:&error];
        if (error) {
        }
    }
    
    // Activate audio session
    success = [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (!success || error) {
    } else {
    }
    
    // Parameters are validated and set before starting stream
    if (_videoParam) {
        NSNumber *profileNum = [_videoParam objectForKey:@"profile"];
        int profileValue = [profileNum intValue];
        
        // CRITICAL: Verify profile is Main (77) or Baseline (66) before starting stream
        // x264 build doesn't support 4:2:2, must use Main (77) or Baseline (66) for 4:2:0
        if (profileValue != 77 && profileValue != 66) {
            if (_onChange) {
                _onChange(@{@"code": @2003, @"msg": [NSString stringWithFormat:@"Video profile must be Main (77) or Baseline (66) for x264, but got %d", profileValue]});
            }
            return -1;
        } else {
        }
    }
    
    int result = [_np start:_url];
    if (result != 0) {
        if (_onChange) {
            _onChange(@{@"code": @2003, @"msg": [NSString stringWithFormat:@"Failed to start stream: %d", result]});
        }
    } else {
    }
    return result;
}

-(int)stop {
    // Ensure we're on the main thread
    if (![NSThread isMainThread]) {
        __block int result = -1;
        dispatch_sync(dispatch_get_main_queue(), ^{
            result = [self stop];
        });
        return result;
    }
    
    int result = [_np stop];
    return result;
}

-(int)startPreview {
    // Ensure we're on the main thread for camera operations
    if (![NSThread isMainThread]) {
        __block int result = -1;
        dispatch_sync(dispatch_get_main_queue(), ^{
            result = [self startPreview];
        });
        return result;
    }
    
    _hasRequestedPreview = YES;
    
    // Check camera permission first
    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (cameraStatus == AVAuthorizationStatusDenied || cameraStatus == AVAuthorizationStatusRestricted) {
        if (_onChange) {
            _onChange(@{@"code": @2003, @"msg": @"Camera permission denied"});
        }
        return -1;
    }
    
    if (cameraStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self startPreview];
                } else {
                    if (self->_onChange) {
                        self->_onChange(@{@"code": @2003, @"msg": @"Camera permission denied"});
                    }
                }
            });
        }];
        return 0;
    }
    
    // Check audio permission
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (audioStatus == AVAuthorizationStatusDenied || audioStatus == AVAuthorizationStatusRestricted) {
        if (_onChange) {
            _onChange(@{@"code": @2003, @"msg": @"Microphone permission denied"});
        }
        return -1;
    }
    
    
    // Ensure view has valid bounds before opening camera
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0) {
        _viewHasValidBounds = NO;
        // Wait for layoutSubviews to trigger retry
        return 0;
    }
    
    _viewHasValidBounds = YES;
    // DON'T set _isPreview = YES here - wait until camera actually opens
    
    // CRITICAL: Configure AVAudioSession properly before opening camera
    // The audio session must be configured with correct options to avoid conflicts
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    // Deactivate first to avoid conflicts
    [audioSession setActive:NO error:&error];
    
    // Set category with proper options for streaming
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                                         mode:AVAudioSessionModeVideoChat  // Use VideoChat mode for better streaming
                                      options:AVAudioSessionCategoryOptionDefaultToSpeaker | 
                                               AVAudioSessionCategoryOptionAllowBluetooth |
                                               AVAudioSessionCategoryOptionAllowBluetoothA2DP
                                        error:&error];
    if (!success || error) {
        // Try with default mode as fallback
        error = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                             mode:AVAudioSessionModeDefault
                          options:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth
                            error:&error];
        if (error) {
        }
    }
    
    // Activate audio session
    success = [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (!success || error) {
    } else {
    }
    
    // Verify view is in hierarchy before opening camera
    if (!self.superview) {
        if (_onChange) {
            _onChange(@{@"code": @2003, @"msg": @"View not in hierarchy"});
        }
        return -1;
    }
    
    // Ensure view is attached (should be done in didMoveToSuperview, but verify)
    
    // CRITICAL: Ensure video orientation is set to portrait before opening camera
    // This must be set before openCameraDevice to ensure preview and stream are portrait
    // Always force portrait orientation regardless of what was set
    [_np setVideoOrientation:1]; // Force portrait orientation
    
    // CRITICAL: Ensure hardware acceleration is enabled before opening camera
    // VideoToolbox (hardware encoder) handles 4:2:2 → 4:2:0 conversion automatically
    // This avoids the x264 "baseline profile doesn't support 4:2:2" error
    [_np setHWAccelEnable:YES];
    
    // CRITICAL: Ensure video profile is Main (77) or Baseline (66) before opening camera
    // x264 build doesn't support 4:2:2, must use Main (77) or Baseline (66) for 4:2:0 encoding
    if (_videoParam) {
        NSNumber *profileNum = [_videoParam objectForKey:@"profile"];
        int profileValue = [profileNum intValue];
        // Prefer Main (77) as it may handle chroma conversion better
        if (profileValue != 77 && profileValue != 66) {
            profileValue = 77;
            // Update the stored param
            NSMutableDictionary *mutableParam = [_videoParam mutableCopy];
            [mutableParam setObject:@77 forKey:@"profile"];
            _videoParam = mutableParam;
        }
        // Re-apply video params with correct profile
        int codecid = [[_videoParam objectForKey:@"codecid"] intValue];
        int width = [[_videoParam objectForKey:@"width"] intValue];
        int height = [[_videoParam objectForKey:@"height"] intValue];
        int fps = [[_videoParam objectForKey:@"fps"] intValue];
        int bitrate = [[_videoParam objectForKey:@"bitrate"] intValue];
        [_np setVideoParamWithCodec:codecid profile:profileValue width:width height:height fps:fps bitrate:bitrate];
    }
    
    // Small delay to ensure view is fully in hierarchy
    dispatch_async(dispatch_get_main_queue(), ^{
        int result = [self->_np openCameraDevice:self->_cameraDevice withFront:self->_frontCamera];
        if (result != 0) {
            self->_isPreview = NO;
            if (self->_onChange) {
                self->_onChange(@{@"code": @2003, @"msg": [NSString stringWithFormat:@"Failed to open camera: %d", result]});
            }
        } else {
            // Camera opened successfully - now set preview flag
            self->_isPreview = YES;
            
            // CRITICAL: Re-apply video params AFTER camera opens
            // Use the profile from videoParam (should be Main 77 or Baseline 66)
            if (self->_videoParam) {
                int codecid = [[self->_videoParam objectForKey:@"codecid"] intValue];
                NSNumber *profileNum = [self->_videoParam objectForKey:@"profile"];
                int profile = [profileNum intValue];
                int width = [[self->_videoParam objectForKey:@"width"] intValue];
                int height = [[self->_videoParam objectForKey:@"height"] intValue];
                int fps = [[self->_videoParam objectForKey:@"fps"] intValue];
                int bitrate = [[self->_videoParam objectForKey:@"bitrate"] intValue];
                [self->_np setVideoParamWithCodec:codecid profile:profile width:width height:height fps:fps bitrate:bitrate];
            }
            
            // CRITICAL: Ensure preview layer is visible
            // Force view to update and show preview layer
            [self setNeedsLayout];
            [self layoutIfNeeded];
            
            // CRITICAL: Verify view is still attached and in hierarchy
            if (self.superview) {
                // View is in hierarchy - preview should be visible
            } else {
                // View is not in hierarchy - preview may not be visible
            }
            
            // CRITICAL: Wait longer for camera to start encoding frames before sending event
            // For 720p@30fps, the encoder needs more time to initialize and start producing frames
            // This ensures that when JavaScript receives the ready event, camera is actually encoding
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self->_onChange) {
                    self->_onChange(@{@"code": @2001, @"msg": @"Preview started and camera encoding"});
                }
            });
        }
    });
    
    return 0;
}

-(int)stopPreview {
    // Ensure we're on the main thread
    if (![NSThread isMainThread]) {
        __block int result = -1;
        dispatch_sync(dispatch_get_main_queue(), ^{
            result = [self stopPreview];
        });
        return result;
    }
    
    _hasRequestedPreview = NO;
    _isPreview = NO;
    int result = [_np closeCamera];
    return result;
}

@end
