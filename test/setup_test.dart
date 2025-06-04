import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('After steps appear after groups ', () {
    const featureFile = '''
Feature: Testing feature
  Background:
    Given the server always return errors
  After:
    And the test finishes
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_server_always_return_errors.dart';
import './step/the_test_finishes.dart';
import './step/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theServerAlwaysReturnErrors(tester);
    }
    Future<void> bddTearDown(WidgetTester tester) async {
      await theTestFinishes(tester);
    }
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
}
