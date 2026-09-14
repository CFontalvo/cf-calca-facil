import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/trace_image.dart';
import '../theme.dart';
import 'camera_trace_screen.dart';
import 'screen_trace_screen.dart';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key, required this.cameraMode});

  final bool cameraMode;

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  bool _picking = false;

  Future<void> _pickFromDevice() async {
    setState(() => _picking = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );
      if (picked == null || !mounted) return;
      _open(TraceImage.file(name: 'Mi imagen', path: picked.path));
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _open(TraceImage image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => widget.cameraMode
            ? CameraTraceScreen(traceImage: image)
            : ScreenTraceScreen(traceImage: image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cameraMode ? 'Imagen para la cámara' : 'Elige un dibujo',
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 600
                ? 3
                : 2;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mis dibujos',
                          style: TextStyle(
                            color: cfCoral,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Escoge uno de los dibujos incluidos o usa una imagen de tu dispositivo.',
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: _picking ? null : _pickFromDevice,
                          icon: _picking
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.photo_library_rounded),
                          label: const Text('Elegir desde mi dispositivo'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: builtInDrawings.length,
                    itemBuilder: (context, index) {
                      final drawing = builtInDrawings[index];
                      return InkWell(
                        onTap: () => _open(drawing),
                        borderRadius: BorderRadius.circular(20),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE6E1E1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(19),
                                  ),
                                  child: Image.asset(
                                    drawing.path,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  drawing.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
