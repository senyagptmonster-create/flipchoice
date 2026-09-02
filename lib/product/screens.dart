import 'dart:math';

import 'package:flutter/material.dart';

import '../app/brand.dart';
import '../app/theme.dart';
import 'choice_store.dart';

/// Экран 1. Режимы выбора
class ModesScreen extends StatelessWidget {
  const ModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ChoiceScope.of(context);

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('FlipChoice', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('Быстрые случайные решения без сомнений', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 20),
            _ModeCard(
              title: 'Бросок монетки',
              subtitle: 'Орёл или Решка для решений 50/50',
              icon: Icons.monetization_on_rounded,
              accentColor: cAccent,
              textColor: Colors.black,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => CoinScreen(store: store)),
              ),
            ),
            const SizedBox(height: 14),
            _ModeCard(
              title: 'Рулетка вариантов',
              subtitle: 'Колесо фортуны для списка от 2 до 8 опций',
              icon: Icons.pie_chart_rounded,
              accentColor: cAccent2,
              textColor: Colors.white,
              onTap: () {
                final set = store.sets.isNotEmpty ? store.sets.first : ChoiceSet(id: 'd', title: 'Выбор', options: ['Вариант А', 'Вариант Б']);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => WheelScreen(choiceSet: set, store: store)),
                );
              },
            ),
            const SizedBox(height: 14),
            _ModeCard(
              title: 'Тайные карточки',
              subtitle: 'Выбери одну закрытую карту наугад',
              icon: Icons.style_rounded,
              accentColor: cSurface,
              textColor: cInk,
              borderColor: cEdge,
              onTap: () {
                final set = store.sets.length > 1 ? store.sets[1] : store.sets.first;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => CardsScreen(choiceSet: set, store: store)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor ?? Colors.transparent, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: textColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.display(18, color: textColor)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTheme.text(12.5, color: textColor.withValues(alpha: 0.75))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: textColor.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

/// Экран Монетки
class CoinScreen extends StatefulWidget {
  const CoinScreen({super.key, required this.store});

  final ChoiceStore store;

  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends State<CoinScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _result = 'Орёл';
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCoin() {
    if (_isFlipping) return;
    setState(() => _isFlipping = true);
    _controller.reset();
    _controller.forward().then((_) {
      final isHeads = Random().nextBool();
      setState(() {
        _result = isHeads ? 'Орёл (Да)' : 'Решка (Нет)';
        _isFlipping = false;
      });
      widget.store.addHistory('Бросок монетки', _result, 'Монетка');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: cInk),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Монетка', style: AppTheme.display(18)),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final angle = _controller.value * pi * 8;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(angle),
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: cAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: cAccent.withValues(alpha: 0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _isFlipping ? '?' : (_result.contains('Орёл') ? 'ОРЁЛ' : 'РЕШКА'),
                        style: AppTheme.display(24, color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 36),
            Text(
              _isFlipping ? 'Монетка в воздухе...' : _result,
              style: AppTheme.display(24, color: cInk),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _flipCoin,
                  child: Text('Бросить монетку', style: AppTheme.text(16, color: Colors.white, weight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран Рулетки
class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key, required this.choiceSet, required this.store});

  final ChoiceSet choiceSet;
  final ChoiceStore store;

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  double _currentAngle = 0;
  String _selectedResult = '';

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _selectedResult = widget.choiceSet.options.first;
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _spin() {
    if (_anim.isAnimating) return;
    final options = widget.choiceSet.options;
    final rand = Random();
    final extraSpins = 4 + rand.nextInt(3);
    final chosenIndex = rand.nextInt(options.length);
    final sectorAngle = 2 * pi / options.length;
    final targetAngle = _currentAngle + (extraSpins * 2 * pi) + (chosenIndex * sectorAngle);

    final animTween = Tween<double>(begin: _currentAngle, end: targetAngle).animate(
      CurvedAnimation(parent: _anim, curve: Curves.decelerate),
    );

    _anim.reset();
    animTween.addListener(() {
      setState(() => _currentAngle = animTween.value);
    });

    _anim.forward().then((_) {
      setState(() {
        _selectedResult = options[chosenIndex];
      });
      widget.store.addHistory(widget.choiceSet.title, _selectedResult, 'Рулетка');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: cInk),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.choiceSet.title, style: AppTheme.display(18)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Transform.rotate(
                  angle: _currentAngle,
                  child: Container(
                    width: 260,
                    height: 260,
                    margin: const EdgeInsets.only(top: 14),
                    child: CustomPaint(
                      painter: _RouletteWheelPainter(options: widget.choiceSet.options),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down_rounded, size: 40, color: Colors.black),
              ],
            ),
            const SizedBox(height: 30),
            Text('Результат:', style: AppTheme.text(13, color: AppTheme.textMuted)),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _selectedResult,
                textAlign: TextAlign.center,
                style: AppTheme.display(24, color: cInk),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: cAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _spin,
                  child: Text('Крутить колесо', style: AppTheme.text(16, color: Colors.black, weight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouletteWheelPainter extends CustomPainter {
  final List<String> options;
  _RouletteWheelPainter({required this.options});

  static const colors = [0xFFB9F227, 0xFF111111, 0xFF37A0D4, 0xFFF2545B, 0xFFFFA502, 0xFF9B59B6];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweep = 2 * pi / max(options.length, 1);

    for (int i = 0; i < options.length; i++) {
      final paint = Paint()
        ..color = Color(colors[i % colors.length])
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweep,
        sweep,
        true,
        paint,
      );
    }

    // Обводка колеса
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Центр
    canvas.drawCircle(center, 18, Paint()..color = Colors.white);
    canvas.drawCircle(center, 18, Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant _RouletteWheelPainter oldDelegate) => false;
}

/// Экран Тайных карточек
class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key, required this.choiceSet, required this.store});

  final ChoiceSet choiceSet;
  final ChoiceStore store;

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  int? _revealedIndex;

  @override
  Widget build(BuildContext context) {
    final options = widget.choiceSet.options;

    return Scaffold(
      backgroundColor: cBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: cInk),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.choiceSet.title, style: AppTheme.display(18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Выбери карту', style: AppTheme.display(24)),
              const SizedBox(height: 4),
              Text('Нажми на любую карту, чтобы открыть выбор', style: AppTheme.text(13, color: AppTheme.textMuted)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  itemCount: options.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, i) {
                    final isRevealed = _revealedIndex == i;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _revealedIndex = i);
                        widget.store.addHistory(widget.choiceSet.title, options[i], 'Карточки');
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isRevealed ? cAccent : cSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isRevealed ? Colors.black : cEdge, width: isRevealed ? 2 : 1),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: isRevealed
                                ? Text(
                                    options[i],
                                    textAlign: TextAlign.center,
                                    style: AppTheme.display(18, color: Colors.black),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.help_outline_rounded, size: 36, color: cEdge),
                                      const SizedBox(height: 6),
                                      Text('Карта #${i + 1}', style: AppTheme.text(12, color: AppTheme.textMuted)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Экран 2. Конструктор вариантов
class BuilderScreen extends StatefulWidget {
  const BuilderScreen({super.key});

  @override
  State<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends State<BuilderScreen> {
  final _titleController = TextEditingController(text: 'Мой выбор');
  final List<TextEditingController> _optionControllers = [
    TextEditingController(text: 'Вариант 1'),
    TextEditingController(text: 'Вариант 2'),
    TextEditingController(text: 'Вариант 3'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 10) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ChoiceScope.of(context);

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('Конструктор', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('Создай свой список для колеса или карт', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 18),
            TextField(
              controller: _titleController,
              style: AppTheme.text(16, color: cInk),
              decoration: InputDecoration(
                labelText: 'Тема выбора',
                filled: true,
                fillColor: cSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: cEdge)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Варианты (${_optionControllers.length})', style: AppTheme.display(16)),
            const SizedBox(height: 8),
            ...List.generate(_optionControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _optionControllers[index],
                        style: AppTheme.text(15, color: cInk),
                        decoration: InputDecoration(
                          hintText: 'Вариант ${index + 1}',
                          filled: true,
                          fillColor: cSurface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: cEdge)),
                        ),
                      ),
                    ),
                    if (_optionControllers.length > 2)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                        onPressed: () {
                          setState(() {
                            _optionControllers.removeAt(index);
                          });
                        },
                      ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add_rounded, color: cAccent2),
              label: Text('Добавить вариант', style: AppTheme.text(14, color: cAccent2, weight: FontWeight.w700)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  final title = _titleController.text.trim();
                  final options = _optionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
                  if (options.length >= 2) {
                    await store.addSet(title.isEmpty ? 'Выбор' : title, options);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Набор сохранён в списки!')),
                      );
                    }
                  }
                },
                child: Text('Сохранить набор', style: AppTheme.text(15.5, color: Colors.white, weight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран 3. Сохранённые наборы
class SavedSetsScreen extends StatelessWidget {
  const SavedSetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ChoiceScope.of(context);
    final sets = store.sets;

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('Списки вариантов', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('${sets.length} готовых списков для выбора', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 18),
            ...sets.map((s) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cEdge),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(s.title, style: AppTheme.display(18)),
                        ),
                        if (!s.isPreset)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                            onPressed: () => store.deleteSet(s),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${s.options.length} вариантов: ${s.options.join(", ")}',
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: AppTheme.text(12.5, color: AppTheme.textMuted)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: (_) => WheelScreen(choiceSet: s, store: store)),
                            ),
                            icon: const Icon(Icons.pie_chart_rounded, size: 16, color: Colors.black),
                            label: const Text('Колесо', style: TextStyle(color: Colors.black, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: (_) => CardsScreen(choiceSet: s, store: store)),
                            ),
                            icon: const Icon(Icons.style_rounded, size: 16, color: Colors.black),
                            label: const Text('Карты', style: TextStyle(color: Colors.black, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Экран 4. История решений
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ChoiceScope.of(context);
    final history = store.history;

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('История решений', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('Все прошлые броски и выборы', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 18),
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('История пуста', style: AppTheme.text(14, color: AppTheme.textMuted)),
                ),
              )
            else
              ...history.map((h) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cEdge),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: cAccent, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, color: Colors.black, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.result, style: AppTheme.text(15, color: cInk, weight: FontWeight.w700)),
                            Text('${h.title} · ${h.mode}', style: AppTheme.text(12, color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// Экран 5. Настройки
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ChoiceScope.of(context);

    return Scaffold(
      backgroundColor: cBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Text('Настройки', style: AppTheme.display(28)),
            const SizedBox(height: 4),
            Text('FlipChoice v1.0.0', style: AppTheme.text(13.5, color: AppTheme.textMuted)),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: cSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cEdge),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.tune_rounded, color: Colors.black),
                    title: Text('Списков в базе', style: AppTheme.text(15, color: cInk)),
                    trailing: Text('${store.sets.length}', style: AppTheme.text(15, color: Colors.black, weight: FontWeight.w700)),
                  ),
                  const Divider(height: 1, color: cEdge),
                  ListTile(
                    leading: const Icon(Icons.restart_alt_rounded, color: Colors.redAccent),
                    title: const Text('Сбросить все списки и историю', style: TextStyle(color: Colors.redAccent)),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: cSurface,
                          title: Text('Сбросить данные?', style: AppTheme.display(18)),
                          content: Text('Все пользовательские наборы будут удалены.', style: AppTheme.text(14, color: cInk)),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Отмена')),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Сбросить'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await store.resetAll();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
