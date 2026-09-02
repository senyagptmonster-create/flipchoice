import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flipchoice/app/theme.dart';
import 'package:flipchoice/product/product_app.dart';

void main() {
  setUp(() {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget app() => MaterialApp(theme: AppTheme.build(), home: const ProductApp());

  testWidgets('режимы выбора открываются и отображаются', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('FlipChoice'), findsOneWidget);
    expect(find.text('Бросок монетки'), findsOneWidget);
    expect(find.text('Рулетка вариантов'), findsOneWidget);
  });

  testWidgets('вкладки переключаются без ошибок', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Создать'));
    await tester.pumpAndSettle();
    expect(find.text('Конструктор'), findsWidgets);

    await tester.tap(find.text('Списки'));
    await tester.pumpAndSettle();
    expect(find.text('Списки вариантов'), findsWidgets);

    await tester.tap(find.text('История'));
    await tester.pumpAndSettle();
    expect(find.text('История решений'), findsWidgets);

    await tester.tap(find.text('Опции'));
    await tester.pumpAndSettle();
    expect(find.text('Настройки'), findsWidgets);
  });

  testWidgets('экран монетки открывается и бросается', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Бросок монетки'));
    await tester.pumpAndSettle();

    expect(find.text('Бросить монетку'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('на узком экране ничего не переполняется', (tester) async {
    tester.view.physicalSize = const Size(720, 1440);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
