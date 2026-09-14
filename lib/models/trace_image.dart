import 'dart:io';

import 'package:flutter/material.dart';

class TraceImage {
  const TraceImage.asset({required this.name, required this.path})
    : isAsset = true;
  const TraceImage.file({required this.name, required this.path})
    : isAsset = false;

  final String name;
  final String path;
  final bool isAsset;

  ImageProvider get provider =>
      isAsset ? AssetImage(path) : FileImage(File(path));
}

const builtInDrawings = <TraceImage>[
  TraceImage.asset(
    name: 'Retrato amable',
    path: 'assets/drawings/retrato_01.jpg',
  ),
  TraceImage.asset(
    name: 'Retrato a tinta',
    path: 'assets/drawings/retrato_02.jpg',
  ),
  TraceImage.asset(
    name: 'Retrato sonriente',
    path: 'assets/drawings/retrato_03.jpg',
  ),
  TraceImage.asset(
    name: 'Retrato sereno',
    path: 'assets/drawings/retrato_04.jpg',
  ),
  TraceImage.asset(
    name: 'Retrato detallado',
    path: 'assets/drawings/retrato_05.jpg',
  ),
];
