/**
 * Simple Live Stream Example
 * 
 * A clean, minimal example of using RTMPStreamPublisher
 * Perfect for getting started with live streaming
 * 
 * Created by Nitensclue
 * https://nitensclue.com
 */

import React, { useRef, useEffect, useState } from 'react';
import { View, StyleSheet, TouchableOpacity, Text, Alert } from 'react-native';
import { RTMPStreamPublisher } from 'react-native-rtmp-stream';
import { request, PERMISSIONS, RESULTS } from 'react-native-permissions';
import { Platform } from 'react-native';

export default function SimpleLiveStream({ streamURL }) {
  const publisherRef = useRef(null);
  const [isStreaming, setIsStreaming] = useState(false);
  const [isPreviewReady, setIsPreviewReady] = useState(false);

  // Request camera and microphone permissions
  useEffect(() => {
    requestPermissions();
  }, []);

  const requestPermissions = async () => {
    try {
      const cameraPermission = Platform.OS === 'ios' 
        ? PERMISSIONS.IOS.CAMERA 
        : PERMISSIONS.ANDROID.CAMERA;
      
      const microphonePermission = Platform.OS === 'ios'
        ? PERMISSIONS.IOS.MICROPHONE
        : PERMISSIONS.ANDROID.RECORD_AUDIO;

      const cameraResult = await request(cameraPermission);
      const micResult = await request(microphonePermission);

      if (cameraResult === RESULTS.GRANTED && micResult === RESULTS.GRANTED) {
        // Start preview after permissions are granted
        setTimeout(() => {
          publisherRef.current?.startPreview();
        }, 500);
      } else {
        Alert.alert('Permissions Required', 'Camera and microphone permissions are required for live streaming.');
      }
    } catch (error) {
      console.error('Permission error:', error);
    }
  };

  // Handle stream events
  const handleEvent = (code, msg) => {
    switch (code) {
      case 2001: // Preview ready
        setIsPreviewReady(true);
        break;
      case 2005: // Stream connected
        setIsStreaming(true);
        break;
      case 2002: // Stopped
      case 2007: // Disconnected
        setIsStreaming(false);
        break;
      case 2003: // Error
      case 2006: // Network timeout
        Alert.alert('Streaming Error', msg);
        setIsStreaming(false);
        break;
    }
  };

  const startStream = () => {
    if (!isPreviewReady) {
      Alert.alert('Not Ready', 'Please wait for camera preview to be ready.');
      return;
    }
    publisherRef.current?.start();
  };

  const stopStream = () => {
    publisherRef.current?.stop();
    setIsStreaming(false);
  };

  const toggleCamera = () => {
    // Note: This requires re-initializing the component with different frontCamera prop
    Alert.alert('Camera Switch', 'To switch cameras, update the frontCamera prop and restart preview.');
  };

  return (
    <View style={styles.container}>
      {/* Camera Preview */}
      <RTMPStreamPublisher
        ref={publisherRef}
        style={StyleSheet.absoluteFill}
        url={streamURL}
        debug={true} // Enable automatic logging
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

      {/* Controls Overlay */}
      <View style={styles.controls}>
        <TouchableOpacity
          style={[styles.button, isStreaming ? styles.stopButton : styles.startButton]}
          onPress={isStreaming ? stopStream : startStream}
        >
          <Text style={styles.buttonText}>
            {isStreaming ? 'Stop Stream' : 'Start Stream'}
          </Text>
        </TouchableOpacity>

        {isPreviewReady && (
          <View style={styles.statusContainer}>
            <View style={[styles.statusDot, isStreaming ? styles.statusActive : styles.statusInactive]} />
            <Text style={styles.statusText}>
              {isStreaming ? 'Live' : 'Ready'}
            </Text>
          </View>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'black',
  },
  controls: {
    position: 'absolute',
    bottom: 40,
    left: 0,
    right: 0,
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  button: {
    paddingVertical: 15,
    paddingHorizontal: 40,
    borderRadius: 25,
    minWidth: 150,
    alignItems: 'center',
  },
  startButton: {
    backgroundColor: '#4CAF50',
  },
  stopButton: {
    backgroundColor: '#F44336',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
  statusContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 15,
    backgroundColor: 'rgba(0, 0, 0, 0.6)',
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 20,
  },
  statusDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginRight: 8,
  },
  statusActive: {
    backgroundColor: '#F44336',
  },
  statusInactive: {
    backgroundColor: '#9E9E9E',
  },
  statusText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '500',
  },
});

