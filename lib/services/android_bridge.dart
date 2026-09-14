import 'package:flutter/services.dart';

class AndroidBridge {
  AndroidBridge._();

  static const _channel = MethodChannel(
    'com.christianfontalvo.cfcalcafacil/native',
  );

  static Future<void> setTracingActive(bool active) async {
    await _channel.invokeMethod<void>('setTracingActive', {'active': active});
  }

  static Future<bool> hasOverlayPermission() async {
    return await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;
  }

  static Future<void> requestOverlayPermission() async {
    await _channel.invokeMethod<void>('requestOverlayPermission');
  }

  static Future<bool> hasCameraPermission() async {
    return await _channel.invokeMethod<bool>('hasCameraPermission') ?? false;
  }

  static Future<bool> requestCameraPermission() async {
    return await _channel.invokeMethod<bool>('requestCameraPermission') ??
        false;
  }

  static Future<void> startCameraOverlay(double opacity) async {
    await _channel.invokeMethod<void>('startCameraOverlay', {
      'opacity': opacity,
    });
  }

  static Future<void> stopCameraOverlay() async {
    await _channel.invokeMethod<void>('stopCameraOverlay');
  }

  static Future<bool> isCameraOverlayRunning() async {
    return await _channel.invokeMethod<bool>('isCameraOverlayRunning') ?? false;
  }
}
