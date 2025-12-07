//
//  RTMPStreamPublisher.jsx
//
//  React Native RTMP Stream - Publisher Component
//  Created by Nitensclue
//  https://nitensclue.com
//

import React from 'react';
import { PropTypes } from 'prop-types';
import { requireNativeComponent, UIManager, findNodeHandle, Platform } from 'react-native';

class RTMPStreamPublisher extends React.Component {

    componentDidMount = () => {
        // Preview should only start after:
        // 1. Permissions are granted
        // 2. View layout is complete
        // 3. Parent explicitly calls startPreview()
    }

    componentWillUnmount = () => {
        this.stopPreview();
        this.stop();
    }

    start = () => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(this), "start", []);
    }

    stop = () => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(this), "stop", []);
    }

    startPreview = () => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(this), "startPreview", []);
    }

    stopPreview = () => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(this), "stopPreview", []);
    }

    _onChange(event) {
        const { code, msg } = event.nativeEvent;
        const { onEvent, debug } = this.props;

        // Automatic debug logging if debug mode is enabled
        if (debug) {
            const eventNames = {
                2000: 'Connecting',
                2001: 'Preview Ready',
                2002: 'Stopped',
                2003: 'Error',
                2004: 'Connection Started',
                2005: 'Stream Connected',
                2006: 'Network Timeout',
                2007: 'Disconnected',
            };
            const eventName = eventNames[code] || `Event ${code}`;
            const emoji = code === 2001 || code === 2005 ? '✅' : code === 2003 || code === 2006 ? '❌' : code === 2004 ? '🔄' : 'ℹ️';
            console.log(`[RTMPStreamPublisher ${Platform.OS}] ${emoji} ${eventName} (${code}): ${msg}`);
        }

        // Call user's onEvent handler if provided
        if (onEvent) {
            onEvent(code, msg);
        }
    }

    render() {
        return <RCTRTMPStreamPublisher
            {...this.props}
            onChange={this._onChange.bind(this)}
        />
    }
}

RTMPStreamPublisher.propTypes = {
    url: PropTypes.string,
    audioParam: PropTypes.shape({
        codecid: PropTypes.number,
        profile: PropTypes.number,
        samplerate: PropTypes.oneOf([8000, 16000, 32000, 44100, 48000]),
        channels: PropTypes.oneOf([1, 2]),
        bitrate: PropTypes.number,
    }),
    videoParam: PropTypes.shape({
        codecid: PropTypes.number,
        profile: PropTypes.number,
        width: PropTypes.number,
        height: PropTypes.number,
        fps: PropTypes.number,
        bitrate: PropTypes.number,
    }),
    cryptoKey: PropTypes.string,
    HWAccelEnable: PropTypes.bool,
    denoiseEnable: PropTypes.bool,
    torchEnable: PropTypes.bool,
    enhancedRtmp: PropTypes.bool,
    frontCamera: PropTypes.bool,
    cameraDevice: PropTypes.number,
    roomRatio: PropTypes.number,
    videoOrientation: PropTypes.number,
    keyFrameInterval: PropTypes.number,
    volume: PropTypes.number,
    debug: PropTypes.bool, // New prop for automatic debug logging
    onEvent: PropTypes.func,
};

// Codec IDs
RTMPStreamPublisher.CODEC_ID_H264 = 27;
RTMPStreamPublisher.CODEC_ID_H265 = 173;
RTMPStreamPublisher.CODEC_ID_AAC = 86018;

// H.264 Profiles
RTMPStreamPublisher.PROFILE_AUTO = 0;
RTMPStreamPublisher.PROFILE_H264_BASELINE = 66;
RTMPStreamPublisher.PROFILE_H264_MAIN = 77;
RTMPStreamPublisher.PROFILE_H264_HIGH = 100;

// H.265 Profiles
RTMPStreamPublisher.PROFILE_H265_MAIN = 1;

// AAC Profiles
RTMPStreamPublisher.PROFILE_AAC_LC = 1;
RTMPStreamPublisher.PROFILE_AAC_HE = 4;
RTMPStreamPublisher.PROFILE_AAC_HE_V2 = 28;
RTMPStreamPublisher.PROFILE_AAC_LD = 22;
RTMPStreamPublisher.PROFILE_AAC_ELD = 38;

// Video Orientation
RTMPStreamPublisher.VIDEO_ORIENTATION_PORTRAIT = 1;
RTMPStreamPublisher.VIDEO_ORIENTATION_LANDSCAPE_RIGHT = 3;
RTMPStreamPublisher.VIDEO_ORIENTATION_LANDSCAPE_LEFT = 4;

// Camera Flags
RTMPStreamPublisher.FLAG_AF = 1;
RTMPStreamPublisher.FLAG_AE = 2;
RTMPStreamPublisher.FLAG_AWB = 4;

// Camera Device Types
RTMPStreamPublisher.DEVICE_TYPE_WideAngleCamera = 0;
RTMPStreamPublisher.DEVICE_TYPE_TelephotoCamera = 1;
RTMPStreamPublisher.DEVICE_TYPE_UltraWideCamera = 2;
RTMPStreamPublisher.DEVICE_TYPE_DualCamera = 3;
RTMPStreamPublisher.DEVICE_TYPE_TripleCamera = 4;

const RCTRTMPStreamPublisher = requireNativeComponent('RTMPStreamPublisher', RTMPStreamPublisher, {
    nativeOnly: { onChange: true }
});

export default RTMPStreamPublisher;
