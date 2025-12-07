//
//  RTMPStreamPublisherView.h
//
//  React Native RTMP Stream - Publisher View
//  Created by Nitensclue
//  https://nitensclue.com
//

#import <UIKit/UIKit.h>
#import <React/RCTView.h>

@class RTMPStreamPublisherView;

@interface RTMPStreamPublisherView : UIView

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *cryptoKey;
@property (strong, nonatomic) NSDictionary *audioParam;
@property (strong, nonatomic) NSDictionary *videoParam;
@property (nonatomic) BOOL HWAccelEnable;
@property (nonatomic) BOOL denoiseEnable;
@property (nonatomic) BOOL torchEnable;
@property (nonatomic) BOOL enhancedRtmp;
@property (nonatomic) BOOL frontCamera;
@property (nonatomic) float volume;
@property (nonatomic) float roomRatio;
@property (nonatomic) int cameraDevice;
@property (nonatomic) int keyFrameInterval;
@property (nonatomic) int videoOrientation;
@property (nonatomic, copy) RCTBubblingEventBlock onChange;

-(int)start;
-(int)stop;
-(int)startPreview;
-(int)stopPreview;

@end
