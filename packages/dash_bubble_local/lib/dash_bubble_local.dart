import 'package:flutter/services.dart';

class DashBubble {
  static const platform = MethodChannel('dev.moaz.dash_bubble/bubble');
  
  static final DashBubble _instance = DashBubble._internal();
  
  factory DashBubble() => _instance;
  DashBubble._internal();
  
  static DashBubble get instance => _instance;
  
  /// Check if overlay permission is granted
  Future<bool> hasOverlayPermission() async {
    try {
      final bool result = await platform.invokeMethod<bool>('hasOverlayPermission') ?? false;
      return result;
    } catch (e) {
      print('Error checking overlay permission: $e');
      return false;
    }
  }
  
  /// Request overlay permission
  Future<bool> requestOverlayPermission() async {
    try {
      final bool result = await platform.invokeMethod<bool>('requestOverlayPermission') ?? false;
      return result;
    } catch (e) {
      print('Error requesting overlay permission: $e');
      return false;
    }
  }
  
  /// Start the floating bubble
  Future<bool> startBubble({
    required BubbleOptions bubbleOptions,
    required Function() onTap,
  }) async {
    try {
      final Map<String, dynamic> args = {
        'bubbleIcon': bubbleOptions.bubbleIcon,
        'distanceToClose': bubbleOptions.distanceToClose,
        'enableAnimateToEdge': bubbleOptions.enableAnimateToEdge,
        'enableClose': bubbleOptions.enableClose,
        'bubbleSize': bubbleOptions.bubbleSize,
        'opacity': bubbleOptions.opacity,
      };
      
      final bool result = await platform.invokeMethod<bool>('startBubble', args) ?? false;
      return result;
    } catch (e) {
      print('Error starting bubble: $e');
      return false;
    }
  }
  
  /// Stop the floating bubble
  Future<bool> stopBubble() async {
    try {
      final bool result = await platform.invokeMethod<bool>('stopBubble') ?? false;
      return result;
    } catch (e) {
      print('Error stopping bubble: $e');
      return false;
    }
  }
}

class BubbleOptions {
  final String bubbleIcon;
  final int distanceToClose;
  final bool enableAnimateToEdge;
  final bool enableClose;
  final double bubbleSize;
  final double opacity;
  
  BubbleOptions({
    required this.bubbleIcon,
    required this.distanceToClose,
    required this.enableAnimateToEdge,
    required this.enableClose,
    required this.bubbleSize,
    required this.opacity,
  });
}
