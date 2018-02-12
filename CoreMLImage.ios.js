// /**
//  * @providesModule CoreMLImage
//  * @flow
//  */
// 'use strict';

// var NativeCoreMLImage = require('NativeModules').CoreMLImageModule;

// /**
//  * High-level docs for the CoreMLImage iOS API can be written here.
//  */

// var CoreMLImage = {
//   test: function() {
//     NativeCoreMLImage.test();
//   }
// };

// module.exports = CoreMLImage;

import React, { Component } from 'react'
import {
  StyleSheet,
  requireNativeComponent,
  Dimensions
} from 'react-native'

const CoreMLImageNative = requireNativeComponent('CoreMLImage', null)

const styles = StyleSheet.create({
  container: {
    width: Dimensions.get('window').width,
    height: Dimensions.get('window').height,
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 999,
    backgroundColor: 'transparent'
  }
})

export default class CoreMLImageView extends Component {
  onClassification(evt) {
    if (this.props.onClassification) {
      this.props.onClassification(evt.nativeEvent)
    }
  }
  render() {
    return (
      <CoreMLImageNative
        modelFile={this.props.modelFile}
        imageFile={this.props.imageFile}
        onClassification={evt => this.onClassification(evt)}
        style={styles.container}
      >
        {this.props.children}
      </CoreMLImageNative>
    )
  }
}
