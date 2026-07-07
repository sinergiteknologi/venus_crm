import '../models/dropdown_option.dart';

class PipeDataParser {
  static List<String> split(String? value) {
    if (value == null || value.isEmpty) return [];
    return value.split('|');
  }

  static List<DropdownOption> parseCodeName(String? codeStr, String? nameStr) {
    final codes = split(codeStr);
    final names = split(nameStr);
    if (codes.isEmpty) return [];
    return List.generate(codes.length, (i) {
      return DropdownOption(
        code: codes[i],
        name: i < names.length ? names[i] : codes[i],
      );
    });
  }

  static List<DropdownOption> parseSales(String? pref1, String? pref2, String? pref3) {
    final codes = split(pref2);
    final names = split(pref3);
    if (codes.isEmpty) return [];
    return List.generate(codes.length, (i) {
      return DropdownOption(
        code: codes[i],
        name: i < names.length ? names[i] : codes[i],
      );
    });
  }

  static List<DropdownOption> parseSalesOwners(String? pref1, String? pref2, String? pref3) {
    final users = split(pref1);
    final names = split(pref3);
    if (names.isEmpty) return [];
    return List.generate(names.length, (i) {
      return DropdownOption(
        code: i < users.length ? users[i] : '',
        name: names[i],
      );
    });
  }

  static List<DropdownOption> withEmptyOption(List<DropdownOption> items) {
    return [const DropdownOption(code: '', name: ''), ...items];
  }

  static List<DropdownOption> parseActivityType(String? pref1, String? pref2, String? pref3) {
    final codes = split(pref1);
    final names = split(pref2);
  // pref3 = IsLocationRequired (unused for dropdown label)
    if (codes.isEmpty) return [];
    return List.generate(codes.length, (i) {
      return DropdownOption(
        code: codes[i],
        name: i < names.length ? names[i] : codes[i],
      );
    });
  }

  static List<Map<String, String>> parseRows(Map<String, String?> prefs, int columnCount) {
    final columns = List.generate(
      columnCount,
      (i) => split(prefs['Pref${i + 1}']),
    );
    if (columns.isEmpty || columns.first.isEmpty) return [];
    final rowCount = columns.first.length;
    return List.generate(rowCount, (row) {
      final map = <String, String>{};
      for (var col = 0; col < columnCount; col++) {
        map['Pref${col + 1}'] =
            col < columns.length && row < columns[col].length ? columns[col][row] : '';
      }
      return map;
    });
  }
}
