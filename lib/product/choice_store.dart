import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChoiceSet {
  final String id;
  String title;
  List<String> options;
  bool isPreset;

  ChoiceSet({
    required this.id,
    required this.title,
    required this.options,
    this.isPreset = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'options': options,
        'isPreset': isPreset,
      };

  static ChoiceSet fromJson(Map<String, dynamic> j) => ChoiceSet(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        options: (j['options'] as List? ?? []).map((e) => e.toString()).toList(),
        isPreset: j['isPreset'] == true,
      );
}

class HistoryEntry {
  final String id;
  final String title;
  final String result;
  final String mode;
  final DateTime date;

  HistoryEntry({
    required this.id,
    required this.title,
    required this.result,
    required this.mode,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'result': result,
        'mode': mode,
        'date': date.toIso8601String(),
      };

  static HistoryEntry fromJson(Map<String, dynamic> j) => HistoryEntry(
        id: (j['id'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        result: (j['result'] ?? '').toString(),
        mode: (j['mode'] ?? 'Колесо').toString(),
        date: DateTime.tryParse('${j['date']}') ?? DateTime.now(),
      );
}

class ChoiceStore extends ChangeNotifier {
  static const _setsKey = 'flipchoice_sets_v1';
  static const _historyKey = 'flipchoice_history_v1';

  final List<ChoiceSet> _sets = [];
  final List<HistoryEntry> _history = [];
  bool _ready = false;

  bool get ready => _ready;
  List<ChoiceSet> get sets => List.unmodifiable(_sets);
  List<HistoryEntry> get history => List.unmodifiable(_history);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawSets = prefs.getString(_setsKey);
      if (rawSets != null) {
        final list = jsonDecode(rawSets) as List;
        _sets.clear();
        for (final item in list) {
          _sets.add(ChoiceSet.fromJson(item as Map<String, dynamic>));
        }
      }
      final rawHist = prefs.getString(_historyKey);
      if (rawHist != null) {
        final list = jsonDecode(rawHist) as List;
        _history.clear();
        for (final item in list) {
          _history.add(HistoryEntry.fromJson(item as Map<String, dynamic>));
        }
      }
    } catch (_) {}

    if (_sets.isEmpty) {
      _seedDemoSets();
    }

    _ready = true;
    notifyListeners();
  }

  void _seedDemoSets() {
    _sets.addAll([
      ChoiceSet(
        id: 's1',
        title: 'Да или Нет',
        options: ['Да, точно!', 'Нет, не стоит'],
        isPreset: true,
      ),
      ChoiceSet(
        id: 's2',
        title: 'Где пообедать?',
        options: ['Итальянская паста', 'Азиатский вок', 'Бургеры и гриль', 'Здоровый боул', 'Домашний обед'],
        isPreset: true,
      ),
      ChoiceSet(
        id: 's3',
        title: 'Чем заняться вечером?',
        options: ['Посмотреть фильм', 'Почитать книгу', 'Прогулка в парке', 'Настольная игра', 'Спорт и растяжка'],
        isPreset: true,
      ),
      ChoiceSet(
        id: 's4',
        title: 'С чего начать проект?',
        options: ['Нарисовать UI в Figma', 'Написать список задач', 'Собрать референсы', 'Начать писать код'],
        isPreset: true,
      ),
    ]);
    _history.addAll([
      HistoryEntry(
        id: 'h1',
        title: 'Где пообедать?',
        result: 'Азиатский вок',
        mode: 'Рулетка',
        date: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      HistoryEntry(
        id: 'h2',
        title: 'Да или Нет',
        result: 'Орёл (Да)',
        mode: 'Монетка',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_setsKey, jsonEncode(_sets.map((s) => s.toJson()).toList()));
      await prefs.setString(_historyKey, jsonEncode(_history.map((h) => h.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> addHistory(String title, String result, String mode) async {
    _history.insert(0, HistoryEntry(
      id: 'h_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      result: result,
      mode: mode,
      date: DateTime.now(),
    ));
    notifyListeners();
    await _persist();
  }

  Future<void> addSet(String title, List<String> options) async {
    _sets.add(ChoiceSet(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      options: options.where((o) => o.trim().isNotEmpty).toList(),
    ));
    notifyListeners();
    await _persist();
  }

  Future<void> deleteSet(ChoiceSet set) async {
    _sets.removeWhere((s) => s.id == set.id);
    notifyListeners();
    await _persist();
  }

  Future<void> resetAll() async {
    _sets.clear();
    _history.clear();
    _seedDemoSets();
    notifyListeners();
    await _persist();
  }
}

class ChoiceScope extends InheritedNotifier<ChoiceStore> {
  const ChoiceScope({super.key, required ChoiceStore store, required super.child})
      : super(notifier: store);

  static ChoiceStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ChoiceScope>();
    assert(scope != null, 'ChoiceScope not found');
    return scope!.notifier!;
  }
}
