import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/android_bridge.dart';
import '../theme.dart';

class FloatingCameraScreen extends StatefulWidget {
  const FloatingCameraScreen({super.key});

  @override
  State<FloatingCameraScreen> createState() => _FloatingCameraScreenState();
}

class _FloatingCameraScreenState extends State<FloatingCameraScreen>
    with WidgetsBindingObserver {
  static const _initialOpacity = 0.70;
  bool _overlayAllowed = false;
  bool _cameraAllowed = false;
  bool _running = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshState();
  }

  Future<void> _refreshState() async {
    try {
      final values = await Future.wait([
        AndroidBridge.hasOverlayPermission(),
        AndroidBridge.hasCameraPermission(),
        AndroidBridge.isCameraOverlayRunning(),
      ]);
      if (!mounted) return;
      setState(() {
        _overlayAllowed = values[0];
        _cameraAllowed = values[1];
        _running = values[2];
        _loading = false;
      });
    } on PlatformException catch (error) {
      _showError(error.message ?? 'No fue posible consultar los permisos.');
    }
  }

  Future<void> _requestCamera() async {
    final granted = await AndroidBridge.requestCameraPermission();
    if (mounted) setState(() => _cameraAllowed = granted);
  }

  Future<void> _start() async {
    if (!_cameraAllowed) {
      await _requestCamera();
      if (!_cameraAllowed) return;
    }
    if (!_overlayAllowed) {
      await AndroidBridge.requestOverlayPermission();
      return;
    }
    try {
      await AndroidBridge.startCameraOverlay(_initialOpacity);
      if (mounted) setState(() => _running = true);
    } on PlatformException catch (error) {
      _showError(error.message ?? 'No fue posible iniciar la cámara flotante.');
    }
  }

  Future<void> _stop() async {
    await AndroidBridge.stopCameraOverlay();
    if (mounted) setState(() => _running = false);
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara sobre otra app')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cfSoftBlue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.layers_rounded, color: cfNavy, size: 56),
                      SizedBox(height: 12),
                      Text(
                        'Otra aplicación + cámara',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cfNavy,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Deja listo el dibujo en cualquier aplicación. Luego verás la cámara semitransparente encima.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _Step(
                  number: '1',
                  text:
                      'Abre la aplicación donde está el dibujo y déjalo listo.',
                ),
                _Step(
                  number: '2',
                  text: 'Vuelve aquí y toca “Iniciar cámara flotante”.',
                ),
                _Step(
                  number: '3',
                  text:
                      'La app volverá atrás y mostrará la cámara transparente.',
                ),
                _Step(
                  number: '4',
                  text:
                      'Toca “Bloquear” para impedir cambios. Desbloquea con 3 toques en el botón CF.',
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 18),
                  child: Text(
                    'La cámara inicia al 70 %. Podrás ajustarla en el panel flotante.',
                    style: TextStyle(color: Color(0xFF6F7174), fontSize: 13),
                  ),
                ),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_running)
                  OutlinedButton.icon(
                    onPressed: _stop,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Detener cámara flotante'),
                  )
                else ...[
                  if (!_cameraAllowed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OutlinedButton.icon(
                        onPressed: _requestCamera,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Permitir uso de la cámara'),
                      ),
                    ),
                  if (!_overlayAllowed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OutlinedButton.icon(
                        onPressed: AndroidBridge.requestOverlayPermission,
                        icon: const Icon(Icons.picture_in_picture_alt_rounded),
                        label: const Text('Permitir mostrar sobre otras apps'),
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: _start,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Iniciar cámara flotante'),
                  ),
                ],
                const SizedBox(height: 18),
                const Text(
                  'La app no captura ni guarda el contenido de otras aplicaciones. Los botones Inicio y Recientes siguen disponibles por seguridad de Android.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6F7174), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: cfCoral,
            foregroundColor: Colors.white,
            child: Text(
              number,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
