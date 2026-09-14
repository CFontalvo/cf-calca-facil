import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import '../widgets/brand_mark.dart';
import 'camera_options_screen.dart';
import 'image_gallery_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 700;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    wide ? 42 : 22,
                    24,
                    wide ? 42 : 22,
                    32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BrandMark(),
                      SizedBox(height: wide ? 52 : 42),
                      Text(
                        '¿Cómo quieres calcar?',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Elige el método que mejor se adapte a tu dibujo y a tu espacio.',
                        style: TextStyle(fontSize: 16, color: cfInk),
                      ),
                      const SizedBox(height: 28),
                      if (wide)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: _screenModeCard(context)),
                              const SizedBox(width: 20),
                              Expanded(child: _cameraModeCard(context)),
                            ],
                          ),
                        )
                      else ...[
                        _screenModeCard(context),
                        const SizedBox(height: 18),
                        _cameraModeCard(context),
                      ],
                      const SizedBox(height: 26),
                      _CommunityLinks(onOpen: (url) => _openLink(context, url)),
                      const SizedBox(height: 28),
                      const Center(
                        child: Text(
                          'Gratis · Sin anuncios · Tus imágenes no salen del dispositivo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF6F7174),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _screenModeCard(BuildContext context) {
    return _ModeCard(
      accent: cfCoral,
      tint: cfSoftCoral,
      icon: Icons.tablet_android_rounded,
      title: 'Sobre la pantalla',
      description:
          'Pon el papel sobre el celular o la tablet. La imagen queda iluminada y bloqueada.',
      bullets: const [
        'Brillo alto',
        'Bloqueo con tres toques',
        'Zoom y rotación',
      ],
      buttonLabel: 'Elegir dibujo',
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ImageGalleryScreen(cameraMode: false),
        ),
      ),
    );
  }

  Widget _cameraModeCard(BuildContext context) {
    return _ModeCard(
      accent: cfNavy,
      tint: cfSoftBlue,
      icon: Icons.camera_alt_rounded,
      title: 'Con la cámara',
      description:
          'Mira la hoja mediante la cámara y úsala con una imagen o sobre otra aplicación.',
      bullets: const [
        'Transparencia ajustable',
        'Imagen propia',
        'Modo flotante',
      ],
      buttonLabel: 'Abrir cámara',
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const CameraOptionsScreen())),
    );
  }

  Future<void> _openLink(BuildContext context, String address) async {
    try {
      final opened = await launchUrl(
        Uri.parse(address),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No fue posible abrir el enlace.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No fue posible abrir el enlace.')),
        );
      }
    }
  }
}

class _CommunityLinks extends StatelessWidget {
  const _CommunityLinks({required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8E2E2)),
      ),
      child: Column(
        children: [
          Text(
            'Más de Christian Fontalvo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cfNavy,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => onOpen('https://christianfontalvo.com/'),
                icon: const Icon(Icons.language_rounded),
                label: const Text('Mi blog'),
              ),
              OutlinedButton.icon(
                onPressed: () => onOpen(
                  'https://www.instagram.com/christianfontalvosketch/',
                ),
                icon: const _InstagramIcon(),
                label: const Text('Instagram'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstagramIcon extends StatelessWidget {
  const _InstagramIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(20),
      painter: _InstagramIconPainter(
        color: IconTheme.of(context).color ?? cfNavy,
      ),
    );
  }
}

class _InstagramIconPainter extends CustomPainter {
  const _InstagramIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.105;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final bounds = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, Radius.circular(size.width * 0.28)),
      paint,
    );
    canvas.drawCircle(size.center(Offset.zero), size.width * 0.22, paint);
    canvas.drawCircle(
      Offset(size.width * 0.73, size.height * 0.27),
      size.width * 0.055,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _InstagramIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.accent,
    required this.tint,
    required this.icon,
    required this.title,
    required this.description,
    required this.bullets,
    required this.buttonLabel,
    required this.onTap,
  });

  final Color accent;
  final Color tint;
  final IconData icon;
  final String title;
  final String description;
  final List<String> bullets;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: accent, size: 30),
            ),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 18),
            ...bullets.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: accent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: onTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(buttonLabel),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
