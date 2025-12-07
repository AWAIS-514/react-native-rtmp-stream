# react-native-rtmp-stream

![react-native-rtmp-stream](assets/logo.svg)

[![npm version](https://img.shields.io/npm/v/react-native-rtmp-stream.svg)](https://www.npmjs.com/package/react-native-rtmp-stream)
[![npm downloads](https://img.shields.io/npm/dm/react-native-rtmp-stream.svg)](https://www.npmjs.com/package/react-native-rtmp-stream)

A powerful React Native library for RTMP/RTMPS live streaming with full iOS and Android support. Optimized for Mux, YouTube Live, Twitch, and other streaming platforms.

**Created by [Nitensclue](https://nitensclue.com)**

## Features

<div align="center">

### ✅ Full RTMP/RTMPS Support
![RTMP Support](assets/gifs/rtmp-support.svg)
**Stream to any RTMP server** - Compatible with Mux, YouTube Live, Twitch, and custom RTMP servers

### ✅ iOS & Android
![iOS Android](assets/gifs/ios-android.svg)
**Native implementation for both platforms** - Write once, stream everywhere

### ✅ Hardware Acceleration
![Hardware Acceleration](assets/gifs/hardware-accel.svg)
**Automatic hardware encoding on iOS (VideoToolbox)** - Optimized performance with minimal CPU usage

### ✅ Portrait & Landscape
![Orientation Support](assets/gifs/orientation.svg)
**Full orientation support** - Seamless rotation and orientation handling

### ✅ Camera Controls
![Camera Controls](assets/gifs/camera-controls.svg)
**Front/back camera, torch, zoom** - Full camera control at your fingertips

### ✅ Audio/Video Configuration
![AV Configuration](assets/gifs/av-config.svg)
**Customizable bitrate, resolution, FPS** - Fine-tune your stream quality

### ✅ Mux Optimized
![Mux Optimized](assets/gifs/mux-optimized.svg)
**Tested and optimized for Mux streaming** - Production-ready Mux integration

### ✅ Production Ready
![Production Ready](assets/gifs/production-ready.svg)
**Battle-tested in production environments** - Reliable and stable for real-world use

</div>

**Created by [Nitensclue](https://nitensclue.com)**

## Installation

```bash
npm install react-native-rtmp-stream
```

### iOS Setup

```bash
cd ios && pod install && cd ..
```

### Android Setup

No additional setup required. The library automatically links.

## Permissions

### iOS

Add to `ios/YourApp/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to your camera for live streaming.</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone for live streaming.</string>
```

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-feature android:name="android.hardware.camera"/>
<uses-feature android:name="android.hardware.camera.autofocus"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.FLASHLIGHT"/>
```

## Quick Start

### Simple Example

```javascript
import React, { useRef, useEffect } from 'react';
import { View, StyleSheet } from 'react-native';
import { RTMPStreamPublisher } from 'react-native-rtmp-stream';

export default function LiveStream() {
  const publisherRef = useRef(null);

  useEffect(() => {
    // Start preview after component mounts
    setTimeout(() => {
      publisherRef.current?.startPreview();
    }, 1000);
  }, []);

  const handleEvent = (code, msg) => {
    if (code === 2001) {
      // Preview ready - start streaming
      setTimeout(() => {
        publisherRef.current?.start();
      }, 500);
    } else if (code === 2005) {
      // Stream connected successfully
      console.log('Streaming live!');
    }
  };

  return (
    <View style={StyleSheet.absoluteFill}>
      <RTMPStreamPublisher
        ref={publisherRef}
        style={StyleSheet.absoluteFill}
        url="rtmps://global-live.mux.com:443/app/YOUR_STREAM_KEY"
        debug={true} // Enable automatic event logging
        audioParam={{
          codecid: RTMPStreamPublisher.CODEC_ID_AAC,
          profile: RTMPStreamPublisher.PROFILE_AAC_LC,
          samplerate: 32000,
          channels: 1,
          bitrate: 32000,
        }}
        videoParam={{
          codecid: RTMPStreamPublisher.CODEC_ID_H264,
          profile: RTMPStreamPublisher.PROFILE_H264_MAIN,
          width: 720,
          height: 1280,
          fps: 30,
          bitrate: 1500000,
        }}
        frontCamera={false}
        videoOrientation={RTMPStreamPublisher.VIDEO_ORIENTATION_PORTRAIT}
        HWAccelEnable={true}
        keyFrameInterval={30}
        onEvent={handleEvent}
      />
    </View>
  );
}
```

### Complete Example with Controls

See the [SimpleLiveStream example](./examples/SimpleLiveStream.js) for a complete implementation with:
- Permission handling
- Start/Stop controls
- Status indicators
- Error handling
- Debug mode enabled

## API Reference

### RTMPStreamPublisher

Main component for live streaming.

#### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `url` | `string` | **Required** | RTMP/RTMPS stream URL |
| `audioParam` | `object` | **Required** | Audio encoding parameters |
| `videoParam` | `object` | **Required** | Video encoding parameters |
| `frontCamera` | `boolean` | `false` | Use front camera |
| `videoOrientation` | `number` | `1` | Video orientation (see constants) |
| `HWAccelEnable` | `boolean` | `true` (iOS) | Enable hardware acceleration |
| `keyFrameInterval` | `number` | `30` | Keyframe interval (frames) |
| `denoiseEnable` | `boolean` | `false` | Enable audio denoising |
| `torchEnable` | `boolean` | `false` | Enable camera torch |
| `enhancedRtmp` | `boolean` | `false` | Use enhanced RTMP protocol |
| `cameraDevice` | `number` | `0` | Camera device type (see constants) |
| `roomRatio` | `number` | `0` | Room echo cancellation ratio |
| `volume` | `number` | `1.0` | Audio volume (0.0 - 1.0) |
| `cryptoKey` | `string` | - | Encryption key for secure streams |
| `debug` | `boolean` | `false` | Enable automatic event logging to console |
| `onEvent` | `function` | - | Event callback `(code, msg) => {}` |

#### Methods

- `start()` - Start streaming
- `stop()` - Stop streaming
- `startPreview()` - Start camera preview
- `stopPreview()` - Stop camera preview

#### Event Codes

| Code | Description |
|------|-------------|
| `2000` | Connecting to server |
| `2001` | Preview started / Ready to stream |
| `2003` | Error occurred |
| `2004` | Connection started |
| `2005` | Stream connected successfully |
| `2006` | Network timeout |
| `2007` | Stream disconnected |

### Audio Parameters

```javascript
audioParam: {
  codecid: RTMPStreamPublisher.CODEC_ID_AAC,  // Audio codec
  profile: RTMPStreamPublisher.PROFILE_AAC_LC, // AAC profile
  samplerate: 32000,  // Sample rate: 8000, 16000, 32000, 44100, 48000
  channels: 1,        // Channels: 1 (mono) or 2 (stereo)
  bitrate: 32000,     // Audio bitrate (bits per second)
}
```

### Video Parameters

```javascript
videoParam: {
  codecid: RTMPStreamPublisher.CODEC_ID_H264,  // Video codec
  profile: RTMPStreamPublisher.PROFILE_H264_MAIN, // H.264 profile
  width: 720,   // Video width (pixels)
  height: 1280, // Video height (pixels)
  fps: 30,      // Frame rate (frames per second)
  bitrate: 1500000, // Video bitrate (bits per second)
}
```

## Recommended Settings

### iOS - Portrait (9:16)

```javascript
audioParam: {
  codecid: RTMPStreamPublisher.CODEC_ID_AAC,
  profile: RTMPStreamPublisher.PROFILE_AAC_LC,
  samplerate: 32000,
  channels: 1,
  bitrate: 32000,
},
videoParam: {
  codecid: RTMPStreamPublisher.CODEC_ID_H264,
  profile: RTMPStreamPublisher.PROFILE_H264_MAIN,
  width: 720,
  height: 1280,
  fps: 30,
  bitrate: 1500000,
},
HWAccelEnable: true, // Always enabled on iOS
videoOrientation: RTMPStreamPublisher.VIDEO_ORIENTATION_PORTRAIT,
```

### iOS - Landscape (16:9)

```javascript
videoParam: {
  codecid: RTMPStreamPublisher.CODEC_ID_H264,
  profile: RTMPStreamPublisher.PROFILE_H264_MAIN,
  width: 1280,
  height: 720,
  fps: 30,
  bitrate: 2000000,
},
videoOrientation: RTMPStreamPublisher.VIDEO_ORIENTATION_LANDSCAPE_RIGHT,
```

### Android - Portrait (9:16)

```javascript
audioParam: {
  codecid: RTMPStreamPublisher.CODEC_ID_AAC,
  profile: RTMPStreamPublisher.PROFILE_AAC_LC,
  samplerate: 44100,
  channels: 2,
  bitrate: 64000,
},
videoParam: {
  codecid: RTMPStreamPublisher.CODEC_ID_H264,
  profile: RTMPStreamPublisher.PROFILE_H264_BASELINE,
  width: 720,
  height: 1280,
  fps: 30,
  bitrate: 2000000,
},
```

### Android - Landscape (16:9)

```javascript
videoParam: {
  codecid: RTMPStreamPublisher.CODEC_ID_H264,
  profile: RTMPStreamPublisher.PROFILE_H264_BASELINE,
  width: 1280,
  height: 720,
  fps: 30,
  bitrate: 2500000,
},
```

## Constants

### Codec IDs

```javascript
RTMPStreamPublisher.CODEC_ID_H264 = 27
RTMPStreamPublisher.CODEC_ID_H265 = 173
RTMPStreamPublisher.CODEC_ID_AAC = 86018
```

### H.264 Profiles

```javascript
RTMPStreamPublisher.PROFILE_AUTO = 0
RTMPStreamPublisher.PROFILE_H264_BASELINE = 66
RTMPStreamPublisher.PROFILE_H264_MAIN = 77
RTMPStreamPublisher.PROFILE_H264_HIGH = 100
```

### AAC Profiles

```javascript
RTMPStreamPublisher.PROFILE_AAC_LC = 1
RTMPStreamPublisher.PROFILE_AAC_HE = 4
RTMPStreamPublisher.PROFILE_AAC_HE_V2 = 28
RTMPStreamPublisher.PROFILE_AAC_LD = 22
RTMPStreamPublisher.PROFILE_AAC_ELD = 38
```

### Video Orientation

```javascript
RTMPStreamPublisher.VIDEO_ORIENTATION_PORTRAIT = 1
RTMPStreamPublisher.VIDEO_ORIENTATION_LANDSCAPE_RIGHT = 3
RTMPStreamPublisher.VIDEO_ORIENTATION_LANDSCAPE_LEFT = 4
```

### Camera Device Types

```javascript
RTMPStreamPublisher.DEVICE_TYPE_WideAngleCamera = 0
RTMPStreamPublisher.DEVICE_TYPE_TelephotoCamera = 1
RTMPStreamPublisher.DEVICE_TYPE_UltraWideCamera = 2
RTMPStreamPublisher.DEVICE_TYPE_DualCamera = 3
RTMPStreamPublisher.DEVICE_TYPE_TripleCamera = 4
```

## Streaming to Mux

```javascript
const muxStreamKey = 'YOUR_MUX_STREAM_KEY';
const streamURL = `rtmps://global-live.mux.com:443/app/${muxStreamKey}`;

<RTMPStreamPublisher
  url={streamURL}
  // ... other props
/>
```

## Streaming to YouTube Live

```javascript
const youtubeStreamKey = 'YOUR_YOUTUBE_STREAM_KEY';
const streamURL = `rtmp://a.rtmp.youtube.com/live2/${youtubeStreamKey}`;

<RTMPStreamPublisher
  url={streamURL}
  // ... other props
/>
```

## Streaming to Twitch

```javascript
const twitchStreamKey = 'YOUR_TWITCH_STREAM_KEY';
const streamURL = `rtmp://live.twitch.tv/app/${twitchStreamKey}`;

<RTMPStreamPublisher
  url={streamURL}
  // ... other props
/>
```

## Platform-Specific Notes

### iOS

- **Hardware Acceleration**: Automatically enabled. Uses VideoToolbox for encoding.
- **Chroma Format**: Automatically handles 4:2:2 → 4:2:0 conversion.
- **Profile**: Use `PROFILE_H264_MAIN` (77) for best compatibility.
- **Orientation**: Portrait orientation is enforced by default.

### Android

- **Hardware Acceleration**: Can be enabled via `HWAccelEnable` prop.
- **Profile**: `PROFILE_H264_BASELINE` (66) recommended for compatibility.
- **Audio**: Stereo (2 channels) recommended for better quality.

## Troubleshooting

### Black Screen on iOS

1. Ensure camera permissions are granted
2. Wait for `2001` event before calling `start()`
3. Check that view has valid bounds

### Stream Disconnects Immediately

1. Verify stream URL is correct
2. Ensure audio/video parameters are set
3. Wait for preview ready event (2001) before starting
4. Check network connectivity

### Write Packet Errors

- **iOS**: Ensure `HWAccelEnable={true}` (enabled by default)
- **Android**: Try `PROFILE_H264_BASELINE` instead of HIGH

### Audio Issues

1. Check microphone permissions
2. Verify `audioParam` is correctly configured
3. Ensure `samplerate` matches platform recommendations

## Examples

### Simple Example with Debug Mode

The simplest way to use RTMPStreamPublisher with automatic logging:

```javascript
<RTMPStreamPublisher
  ref={publisherRef}
  url="rtmps://global-live.mux.com:443/app/YOUR_STREAM_KEY"
  debug={true} // All events will be automatically logged
  // ... other props
/>
```

With `debug={true}`, you'll see automatic logs like:
```
[RTMPStreamPublisher ios] ✅ Preview Ready (2001): Preview started and camera encoding
[RTMPStreamPublisher ios] 🔄 Connection Started (2004): connect to rtmps://...
[RTMPStreamPublisher ios] ✅ Stream Connected (2005): connect success
```

### Complete Example

See the [SimpleLiveStream example](./examples/SimpleLiveStream.js) for a complete implementation with:
- Permission handling
- Start/Stop controls  
- Status indicators
- Error handling
- Debug mode enabled

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) first.

## License

MIT

## Author

**Nitensclue**

- Website: [https://nitensclue.com](https://nitensclue.com)
- GitHub: [@nitensclue](https://github.com/Awais-514)

## Support

For issues, questions, or contributions, please open an issue on [GitHub](https://github.com/Awais-514/react-native-rtmp-stream/issues).

---

Made with ❤️ by [Nitensclue](https://nitensclue.com)
