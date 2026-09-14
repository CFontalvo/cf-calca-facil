import 'package:flutter/material.dart';

import '../theme.dart';
import 'floating_camera_screen.dart';
import 'image_gallery_screen.dart';

class CameraOptionsScreen extends StatelessWidget {
  const CameraOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calcar con la cámara')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
              children: [
                const Text(
                  'Elige de dónde quieres ver el dibujo mientras enfocas la hoja.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 22),
                _OptionCard(
                  icon: Icons.add_photo_alternate_rounded,
                  title: 'Elegir una imagen',
                  description:
                      'Usa uno de tus dibujos o una foto guardada. La imagen aparecerá sobre la cámara.',
                  accent: cfCoral,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const ImageGalleryScreen(cameraMode: true),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _OptionCard(
                  icon: Icons.picture_in_picture_alt_rounded,
                  title: 'Usar otra aplicación',
                  description:
                      'Deja un dibujo abierto en cualquier aplicación y usa la cámara semitransparente encima.',
                  accent: cfNavy,
                  badge: 'NUEVO',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FloatingCameraScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: cfCoral,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(description),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
