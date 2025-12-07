//
//  index.jsx
//
//  React Native RTMP Stream - Main Export
//  Created by Nitensclue
//  https://nitensclue.com
//

import { NativeModules } from 'react-native';
import RTMPStreamPlayer from './RTMPStreamPlayer';
import RTMPStreamPublisher from './RTMPStreamPublisher';

const RTMPStreamClient = NativeModules.RTMPStreamClient;
export { RTMPStreamClient, RTMPStreamPlayer, RTMPStreamPublisher };
