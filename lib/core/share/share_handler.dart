import 'package:flutter/services.dart';
import '../router/app_router.dart';

class ShareHandler {
  static const _channel = MethodChannel('com.jizhang.app/share');

  static void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'getSharedImage') {
        final path = call.arguments as String?;
        if (path != null && path.isNotEmpty) {
          appRouter.push('/ai-scan', extra: path);
        }
      }
    });

    // Check if we were launched from a share intent
    _channel.invokeMethod('getSharedImage').then((path) {
      if (path != null && path is String && path.isNotEmpty) {
        appRouter.push('/ai-scan', extra: path);
      }
    });
  }
}
