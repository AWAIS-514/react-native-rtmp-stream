//
//  RTMPStreamPlayerManager.m
//
//  React Native RTMP Stream - Player Manager
//  Created by Nitensclue
//  https://nitensclue.com
//

#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "RTMPStreamClient.h"
#import "RTMPStreamPlayerView.h"

@interface RTMPStreamPlayerManager : RCTViewManager

@end

@implementation RTMPStreamPlayerManager

RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(url, NSString)
RCT_EXPORT_VIEW_PROPERTY(volume, float)
RCT_EXPORT_VIEW_PROPERTY(bufferTime, int)
RCT_EXPORT_VIEW_PROPERTY(scaleMode, int)
RCT_EXPORT_VIEW_PROPERTY(cryptoKey, NSString)
RCT_EXPORT_VIEW_PROPERTY(HWAccelEnable, BOOL)
RCT_EXPORT_VIEW_PROPERTY(HTTPReferer, NSString)
RCT_EXPORT_VIEW_PROPERTY(HTTPUserAgent, NSString)
RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)

RCT_EXPORT_METHOD(start:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock: ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RTMPStreamPlayerView *> *viewRegistry){
      RTMPStreamPlayerView *view = viewRegistry[reactTag];
      [view start];
   }];
}

RCT_EXPORT_METHOD(stop:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock: ^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, RTMPStreamPlayerView *> *viewRegistry){
      RTMPStreamPlayerView *view = viewRegistry[reactTag];
      [view stop];
   }];
}

- (UIView *)view
{
  return [[RTMPStreamPlayerView alloc] init];
}

@end
