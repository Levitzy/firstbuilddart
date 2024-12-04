// lib/utils/json_formatter.dart
class JsonFormatter {
  static String formatJson(dynamic data, [String prefix = '']) {
    List<String> result = [];

    void recurse(dynamic obj, [String prefix = '']) {
      if (obj is Map) {
        for (var entry in obj.entries) {
          if (entry.value is Map || entry.value is List) {
            result.add('$prefix[</>] [${entry.key}]:');
            recurse(entry.value, prefix);
          } else {
            result.add('$prefix[</>] [${entry.key}]: ${entry.value}');
          }
        }
      } else if (obj is List) {
        for (var item in obj) {
          recurse(item, prefix);
        }
      }
    }

    recurse(data);
    return result.join('\n');
  }
}