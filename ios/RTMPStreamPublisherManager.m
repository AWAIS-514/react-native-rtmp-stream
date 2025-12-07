//
//  RTMPStreamPublisherManager.m
//
//  React Native RTMP Stream - Publisher Manager
//  Created by Nitensclue
//  https://nitensclue.com
//

#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "RTMPStreamClient.h"
#import "RTMPStreamPublisherView.h"

@interface RTMPStreamPublisherManager : RCTViewManager

@end

@implementation RTMPStreamPublisherManager

RCT_EXPORT_MODULE(RTMPStreamPublisher)
RCT_EXPORT_VIEW_PROPERTY(url, NSString)
RCT_EXPORT_VIEW_PROPERTY(volume, float)
RCT_EXPORT_VIEW_PROPERTY(roomRatio, float)
RCT_EXPORT_VIEW_PROPERTY(cryptoKey, NSString)
RCT_EXPORT_VIEW_PROPERTY(denoiseEnable, BOOL)
RCT_EXPORT_VIEW_PROPERTY(HWAccelEnable, BOOL)
RCT_EXPORT_VIEW_PROPERTY(torchEnable, BOOL)
RCT_EXPORT_VIEW_PROPERTY(enhancedRtmp, BOOL)
RCT_EXPORT_VIEW_PROPERTY(frontCamera, BOOL)
RCT_EXPORT_VIEW_PROPERTY(cameraDevice, int)
RCT_EXPORT_VIEW_PROPERTY(keyFrameInterval, int)
RCT_EXPORT_VIEW_PROPERTY(videoOrientation, int)
RCT_EXPORT_VIEW_PROPERTY(audioParam, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(videoParam, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)

- (UIView *)view
{
  return [[RTMPStreamPublisherView alloc] init];
}

RCT_EXPORT_METHOD(start:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock: ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RTMPStreamPublisherView *> *viewRegistry){
      RTMPStreamPublisherView *view = viewRegistry[reactTag];
      [view start];
   }];
}

RCT_EXPORT_METHOD(stop:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock: ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RTMPStreamPublisherView *> *viewRegistry){
      RTMPStreamPublisherView *view = viewRegistry[reactTag];
      [view stop];
   }];
}

RCT_EXPORT_METHOD(startPreview:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock: ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RTMPStreamPublisherView *> *viewRegistry){
      RTMPStreamPublisherView *view = viewRegistry[reactTag];
      [view startPreview];
   }];
}

RCT_EXPORT_METHOD(stopPreview:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock: ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RTMPStreamPublisherView *> *viewRegistry){
      RTMPStreamPublisherView *view = viewRegistry[reactTag];
      [view stopPreview];
   }];
}

@end
