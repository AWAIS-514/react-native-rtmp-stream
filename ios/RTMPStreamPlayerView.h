//
//  RTMPStreamPlayerView.h
//
//  React Native RTMP Stream - Player View
//  Created by Nitensclue
//  https://nitensclue.com
//

#import <UIKit/UIKit.h>
#import <React/RCTView.h>

@class RTMPStreamPlayerView;

@interface RTMPStreamPlayerView : UIView

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *cryptoKey;
@property (strong, nonatomic) NSString *HTTPReferer;
@property (strong, nonatomic) NSString *HTTPUserAgent;
@property (nonatomic) int bufferTime;
@property (nonatomic) int scaleMode;
@property (nonatomic) BOOL autoplay;
@property (nonatomic) BOOL HWAccelEnable;
@property (nonatomic) float volume;
@property (nonatomic, copy) RCTBubblingEventBlock onChange;

-(int)start;
-(int)stop;

@end
