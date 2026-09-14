// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart' show Size;
import 'package:flutter_test/flutter_test.dart';

import 'package:cf_calca_facil/main.dart';

void main() {
  testWidgets('shows the two tracing modes', (WidgetTester tester) async {
    await tester.pumpWidget(const CfCalcaFacilApp());

    expect(find.text('CF Calca Fácil'), findsOneWidget);
    expect(find.text('Sobre la pantalla'), findsOneWidget);
    expect(find.text('Con la cámara'), findsOneWidget);
    expect(find.text('Mi blog'), findsOneWidget);
    expect(find.text('Instagram'), findsOneWidget);
  });

  testWidgets('adapts the home to a tablet viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CfCalcaFacilApp());

    expect(find.text('¿Cómo quieres calcar?'), findsOneWidget);
    expect(find.text('Elegir dibujo'), findsOneWidget);
    expect(find.text('Abrir cámara'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
