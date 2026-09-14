import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/trace_image.dart';
import '../theme.dart';

class TraceOverlay extends StatefulWidget {
  const TraceOverlay({
    super.key,
    required this.traceImage,
    required this.initialTransparency,
    this.showTransparency = true,
    this.onExit,
  });

  final TraceImage traceImage;
  final double initialTransparency;
  final bool showTransparency;
  final VoidCallback? onExit;

  @override
  State<TraceOverlay> createState() => _TraceOverlayState();
}

class _TraceOverlayState extends State<TraceOverlay> {
  Offset _offset = Offset.zero;
  Offset _gestureStartOffset = Offset.zero;
  Offset _gestureStartFocal = Offset.zero;
  double _scale = 1;
  double _gestureStartScale = 1;
  double _rotation = 0;
  double _gestureStartRotation = 0;
  double _flipX = 1;
  double _flipY = 1;
  late double _transparency;
  bool _locked = false;
  int _unlockTapCount = 0;
  DateTime? _lastUnlockTap;

  @override
  void initState() {
    super.initState();
    _transparency = widget.initialTransparency;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _gestureStartOffset = _offset;
    _gestureStartFocal = details.focalPoint;
    _gestureStartScale = _scale;
    _gestureStartRotation = _rotation;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_gestureStartScale * details.scale).clamp(0.25, 6.0);
      _rotation = _gestureStartRotation + details.rotation;
      _offset = _gestureStartOffset + details.focalPoint - _gestureStartFocal;
    });
  }

  void _reset() {
    setState(() {
      _offset = Offset.zero;
      _scale = 1;
      _rotation = 0;
      _flipX = 1;
      _flipY = 1;
    });
  }

  void _unlockTap() {
    final now = DateTime.now();
    if (_lastUnlockTap == null ||
        now.difference(_lastUnlockTap!).inMilliseconds > 850) {
      _unlockTapCount = 1;
    } else {
      _unlockTapCount += 1;
    }
    _lastUnlockTap = now;
    if (_unlockTapCount >= 3) {
      setState(() {
        _locked = false;
        _unlockTapCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          ignoring: _locked,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            child: Center(
              child: Transform.translate(
                offset: _offset,
                child: Transform.rotate(
                  angle: _rotation,
                  child: Transform.scale(
                    scale: _scale,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(_flipX, _flipY, 1),
                      child: Opacity(
                        opacity: 1 - _transparency,
                        child: Image(
                          image: widget.traceImage.provider,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (!_locked) ...[
          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              child: _RoundButton(
                icon: Icons.close_rounded,
                tooltip: 'Salir',
                onTap: widget.onExit ?? () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: _ControlPanel(
                transparency: _transparency,
                showTransparency: widget.showTransparency,
                onTransparencyChanged: (value) =>
                    setState(() => _transparency = value),
                onRotateLeft: () => setState(() => _rotation -= math.pi / 2),
                onRotateRight: () => setState(() => _rotation += math.pi / 2),
                onFlipHorizontal: () => setState(() => _flipX *= -1),
                onFlipVertical: () => setState(() => _flipY *= -1),
                onReset: _reset,
                onLock: () => setState(() => _locked = true),
              ),
            ),
          ),
        ] else
          Positioned(
            top: 18,
            right: 14,
            child: SafeArea(
              child: GestureDetector(
                onTap: _unlockTap,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: cfNavy.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.white, size: 19),
                      Text(
                        '3×',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.transparency,
    required this.showTransparency,
    required this.onTransparencyChanged,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onFlipHorizontal,
    required this.onFlipVertical,
    required this.onReset,
    required this.onLock,
  });

  final double transparency;
  final bool showTransparency;
  final ValueChanged<double> onTransparencyChanged;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onFlipHorizontal;
  final VoidCallback onFlipVertical;
  final VoidCallback onReset;
  final VoidCallback onLock;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF2FFFFFF),
      elevation: 10,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showTransparency)
              Row(
                children: [
                  const Icon(Icons.opacity_rounded, color: cfCoral, size: 21),
                  const SizedBox(width: 6),
                  Text(
                    'Transparencia ${(transparency * 100).round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: transparency,
                      min: 0,
                      max: 0.95,
                      divisions: 19,
                      onChanged: onTransparencyChanged,
                    ),
                  ),
                ],
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ToolButton(
                    icon: Icons.rotate_left_rounded,
                    label: 'Girar',
                    onTap: onRotateLeft,
                  ),
                  _ToolButton(
                    icon: Icons.rotate_right_rounded,
                    label: 'Girar',
                    onTap: onRotateRight,
                  ),
                  _ToolButton(
                    icon: Icons.flip_rounded,
                    label: 'Voltear',
                    onTap: onFlipHorizontal,
                  ),
                  _ToolButton(
                    icon: Icons.swap_vert_rounded,
                    label: 'Vertical',
                    onTap: onFlipVertical,
                  ),
                  _ToolButton(
                    icon: Icons.restart_alt_rounded,
                    label: 'Restaurar',
                    onTap: onReset,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: cfCoral,
                minimumSize: const Size.fromHeight(44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onPressed: onLock,
              icon: const Icon(Icons.lock_rounded, size: 19),
              label: const Text('Bloquear dibujo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: cfNavy, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xEFFFFFFF),
      shape: const CircleBorder(),
      elevation: 5,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon, color: cfNavy),
      ),
    );
  }
}
