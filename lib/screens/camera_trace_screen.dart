import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/trace_image.dart';
import '../services/android_bridge.dart';
import '../theme.dart';
import '../widgets/trace_overlay.dart';

class CameraTraceScreen extends StatefulWidget {
  const CameraTraceScreen({super.key, required this.traceImage});

  final TraceImage traceImage;

  @override
  State<CameraTraceScreen> createState() => _CameraTraceScreenState();
}

class _CameraTraceScreenState extends State<CameraTraceScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    AndroidBridge.setTracingActive(true);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(
          () => _error = 'Este dispositivo no tiene una cámara disponible.',
        );
        return;
      }
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      final minimumZoom = await controller.getMinZoomLevel();
      await controller.setZoomLevel(minimumZoom);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on CameraException catch (error) {
      if (mounted) {
        setState(
          () => _error = error.code == 'CameraAccessDenied'
              ? 'Necesitamos permiso para mostrar la cámara.'
              : 'No fue posible iniciar la cámara: ${error.description ?? error.code}',
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    AndroidBridge.setTracingActive(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: cfCanvas,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.no_photography_rounded,
                  color: cfCoral,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: cfCoral)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _CoverCameraPreview(controller: controller),
          TraceOverlay(
            traceImage: widget.traceImage,
            initialTransparency: 0.7,
            showTransparency: true,
          ),
        ],
      ),
    );
  }
}

class _CoverCameraPreview extends StatelessWidget {
  const _CoverCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportRatio = constraints.maxWidth / constraints.maxHeight;
          final sensorRatio = controller.value.aspectRatio;
          final previewRatio = constraints.maxHeight > constraints.maxWidth
              ? 1 / sensorRatio
              : sensorRatio;
          final scale = previewRatio > viewportRatio
              ? previewRatio / viewportRatio
              : viewportRatio / previewRatio;

          return Transform.scale(
            scale: scale,
            child: Center(child: CameraPreview(controller)),
          );
        },
      ),
    );
  }
}
