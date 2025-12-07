//
//  RTMPStreamPlayer.jsx
//
//  React Native RTMP Stream - Player Component
//  Created by Nitensclue
//  https://nitensclue.com
//

import React from 'react';
import { PropTypes } from 'prop-types';
import { requireNativeComponent, UIManager, findNodeHandle } from 'react-native';

class RTMPStreamPlayer extends React.Component {

    componentWillUnmount = () => {
        this.stop();
    }

    start = () => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(this), "start", []);
    }

    stop = () => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(this), "stop", []);
    }

    pause = () => {
        UIManager.dispatchViewManagerCommand(findNodeHandle(this), "pause", []);
    }

    _onChange(event) {
        if (this.props.onEvent) {
            this.props.onEvent(event.nativeEvent.code, event.nativeEvent.msg);
        }
    }

    render() {
        return <RCTRTMPStreamPlayer
            {...this.props}
            onChange={this._onChange.bind(this)}
        />
    }
}

RTMPStreamPlayer.propTypes = {
    url: PropTypes.string,
    scaleMode: PropTypes.oneOf(['ScaleToFill', 'ScaleAspectFit', 'ScaleAspectFill']),
    bufferTime: PropTypes.number,
    maxBufferTime: PropTypes.number,
    timeout: PropTypes.number,
    cryptoKey: PropTypes.string,
    HWAccelEnable: PropTypes.bool,
    playInBackground: PropTypes.bool,
    onEvent: PropTypes.func,
};

const RCTRTMPStreamPlayer = requireNativeComponent('RTMPStreamPlayer', RTMPStreamPlayer, {
    nativeOnly: { onChange: true }
});

export default RTMPStreamPlayer;

