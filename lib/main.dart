import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/share/share_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN');

  // Limit image cache: default is 1000 images / 100 MB — overkill for a finance app
  PaintingBinding.instance.imageCache.maximumSize = 50;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 32 << 20; // 32 MB

  ShareHandler.init();
  runApp(
    const ProviderScope(
      child: ApurseApp(),
    ),
  );
}
