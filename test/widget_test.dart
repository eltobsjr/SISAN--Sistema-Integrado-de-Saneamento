import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sisan/core/theme/app_theme.dart';

void main() {
  test('AppTheme.light() usa a cor primária da identidade Água Viva', () {
    final theme = AppTheme.light();
    expect(theme.colorScheme.primary, const Color(0xFF0288D1));
  });
}
