import 'package:flutter/material.dart';

import '../theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 42 : 58,
          height: compact ? 42 : 58,
          decoration: BoxDecoration(
            color: cfNavy,
            borderRadius: BorderRadius.circular(compact ? 13 : 18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22002D5B),
                blurRadius: 16,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'CF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 16 : 21,
                ),
              ),
              Positioned(
                right: compact ? 3 : 5,
                bottom: compact ? 3 : 5,
                child: Icon(
                  Icons.edit_rounded,
                  color: cfCoral,
                  size: compact ? 14 : 18,
                ),
              ),
            ],
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CF Calca Fácil',
                style: TextStyle(
                  color: cfNavy,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Dos formas de calcar, una sola app.',
                style: TextStyle(
                  color: cfCoral,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
