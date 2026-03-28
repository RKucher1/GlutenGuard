class IngredientRegionDetector {
  /// Extracts the ingredient text block from OCR lines.
  ///
  /// Scans [lines] for the first line that starts with an [anchors] phrase,
  /// then collects lines until a [terminators] phrase is hit.
  /// Falls back to the line with the most commas if no anchor is found.
  static String extract(
    List<String> lines, {
    required List<String> anchors,
    required List<String> terminators,
  }) {
    if (lines.isEmpty) return '';

    int startIndex = -1;
    String? strippedAnchorLine;

    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase().trim();
      for (final anchor in anchors) {
        if (lower.startsWith(anchor) ||
            lower == anchor.replaceAll(':', '').trim()) {
          startIndex = i;
          // Strip the anchor word itself from the first captured line
          final afterAnchor = lines[i]
              .substring(anchor.length.clamp(0, lines[i].length))
              .trim();
          strippedAnchorLine = afterAnchor;
          break;
        }
      }
      if (startIndex >= 0) break;
    }

    if (startIndex < 0) {
      return _longestTextBlock(lines);
    }

    final collected = <String>[];
    if (strippedAnchorLine != null && strippedAnchorLine.isNotEmpty) {
      collected.add(strippedAnchorLine);
    }

    for (int i = startIndex + 1; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase().trim();

      bool isTerminator = false;
      for (final term in terminators) {
        if (lower.startsWith(term) || lower.contains(term)) {
          isTerminator = true;
          break;
        }
      }
      if (isTerminator) break;

      // Short lines after collecting substantial text = section break
      if (collected.length > 3 && line.trim().length < 4) break;

      collected.add(line.trim());
    }

    return collected.join(' ').trim();
  }

  static String _longestTextBlock(List<String> lines) {
    if (lines.isEmpty) return '';
    return lines.reduce((a, b) {
      final aCommas = a.split(',').length;
      final bCommas = b.split(',').length;
      return aCommas >= bCommas ? a : b;
    });
  }
}

class NutritionRegionDetector {
  static const _anchors = [
    'nutrition facts',
    'supplement facts',
    'nutritional information',
    'valeurs nutritives',
  ];

  static String? extract(List<String> lines) {
    int startIndex = -1;

    for (int i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase().trim();
      for (final anchor in _anchors) {
        if (lower.contains(anchor)) {
          startIndex = i;
          break;
        }
      }
      if (startIndex >= 0) break;
    }

    // Fallback: find 'Calories' line with a number
    if (startIndex < 0) {
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].toLowerCase().contains('calories') &&
            lines[i].contains(RegExp(r'\d'))) {
          startIndex = i;
          break;
        }
      }
    }

    if (startIndex < 0) return null;

    final collected = <String>[];
    for (int i = startIndex;
        i < lines.length && i < startIndex + 30;
        i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      collected.add(line);
    }

    return collected.isEmpty ? null : collected.join('\n');
  }
}
