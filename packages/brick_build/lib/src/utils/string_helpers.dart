// ignore: avoid_classes_with_only_static_members
///
class StringHelpers {
  /// See [_EscapedDartString].
  static String escape(String contents) => _EscapedDartString(contents).toString();

  /// Convert a camelized string to snake_case
  /// e.g. `aLongFieldName` becomes `a_long_field_name`
  /// Taken from [json_serializable](https://github.com/dart-lang/json_serializable/blob/d7e6612cf947e150710007a63b439f8f0c316d42/json_serializable/lib/src/utils.dart#L38-L47)
  static String snakeCase(String input) => input.replaceAllMapped(RegExp('[A-Z]'), (match) {
        var lower = match.group(0)!.toLowerCase();

        if (match.start > 0) {
          lower = '_$lower';
        }

        return lower;
      });
}

// Borrowed from [JsonSerializable](https://github.com/dart-lang/json_serializable/blob/9fcee71528f17f8e9e80e90003264e84d048977b/json_serializable/lib/src/utils.dart)

/// Returns a quoted String literal for [contents] that can be used in generated
/// Dart code.
class _EscapedDartString {
  final String contents;

  _EscapedDartString(this.contents);

  String escape() {
    var value = contents;
    var hasSingleQuote = false;
    var hasDoubleQuote = false;
    var hasDollar = false;
    var canBeRaw = true;

    value = value.replaceAllMapped(_escapeRegExp, (match) {
      final value = match[0]!;
      if (value == "'") {
        hasSingleQuote = true;
        return value;
      } else if (value == '"') {
        hasDoubleQuote = true;
        return value;
      } else if (value == r'$') {
        hasDollar = true;
        return value;
      }

      canBeRaw = false;
      return _escapeMap[value] ?? _getHexLiteral(value);
    });

    if (!hasDollar) {
      if (hasSingleQuote) {
        if (!hasDoubleQuote) {
          return '"$value"';
        }
      } else {
        return "'$value'";
      }
    }

    if (hasDollar && canBeRaw) {
      if (hasSingleQuote) {
        if (!hasDoubleQuote) {
          return 'r"$value"';
        }
      } else {
        return "r'$value'";
      }
    }

    // The only safe way to wrap the content is to escape all of the
    // problematic characters - `$`, `'`, and `"`
    final string = value.replaceAll(_dollarQuoteRegexp, r'\');
    return "'$string'";
  }

  /// A [RegExp] that matches whitespace characters that should be escaped and
  /// single-quote, double-quote, and `$`
  final _escapeRegExp = RegExp('[\$\'"\\x00-\\x07\\x0E-\\x1F$_escapeMapRegexp]');

  final _dollarQuoteRegexp = RegExp(r"""(?=[$'"])""");

  /// A [Map] between whitespace characters & `\` and their escape sequences.
  static const _escapeMap = {
    '\b': r'\b', // 08 - backspace
    '\t': r'\t', // 09 - tab
    '\n': r'\n', // 0A - new line
    '\v': r'\v', // 0B - vertical tab
    '\f': r'\f', // 0C - form feed
    '\r': r'\r', // 0D - carriage return
    '\x7F': r'\x7F', // delete
    r'\': r'\\', // backslash
  };

  static final _escapeMapRegexp = _escapeMap.keys.map(_getHexLiteral).join();

  /// Given single-character string, return the hex-escaped equivalent.
  static String _getHexLiteral(String input) {
    final rune = input.runes.single;
    final value = rune.toRadixString(16).toUpperCase().padLeft(2, '0');
    return '\\x$value';
  }

  @override
  String toString() => escape();
}
