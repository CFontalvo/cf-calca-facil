import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/trace_image.dart';
import '../services/android_bridge.dart';
import '../widgets/trace_overlay.dart';

class ScreenTraceScreen extends StatefulWidget {
  const ScreenTraceScreen({super.key, required this.traceImage});

  final TraceImage traceImage;

  @override
  State<ScreenTraceScreen> createState() => _ScreenTraceScreenState();
}

class _ScreenTraceScreenState extends State<ScreenTraceScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    AndroidBridge.setTracingActive(true);
  }

  @override
  void dispose() {
    AndroidBridge.setTracingActive(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: TraceOverlay(
          traceImage: widget.traceImage,
          initialTransparency: 0,
          showTransparency: false,
        ),
      ),
    );
  }
}
