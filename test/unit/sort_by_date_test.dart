import 'package:flutter_test/flutter_test.dart';
import 'package:img_syncer/util.dart';

void main() {
  group('sortByDateDesc（issue #84 排序护栏）', () {
    test('乱序输入 → 按日期降序输出', () {
      final items = <Map<String, Object>>[
        {'id': 'a', 'date': DateTime(2020, 3, 1)},
        {'id': 'b', 'date': DateTime(2023, 11, 15)},
        {'id': 'c', 'date': DateTime(2021, 7, 8)},
      ];
      final sorted = sortByDateDesc(items, (m) => m['date'] as DateTime);
      expect(sorted.map((m) => m['id']).toList(), ['b', 'c', 'a']);
    });

    test('同一天多条 → 倒序输出', () {
      final items = <Map<String, Object>>[
        {'id': 'a', 'date': DateTime(2023, 1, 1, 10)},
        {'id': 'b', 'date': DateTime(2023, 1, 1, 8)},
        {'id': 'c', 'date': DateTime(2023, 1, 1, 12)},
      ];
      final sorted = sortByDateDesc(items, (m) => m['date'] as DateTime);
      expect(sorted.map((m) => m['id']).toList(), ['c', 'a', 'b']);
    });

    test('不修改原列表', () {
      final items = <Map<String, Object>>[
        {'id': 'a', 'date': DateTime(2020)},
        {'id': 'b', 'date': DateTime(2023)},
      ];
      final sorted = sortByDateDesc(items, (m) => m['date'] as DateTime);
      expect(items.map((m) => m['id']).toList(), ['a', 'b'],
          reason: '原列表顺序不应被改变');
      expect(sorted.length, 2);
    });

    test('空列表', () {
      expect(
          sortByDateDesc<Map<String, Object>>(
              <Map<String, Object>>[], (m) => m['date'] as DateTime),
          isEmpty);
    });
  });
}
